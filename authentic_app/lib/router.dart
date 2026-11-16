import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/providers.dart';
import 'ui/admin/admin_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/register_screen.dart';
import 'ui/home/home_shell.dart';
import 'ui/listing/listing_detail_screen.dart';
import 'ui/sell/sell_screen.dart';

/// Routing with guards:
/// * Authentication: signed-out users can only see /login and /register.
/// * Authorization: /admin is only reachable for users with role "admin".
///   (Firestore security rules enforce the same thing on the server.)
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(currentUserProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;

      final signedIn = auth.value != null;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/register';

      if (!signedIn) return onAuthPage ? null : '/login';
      if (onAuthPage) return '/';

      if (loc.startsWith('/admin')) {
        final user = ref.read(currentUserProvider).value;
        if (user == null || !user.isAdmin) return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeShell()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/sell', builder: (_, _) => const SellScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) => ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
    ],
  );
});
