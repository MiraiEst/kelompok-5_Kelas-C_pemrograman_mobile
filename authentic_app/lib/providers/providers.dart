import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/api/catalog_api.dart';
import '../data/api/currency_api.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/storage_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/courier_rate_service.dart';
import '../data/services/notification_service.dart';
import '../domain/bidding/proxy_engine.dart';
import '../domain/models/app_notification.dart';
import '../domain/models/app_user.dart';
import '../domain/models/bid.dart';
import '../domain/models/catalog_product.dart';
import '../domain/models/listing.dart';
import '../domain/models/order.dart';
import '../domain/models/payout_account.dart';
import '../domain/models/public_profile.dart';

// =============================================================================
// State management: Riverpod.
// Infrastructure -> repositories -> streams/futures -> UI controllers.
// =============================================================================

// --- Infrastructure ----------------------------------------------------------

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

// --- Repositories / APIs -----------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);
final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(ref.watch(firestoreProvider)),
);
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)),
);
final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepository(ref.watch(httpClientProvider)),
);
final catalogApiProvider = Provider<CatalogApi>((ref) => CatalogApi(ref.watch(httpClientProvider)));
final currencyApiProvider = Provider<CurrencyApi>(
  (ref) => CurrencyApi(ref.watch(httpClientProvider)),
);

// --- Auth / current user -------------------------------------------------------

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's profile, including their role (authorization).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  // A signed-in account without a profile would wait forever: create it once.
  // Only for the first snapshot, so a profile deleted by "Delete account"
  // is not brought back.
  var first = true;
  return ref.watch(userRepositoryProvider).watchUser(user.uid).asyncMap((profile) async {
    if (first && profile == null) await ref.read(authRepositoryProvider).ensureProfile(user);
    first = false;
    return profile;
  });
});

final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider).value?.isAdmin ?? false,
);

String? _uid(Ref ref) => ref.watch(authStateProvider).value?.uid;

// --- Listings ------------------------------------------------------------------

final activeListingsProvider = StreamProvider<List<Listing>>(
  (ref) => ref.watch(listingRepositoryProvider).watchActive(),
);

final listingProvider = StreamProvider.autoDispose.family<Listing?, String>(
  (ref, id) => ref.watch(listingRepositoryProvider).watchListing(id),
);

final bidsProvider = StreamProvider.autoDispose.family<List<Bid>, String>(
  (ref, id) => ref.watch(listingRepositoryProvider).watchBids(id),
);

/// My own hidden maximum on a listing (only I can read it).
final myMaxProvider = StreamProvider.autoDispose.family<int?, String>((ref, listingId) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(null);
  return ref.watch(listingRepositoryProvider).watchMyMax(listingId, uid);
});

final publicProfileProvider = StreamProvider.autoDispose.family<PublicProfile?, String>(
  (ref, uid) => ref.watch(userRepositoryProvider).watchPublicProfile(uid),
);

final myListingsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(listingRepositoryProvider).watchBySeller(uid);
});

final myBidsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(listingRepositoryProvider).watchBidOn(uid);
});

/// Active listings I watch or bid on. The phone schedules local "ending soon"
/// reminders for these (see NotificationService.scheduleEndingSoon).
final reminderListingsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(listingRepositoryProvider).watchWatchedBy(uid);
});

final endingSoonRemindersProvider = Provider<List<Listing>?>((ref) {
  // "Ending soon" push switched off in Notification settings: no reminders
  // (an empty list also cancels the ones already scheduled).
  final user = ref.watch(currentUserProvider).value;
  if (user != null && !user.prefFor(NotificationPref.endingSoon).push) return const [];
  final bidOn = ref.watch(myBidsProvider).value;
  final watched = ref.watch(reminderListingsProvider).value;
  if (bidOn == null || watched == null) return null;
  return {
    for (final l in [...bidOn, ...watched])
      if (l.status == ListingStatus.active) l.id: l,
  }.values.toList();
});

/// Listings I won (by bidding or Buy It Now).
final wonListingsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(listingRepositoryProvider).watchWonBy(uid);
});

// --- Orders --------------------------------------------------------------------

final orderProvider = StreamProvider.autoDispose.family<AuctionOrder?, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).watchOrder(id),
);

final myPurchasesProvider = StreamProvider<List<AuctionOrder>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(orderRepositoryProvider).watchPurchases(uid);
});

final mySalesProvider = StreamProvider<List<AuctionOrder>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(orderRepositoryProvider).watchSales(uid);
});

final payoutProvider = StreamProvider<PayoutAccount?>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchPayout(uid);
});

final addressesProvider = StreamProvider<List<Address>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(userRepositoryProvider).watchAddresses(uid);
});

final courierRateServiceProvider = Provider<CourierRateService>((ref) => const FixedCourierRates());

final allListingsProvider = StreamProvider<List<Listing>>(
  (ref) => ref.watch(listingRepositoryProvider).watchAll(),
);

// --- Notifications & watchlist ---------------------------------------------------

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(userRepositoryProvider).watchNotifications(uid);
});

/// Notifications screen paging: 30 per page.
class NotificationsLimit extends Notifier<int> {
  static const pageSize = 30;
  @override
  int build() => pageSize;
  void loadMore() => state += pageSize;
}

final notificationsLimitProvider = NotifierProvider<NotificationsLimit, int>(
  NotificationsLimit.new,
);

final notificationsPageProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  final limit = ref.watch(notificationsLimitProvider);
  return ref.watch(userRepositoryProvider).watchNotificationsPage(uid, limit);
});

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).value?.where((n) => !n.read).length ?? 0,
);

final watchlistIdsProvider = StreamProvider<Set<String>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const <String>{});
  return ref.watch(userRepositoryProvider).watchWatchlistIds(uid);
});

// --- Open-source APIs ------------------------------------------------------------

final categoriesProvider = FutureProvider<List<CatalogCategory>>((ref) async {
  try {
    final list = await ref.watch(catalogApiProvider).categories();
    return list.isEmpty ? CatalogApi.fallbackCategories : list;
  } catch (_) {
    return CatalogApi.fallbackCategories; // offline-friendly
  }
});

final catalogSearchProvider = FutureProvider.autoDispose.family<List<CatalogProduct>, String>(
  (ref, query) => ref.watch(catalogApiProvider).search(query),
);

/// 1 IDR in other currencies, for the price conversion strip.
final idrRatesProvider = FutureProvider<Map<String, double>>(
  (ref) => ref
      .watch(currencyApiProvider)
      .latest(base: 'IDR', symbols: const ['USD', 'EUR', 'SGD', 'MYR']),
);

// --- Home filter (Notifier) ------------------------------------------------------

class HomeFilter {
  const HomeFilter({this.query = '', this.category});
  final String query;
  final String? category;
}

class HomeFilterNotifier extends Notifier<HomeFilter> {
  @override
  HomeFilter build() => const HomeFilter();

  void setQuery(String q) => state = HomeFilter(query: q, category: state.category);
  void setCategory(String? c) => state = HomeFilter(query: state.query, category: c);
}

final homeFilterProvider = NotifierProvider<HomeFilterNotifier, HomeFilter>(HomeFilterNotifier.new);

/// How many Home feed items to load (grows by [pageSize] on scroll).
class HomeFeedLimit extends Notifier<int> {
  static const pageSize = 20;
  @override
  int build() {
    ref.watch(homeFilterProvider.select((f) => f.category)); // reset on category change
    return pageSize;
  }

  void loadMore() => state += pageSize;
}

final homeFeedLimitProvider = NotifierProvider<HomeFeedLimit, int>(HomeFeedLimit.new);

/// Home "All auctions": live, paged, category filtered on the server and
/// title-searched on the client (Firestore has no substring search).
final homeFeedProvider = StreamProvider<({List<Listing> items, bool hasMore})>((ref) {
  final category = ref.watch(homeFilterProvider.select((f) => f.category));
  final limit = ref.watch(homeFeedLimitProvider);
  return ref
      .watch(listingRepositoryProvider)
      .watchActivePage(category: category, limit: limit)
      .map((list) => (items: list, hasMore: list.length >= limit));
});

final filteredHomeFeedProvider = Provider<AsyncValue<({List<Listing> items, bool hasMore})>>((ref) {
  final q = ref.watch(homeFilterProvider.select((f) => f.query)).trim().toLowerCase();
  return ref
      .watch(homeFeedProvider)
      .whenData(
        (page) => (
          items: q.isEmpty
              ? page.items
              : page.items.where((l) => l.title.toLowerCase().contains(q)).toList(),
          hasMore: page.hasMore,
        ),
      );
});

final endingSoonProvider = StreamProvider.autoDispose<List<Listing>>(
  (ref) => ref.watch(listingRepositoryProvider).watchEndingSoon(),
);

// --- Trending --------------------------------------------------------------------

class TrendingSortNotifier extends Notifier<TrendingSort> {
  @override
  TrendingSort build() => TrendingSort.mostBids;
  void select(TrendingSort s) => state = s;
}

final trendingSortProvider = NotifierProvider<TrendingSortNotifier, TrendingSort>(
  TrendingSortNotifier.new,
);

final trendingProvider = StreamProvider.autoDispose.family<List<Listing>, TrendingSort>(
  (ref, sort) => ref.watch(listingRepositoryProvider).watchTrending(sort),
);

/// Top 4 categories by number of live auctions, counted on the client from
/// the active listings already loaded.
final hotCategoriesProvider = Provider<AsyncValue<List<({String slug, int count, String? image})>>>(
  (ref) => ref.watch(activeListingsProvider).whenData((list) {
    final now = DateTime.now();
    final counts = <String, ({int count, String? image})>{};
    for (final l in list.where((l) => l.isLive(now))) {
      final prev = counts[l.category];
      counts[l.category] = (count: (prev?.count ?? 0) + 1, image: prev?.image ?? l.thumbnail);
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.count.compareTo(a.value.count));
    return [
      for (final e in sorted.take(4)) (slug: e.key, count: e.value.count, image: e.value.image),
    ];
  }),
);

// --- Bid controller (AsyncValue state for the bid button) -------------------------

class BidController extends Notifier<AsyncValue<BidDecision?>> {
  @override
  AsyncValue<BidDecision?> build() => const AsyncData(null);

  Future<BidDecision?> place({required String listingId, required int maxAmount}) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(listingRepositoryProvider)
          .placeBid(listingId: listingId, bidder: user, maxAmount: maxAmount),
    );
    return state.value;
  }
}

final bidControllerProvider = NotifierProvider<BidController, AsyncValue<BidDecision?>>(
  BidController.new,
);

// --- Auction closer -----------------------------------------------------------------

/// Closes expired auctions when the app notices them (countdown hits zero).
/// The scheduled Cloud Function does the same server-side; both are safe to
/// run because closing is an idempotent transaction.
class AuctionCloser {
  AuctionCloser(this._ref);
  final Ref _ref;
  final _attempted = <String>{};

  Future<void> ensureClosed(Listing l) async {
    if (!l.isActive || !l.isExpired(DateTime.now())) return;
    if (!_attempted.add(l.id)) return;
    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    final closed = await _ref
        .read(listingRepositoryProvider)
        .closeIfExpired(listingId: l.id, actorUid: uid);
    if (!closed) {
      // Allow a retry a bit later (e.g. device clock slightly ahead).
      Future.delayed(const Duration(seconds: 10), () => _attempted.remove(l.id));
    }
  }
}

final auctionCloserProvider = Provider<AuctionCloser>((ref) => AuctionCloser(ref));
