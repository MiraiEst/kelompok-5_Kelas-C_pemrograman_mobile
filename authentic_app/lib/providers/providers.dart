import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/api/catalog_api.dart';
import '../data/api/currency_api.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/notification_service.dart';
import '../domain/bidding/proxy_engine.dart';
import '../domain/models/app_notification.dart';
import '../domain/models/app_user.dart';
import '../domain/models/bid.dart';
import '../domain/models/catalog_product.dart';
import '../domain/models/listing.dart';

// =============================================================================
// State management: Riverpod.
// Infrastructure -> repositories -> streams/futures -> UI controllers.
// =============================================================================

// --- Infrastructure ----------------------------------------------------------

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

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
final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository(ref.watch(firestoreProvider)));
final listingRepositoryProvider =
    Provider<ListingRepository>((ref) => ListingRepository(ref.watch(firestoreProvider)));
final catalogApiProvider =
    Provider<CatalogApi>((ref) => CatalogApi(ref.watch(httpClientProvider)));
final currencyApiProvider =
    Provider<CurrencyApi>((ref) => CurrencyApi(ref.watch(httpClientProvider)));

// --- Auth / current user -------------------------------------------------------

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's profile, including their role (authorization).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
});

final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider).value?.isAdmin ?? false,
);

String? _uid(Ref ref) => ref.watch(authStateProvider).value?.uid;

// --- Listings ------------------------------------------------------------------

final activeListingsProvider = StreamProvider<List<Listing>>(
  (ref) => ref.watch(listingRepositoryProvider).watchActive(),
);

final listingProvider = StreamProvider.family<Listing?, String>(
  (ref, id) => ref.watch(listingRepositoryProvider).watchListing(id),
);

final bidsProvider = StreamProvider.family<List<Bid>, String>(
  (ref, id) => ref.watch(listingRepositoryProvider).watchBids(id),
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

final allListingsProvider = StreamProvider<List<Listing>>(
  (ref) => ref.watch(listingRepositoryProvider).watchAll(),
);

// --- Notifications & watchlist ---------------------------------------------------

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const []);
  return ref.watch(userRepositoryProvider).watchNotifications(uid);
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

final catalogSearchProvider = FutureProvider.family<List<CatalogProduct>, String>(
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

final homeFilterProvider =
    NotifierProvider<HomeFilterNotifier, HomeFilter>(HomeFilterNotifier.new);

final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final f = ref.watch(homeFilterProvider);
  final q = f.query.trim().toLowerCase();
  return ref.watch(activeListingsProvider).whenData(
        (list) => list
            .where((l) => f.category == null || l.category == f.category)
            .where((l) => q.isEmpty || l.title.toLowerCase().contains(q))
            .toList(),
      );
});

// --- Bid controller (AsyncValue state for the bid button) -------------------------

class BidController extends Notifier<AsyncValue<BidDecision?>> {
  @override
  AsyncValue<BidDecision?> build() => const AsyncData(null);

  Future<BidDecision?> place({required String listingId, required int maxAmount}) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(listingRepositoryProvider).placeBid(
            listingId: listingId,
            bidder: user,
            maxAmount: maxAmount,
          ),
    );
    return state.value;
  }
}

final bidControllerProvider =
    NotifierProvider<BidController, AsyncValue<BidDecision?>>(BidController.new);

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
