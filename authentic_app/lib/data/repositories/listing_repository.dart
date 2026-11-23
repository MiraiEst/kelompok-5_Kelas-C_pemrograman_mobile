import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/extensions.dart';
import '../../domain/bidding/proxy_engine.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/bid.dart';
import '../../domain/models/listing.dart';

/// Thrown for business-rule failures the UI should show as-is.
class AuctionException implements Exception {
  const AuctionException(this.message);
  final String message;
  @override
  String toString() => message;
}

enum TrendingSort {
  mostBids('Most bids'),
  mostWatched('Most watched'),
  newToday('New today');

  const TrendingSort(this.label);
  final String label;
}

class ListingRepository {
  ListingRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _listings => _db.collection('listings');

  // ---------------------------------------------------------------------------
  // Queries (realtime Firestore snapshot listeners = live updates, no refresh)
  // ---------------------------------------------------------------------------

  List<Listing> _map(QuerySnapshot<Map<String, dynamic>> q) => q.docs.map(Listing.fromDoc).toList();

  /// Active auctions, ending soonest first. Sorting happens client-side so
  /// no composite index is needed.
  Stream<List<Listing>> watchActive() => _listings
      .where('status', isEqualTo: ListingStatus.active.value)
      .snapshots()
      .map(_map)
      .map((list) => list..sort((a, b) => a.endsAt.compareTo(b.endsAt)));

  /// Home feed page: active auctions ending soonest first, optionally in one
  /// category. Paging grows [limit] (20, 40, 60…) on a live query, so prices
  /// and bid counts on screen stay up to date.
  Stream<List<Listing>> watchActivePage({String? category, required int limit}) {
    Query<Map<String, dynamic>> q = _listings.where(
      'status',
      isEqualTo: ListingStatus.active.value,
    );
    if (category != null) q = q.where('category', isEqualTo: category);
    return q.orderBy('endsAt').limit(limit).snapshots().map(_map);
  }

  /// The next [limit] auctions to end (for "Ending soon").
  Stream<List<Listing>> watchEndingSoon({int limit = 10}) => _listings
      .where('status', isEqualTo: ListingStatus.active.value)
      .where('endsAt', isGreaterThan: Timestamp.now())
      .orderBy('endsAt')
      .limit(limit)
      .snapshots()
      .map(_map);

  /// Trending lists (live). See [TrendingSort].
  Stream<List<Listing>> watchTrending(TrendingSort sort) {
    final active = _listings.where('status', isEqualTo: ListingStatus.active.value);
    final q = switch (sort) {
      TrendingSort.mostBids => active.orderBy('bidCount', descending: true).limit(20),
      TrendingSort.mostWatched => active.orderBy('watcherCount', descending: true).limit(20),
      TrendingSort.newToday =>
        active
            .where(
              'createdAt',
              isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24))),
            )
            .orderBy('createdAt', descending: true)
            .limit(20),
    };
    return q.snapshots().map(_map);
  }

  Stream<Listing?> watchListing(String id) =>
      _listings.doc(id).snapshots().map((s) => s.exists ? Listing.fromDoc(s) : null);

  /// The signed-in user's own maximum bid on a listing (null if none).
  Stream<int?> watchMyMax(String listingId, String uid) => _listings
      .doc(listingId)
      .collection('myMax')
      .doc(uid)
      .snapshots()
      .map((s) => (s.data()?['maxAmount'] as num?)?.toInt());

  Stream<List<Bid>> watchBids(String listingId) => _listings
      .doc(listingId)
      .collection('bids')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((q) => q.docs.map(Bid.fromDoc).toList());

  Stream<List<Listing>> watchBySeller(String uid) => _listings
      .where('sellerId', isEqualTo: uid)
      .snapshots()
      .map(_map)
      .map((l) => l..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  Stream<List<Listing>> watchBidOn(String uid) => _listings
      .where('bidderIds', arrayContains: uid)
      .snapshots()
      .map(_map)
      .map((l) => l..sort((a, b) => a.endsAt.compareTo(b.endsAt)));

  Stream<List<Listing>> watchWonBy(String uid) => _listings
      .where('winnerId', isEqualTo: uid)
      .snapshots()
      .map(_map)
      .map((l) => l..sort((a, b) => b.endsAt.compareTo(a.endsAt)));

  Stream<List<Listing>> watchAll() =>
      _listings.orderBy('createdAt', descending: true).limit(200).snapshots().map(_map);

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// A fresh listing id, so photos can be uploaded before the doc exists.
  String newListingId() => _listings.doc().id;

  Future<String> createListing(NewListing input, AppUser seller, {String? id}) async {
    final endsAt = DateTime.now().add(input.duration.duration);
    // Buy It Now only: fixed price, so the "start" price is the BIN price.
    final start = input.format == ListingFormat.buyNow ? input.buyNowPrice! : input.startPrice;
    final ref = _listings.doc(id);
    await ref.set({
      'sellerId': seller.uid,
      'sellerName': seller.displayName,
      'title': input.title,
      'description': input.description,
      'category': input.category,
      'condition': input.condition.value,
      'imageUrls': input.imageUrls,
      'startPrice': start,
      'reservePrice': input.format.hasAuction ? input.reservePrice : null,
      'buyNowPrice': input.format.hasBuyNow ? input.buyNowPrice : null,
      'shippingCost': input.shippingCost,
      'format': input.format.value,
      'handlingDays': input.handlingDays,
      'location': input.location,
      'acceptsReturns': input.acceptsReturns,
      'returnDays': input.returnDays,
      'createdAt': FieldValue.serverTimestamp(),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': ListingStatus.active.value,
      'currentPrice': start,
      'bidCount': 0,
      'bidderIds': <String>[],
      'leaderId': null,
      'leaderName': null,
      'leaderMax': null,
      'reserveMet': !input.format.hasAuction || input.reservePrice == null,
      'buyNowAvailable': input.format.hasBuyNow && input.buyNowPrice != null,
      'watcherIds': <String>[],
      'watcherCount': 0,
      'winnerId': null,
      'finalPrice': null,
    });
    return ref.id;
  }

  /// Places (or raises) a maximum bid.
  ///
  /// The pure [ProxyBiddingEngine] decides the outcome; the Firestore
  /// transaction makes it atomic, so two people bidding in the same
  /// millisecond can never both "win". Security rules additionally enforce
  /// server time (`request.time < endsAt`) and that sellers can't bid.
  Future<BidDecision> placeBid({
    required String listingId,
    required AppUser bidder,
    required int maxAmount,
  }) {
    final ref = _listings.doc(listingId);
    return _db.runTransaction<BidDecision>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return const BidRejected(AuctionClosed());
      final listing = Listing.fromDoc(snap);

      final decision = ProxyBiddingEngine.evaluate(
        state: listing.engineState,
        bidderId: bidder.uid,
        maxAmount: maxAmount,
        now: DateTime.now(),
      );

      // Advanced Dart: type promotion + object pattern destructuring.
      if (decision is! BidAccepted) return decision;
      final BidAccepted(:kind, :newPrice, :leaderId, :leaderMax, :reserveMet, :previousLeaderId) =
          decision;
      final bidderMasked = bidder.displayName.masked();
      final leaderChanged = leaderId != listing.leaderId;

      // The bidder's own maximum, readable only by them (Your bids, banner).
      tx.set(ref.collection('myMax').doc(bidder.uid), {
        'maxAmount': maxAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(ref.collection('bids').doc(), {
        'userId': bidder.uid,
        'maskedName': bidderMasked,
        'priceAfter': newPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Trending "+12": bids in the current 1-hour window.
      final now = DateTime.now();
      final windowStart = listing.recentBidWindowStart;
      final freshWindow =
          windowStart == null || now.difference(windowStart) > const Duration(hours: 1);

      tx.update(ref, {
        'recentBidCount': freshWindow ? 1 : listing.recentBidCount + 1,
        'recentBidWindowStart': freshWindow
            ? Timestamp.fromDate(now)
            : listing.recentBidWindowStart,
        'currentPrice': newPrice,
        'bidCount': listing.bidCount + 1,
        'bidderIds': listing.bidderIds.contains(bidder.uid)
            ? listing.bidderIds
            : [...listing.bidderIds, bidder.uid],
        'leaderId': leaderId,
        'leaderName': leaderChanged ? bidderMasked : listing.leaderName,
        'leaderMax': leaderMax,
        'reserveMet': reserveMet,
        'buyNowAvailable': false, // Buy It Now disappears after the first bid
        'lastBidAt': FieldValue.serverTimestamp(),
      });

      // Push/in-app notifications. Cloud Functions turn these docs into
      // FCM pushes; the app also shows them as local notifications.
      if (previousLeaderId != null && previousLeaderId != bidder.uid) {
        _notify(
          tx,
          to: previousLeaderId,
          from: bidder.uid,
          type: 'outbid',
          title: "You've been outbid",
          body: '"${listing.title}" is now ${newPrice.toRupiah()}. Raise your max to stay in.',
          listingId: listing.id,
        );
      }
      // Reserve just got met: tell the leading bidder.
      if (!listing.reserveMet && reserveMet) {
        _notify(
          tx,
          to: leaderId,
          from: bidder.uid,
          type: 'reserve_met',
          title: 'Reserve met',
          body: 'The reserve on "${listing.title}" is met. Keep the lead to win it.',
          listingId: listing.id,
        );
      }
      if (kind != AcceptedKind.raisedOwnMax) {
        _notify(
          tx,
          to: listing.sellerId,
          from: bidder.uid,
          type: 'new_bid',
          title: 'New bid on your item',
          body: '"${listing.title}" is now ${newPrice.toRupiah()}.',
          listingId: listing.id,
        );
      }
      return decision;
    });
  }

  /// Buy It Now: ends the auction immediately with the buyer as winner.
  Future<void> buyNow({required String listingId, required AppUser buyer}) {
    final ref = _listings.doc(listingId);
    return _db.runTransaction((tx) async {
      final listing = Listing.fromDoc(await tx.get(ref));
      if (buyer.uid == listing.sellerId) {
        throw const AuctionException('You cannot buy your own item.');
      }
      if (!listing.canBuyNow(DateTime.now())) {
        throw const AuctionException('Buy It Now is no longer available.');
      }
      final price = listing.buyNowPrice!;
      tx.update(ref, {
        'status': ListingStatus.sold.value,
        'winnerId': buyer.uid,
        'finalPrice': price,
        'currentPrice': price,
        'leaderId': buyer.uid,
        'leaderName': buyer.displayName.masked(),
        'buyNowAvailable': false,
        'endedAt': FieldValue.serverTimestamp(),
      });
      _notify(
        tx,
        to: listing.sellerId,
        from: buyer.uid,
        type: 'sold',
        title: 'Sold with Buy It Now',
        body: '"${listing.title}" sold for ${price.toRupiah()}.',
        listingId: listing.id,
      );
    });
  }

  /// Closes an expired auction (winner if reserve met, otherwise unsold).
  ///
  /// Called by the app when a countdown reaches zero, and by the scheduled
  /// Cloud Function. The transaction + status check make it idempotent.
  /// Returns true if this call closed the auction.
  Future<bool> closeIfExpired({required String listingId, required String actorUid}) async {
    final ref = _listings.doc(listingId);
    try {
      return await _db.runTransaction<bool>((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) return false;
        final l = Listing.fromDoc(snap);
        if (!l.isActive || !l.isExpired(DateTime.now())) return false;

        final winnerId = (l.bidCount > 0 && l.reserveMet) ? l.leaderId : null;
        final losers = l.bidderIds.where((id) => id != winnerId);

        if (winnerId != null) {
          tx.update(ref, {
            'status': ListingStatus.sold.value,
            'winnerId': winnerId,
            'finalPrice': l.currentPrice,
            'buyNowAvailable': false,
            'endedAt': FieldValue.serverTimestamp(),
          });
          _notify(
            tx,
            to: winnerId,
            from: actorUid,
            type: 'won',
            title: 'You won!',
            body: 'You won "${l.title}" for ${l.currentPrice.toRupiah()}. Pay within 4 days.',
            listingId: l.id,
            orderId: l.id, // the order id equals the listing id
          );
          _notify(
            tx,
            to: l.sellerId,
            from: actorUid,
            type: 'sold',
            title: 'Your item sold',
            body: '"${l.title}" sold for ${l.currentPrice.toRupiah()}.',
            listingId: l.id,
          );
        } else {
          tx.update(ref, {
            'status': ListingStatus.unsold.value,
            'buyNowAvailable': false,
            'endedAt': FieldValue.serverTimestamp(),
          });
          _notify(
            tx,
            to: l.sellerId,
            from: actorUid,
            type: 'unsold',
            title: 'Auction ended unsold',
            body: l.bidCount == 0
                ? '"${l.title}" ended with no bids. You can relist it.'
                : '"${l.title}" ended below your reserve price.',
            listingId: l.id,
          );
        }
        for (final uid in losers) {
          _notify(
            tx,
            to: uid,
            from: actorUid,
            type: 'lost',
            title: "You didn't win",
            body: '"${l.title}" has ended.',
            listingId: l.id,
          );
        }
        return true;
      });
    } on FirebaseException {
      // e.g. device clock is ahead of server time: the rules reject the
      // close until request.time >= endsAt. Safe to ignore and retry later.
      return false;
    }
  }

  /// Seller can end early only when there are no bids. Admins can always.
  Future<void> endEarly(Listing listing, AppUser actor) async {
    if (!actor.isAdmin && listing.bidCount > 0) {
      throw const AuctionException('Listings with bids cannot be ended early.');
    }
    await _listings.doc(listing.id).update({
      'status': ListingStatus.ended.value,
      'buyNowAvailable': false,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Relist an unsold / ended item as a fresh auction (copy of the original).
  Future<String> relist(Listing l, AppUser seller, AuctionDuration duration) => createListing(
    NewListing(
      title: l.title,
      description: l.description,
      category: l.category,
      condition: l.condition,
      imageUrls: l.imageUrls,
      startPrice: l.startPrice,
      reservePrice: l.reservePrice,
      buyNowPrice: l.buyNowPrice,
      shippingCost: l.shippingCost,
      duration: duration,
    ),
    seller,
  );

  // ---------------------------------------------------------------------------
  // Drafts: users/{uid}/drafts/{draftId} (draftId = the future listing id)
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _drafts(String uid) =>
      _db.collection('users').doc(uid).collection('drafts');

  Future<void> saveDraft(String uid, String draftId, Map<String, dynamic> data) =>
      _drafts(uid).doc(draftId).set({...data, 'updatedAt': FieldValue.serverTimestamp()});

  /// The most recent draft, as (id, data), or null.
  Future<(String, Map<String, dynamic>)?> latestDraft(String uid) async {
    final q = await _drafts(uid).orderBy('updatedAt', descending: true).limit(1).get();
    if (q.docs.isEmpty) return null;
    final d = q.docs.first;
    return (d.id, d.data());
  }

  Future<void> deleteDraft(String uid, String draftId) => _drafts(uid).doc(draftId).delete();

  Future<void> delete(String listingId) => _listings.doc(listingId).delete();

  void _notify(
    Transaction tx, {
    required String to,
    required String from,
    required String type,
    required String title,
    required String body,
    required String listingId,
    String? orderId,
  }) {
    tx.set(_db.collection('users').doc(to).collection('notifications').doc(), {
      'type': type,
      'title': title,
      'body': body,
      'listingId': listingId,
      'orderId': ?orderId,
      'fromUid': from,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
