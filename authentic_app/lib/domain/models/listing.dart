import 'package:cloud_firestore/cloud_firestore.dart';

import '../bidding/proxy_engine.dart';

enum ListingStatus {
  active('active'),
  sold('sold'),
  unsold('unsold'),
  ended('ended'); // ended early by the seller / admin with no bids

  const ListingStatus(this.value);
  final String value;

  static ListingStatus parse(Object? raw) =>
      values.firstWhere((s) => s.value == raw, orElse: () => ListingStatus.ended);
}

enum ItemCondition {
  brandNew('new', 'New'),
  used('used', 'Used'),
  forParts('for_parts', 'For parts');

  const ItemCondition(this.value, this.label);
  final String value;
  final String label;

  static ItemCondition parse(Object? raw) =>
      values.firstWhere((c) => c.value == raw, orElse: () => ItemCondition.used);
}

/// Durations offered when listing. The 5-minute option exists so you can
/// test auction endings during development and demos.
enum AuctionDuration {
  fiveMinutesTest(Duration(minutes: 5), '5 minutes (testing)'),
  oneDay(Duration(days: 1), '1 day'),
  threeDays(Duration(days: 3), '3 days'),
  fiveDays(Duration(days: 5), '5 days'),
  sevenDays(Duration(days: 7), '7 days'),
  tenDays(Duration(days: 10), '10 days');

  const AuctionDuration(this.duration, this.label);
  final Duration duration;
  final String label;
}

class Listing {
  const Listing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.startPrice,
    required this.reservePrice,
    required this.buyNowPrice,
    required this.shippingCost,
    required this.endsAt,
    required this.createdAt,
    required this.status,
    required this.currentPrice,
    required this.bidCount,
    required this.bidderIds,
    required this.leaderId,
    required this.leaderName,
    required this.leaderMax,
    required this.reserveMet,
    required this.buyNowAvailable,
    required this.watcherCount,
    required this.winnerId,
    required this.finalPrice,
  });

  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final String category;
  final ItemCondition condition;
  final List<String> imageUrls;
  final int startPrice;
  final int? reservePrice; // hidden in UI
  final int? buyNowPrice;
  final int shippingCost;
  final DateTime endsAt;
  final DateTime createdAt;
  final ListingStatus status;

  // Auction state (kept on the same doc so one transaction updates it).
  final int currentPrice;
  final int bidCount;
  final List<String> bidderIds;
  final String? leaderId;
  final String? leaderName; // masked
  final int? leaderMax; // hidden: only shown to the leader
  final bool reserveMet;
  final bool buyNowAvailable;
  final int watcherCount;
  final String? winnerId;
  final int? finalPrice;

  bool get hasReserve => reservePrice != null;
  bool get isActive => status == ListingStatus.active;
  bool isExpired(DateTime now) => !now.isBefore(endsAt);
  bool isLive(DateTime now) => isActive && !isExpired(now);
  Duration timeLeft(DateTime now) => endsAt.difference(now);
  String? get thumbnail => imageUrls.isEmpty ? null : imageUrls.first;

  bool canBuyNow(DateTime now) =>
      buyNowPrice != null && buyNowAvailable && bidCount == 0 && isLive(now);

  /// Snapshot for the pure proxy engine (a Dart record).
  AuctionState get engineState => (
        sellerId: sellerId,
        isActive: isActive,
        endsAt: endsAt,
        startPrice: startPrice,
        currentPrice: currentPrice,
        bidCount: bidCount,
        leaderId: leaderId,
        leaderMax: leaderMax,
        reservePrice: reservePrice,
      );

  int get minimumNextBid => ProxyBiddingEngine.minimumBid(engineState);

  static int? _int(Object? v) => (v as num?)?.toInt();

  factory Listing.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Listing(
      id: doc.id,
      sellerId: d['sellerId'] as String? ?? '',
      sellerName: d['sellerName'] as String? ?? 'Seller',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? 'other',
      condition: ItemCondition.parse(d['condition']),
      imageUrls: List<String>.from(d['imageUrls'] as List? ?? const []),
      startPrice: _int(d['startPrice']) ?? 0,
      reservePrice: _int(d['reservePrice']),
      buyNowPrice: _int(d['buyNowPrice']),
      shippingCost: _int(d['shippingCost']) ?? 0,
      endsAt: (d['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ListingStatus.parse(d['status']),
      currentPrice: _int(d['currentPrice']) ?? 0,
      bidCount: _int(d['bidCount']) ?? 0,
      bidderIds: List<String>.from(d['bidderIds'] as List? ?? const []),
      leaderId: d['leaderId'] as String?,
      leaderName: d['leaderName'] as String?,
      leaderMax: _int(d['leaderMax']),
      reserveMet: d['reserveMet'] as bool? ?? true,
      buyNowAvailable: d['buyNowAvailable'] as bool? ?? false,
      watcherCount: _int(d['watcherCount']) ?? 0,
      winnerId: d['winnerId'] as String?,
      finalPrice: _int(d['finalPrice']),
    );
  }
}

/// Input for creating a listing (validated in the form).
class NewListing {
  const NewListing({
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.startPrice,
    required this.duration,
    required this.shippingCost,
    this.reservePrice,
    this.buyNowPrice,
  });

  final String title;
  final String description;
  final String category;
  final ItemCondition condition;
  final List<String> imageUrls;
  final int startPrice;
  final int? reservePrice;
  final int? buyNowPrice;
  final int shippingCost;
  final AuctionDuration duration;
}
