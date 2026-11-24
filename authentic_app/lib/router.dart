import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/repositories/auth_repository.dart';
import 'providers/providers.dart';
import 'domain/models/order.dart';
import 'domain/models/listing.dart';
import 'ui/account/account_screen.dart';
import 'ui/account/account_subscreens.dart';
import 'ui/account/address_screens.dart';
import 'ui/admin/admin_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/register_screen.dart';
import 'ui/auth/verify_email_screen.dart';
import 'ui/bids/your_bids_screen.dart';
import 'ui/checkout/checkout_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/home/home_shell.dart';
import 'ui/legal/legal_screen.dart';
import 'ui/listing/listing_detail_screen.dart';
import 'ui/notifications/notifications_screen.dart';
import 'ui/orders/order_screen.dart';
import 'ui/sell/sell_screen.dart';
import 'ui/trending/trending_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routing with guards:
/// * Authentication: signed-out users can only see /login and /register.
/// * Authorization: /admin is only reachable for users with role "admin".
///   (Firestore security rules enforce the same thing on the server.)
/// The 4 tabs live in a StatefulShellRoute; everything else is full screen.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(currentUserProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;

      final user = auth.value;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/register';
      // Terms / privacy can be read before signing in (linked from register).
      if (loc.startsWith('/legal/')) return null;

      if (user == null) return onAuthPage ? null : '/login';
      // Email/password accounts must verify their email first.
      if (needsEmailVerification(user)) return loc == '/verify-email' ? null : '/verify-email';
      if (onAuthPage || loc == '/' || loc == '/verify-email') return '/home';

      if (loc.startsWith('/admin')) {
        final user = ref.read(currentUserProvider).value;
        if (user == null || !user.isAdmin) return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/home'),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/trending', builder: (_, _) => const TrendingScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/bids', builder: (_, _) => const YourBidsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (_, _) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'listings',
                    builder: (_, state) => MyListingsScreen(
                      initial: ListingStatus.parse(state.uri.queryParameters['filter'] ?? 'active'),
                    ),
                  ),
                  GoRoute(
                    path: 'orders',
                    builder: (_, state) =>
                        OrdersListScreen(toShip: state.uri.queryParameters['mode'] == 'ship'),
                  ),
                  GoRoute(path: 'payout', builder: (_, _) => const PayoutScreen()),
                  GoRoute(
                    path: 'notifications',
                    builder: (_, _) => const NotificationSettingsScreen(),
                  ),
                  GoRoute(path: 'help', builder: (_, _) => const HelpScreen()),
                  GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/verify-email', builder: (_, _) => const VerifyEmailScreen()),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => LegalScreen(doc: LegalDoc.parse(state.pathParameters['doc'])),
      ),
      GoRoute(path: '/sell', builder: (_, _) => const SellScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) => ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout/:orderId',
        builder: (_, state) => CheckoutScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (_, state) => OrderScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, state) =>
            AddressesScreen(selectMode: state.uri.queryParameters['select'] == '1'),
      ),
      GoRoute(
        path: '/addresses/edit',
        builder: (_, state) => AddressFormScreen(address: state.extra as Address?),
      ),
    ],
  );
});
