import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/models/app_notification.dart';
import 'providers/providers.dart';
import 'router.dart';
import 'ui/theme.dart';

class AuctionApp extends ConsumerStatefulWidget {
  const AuctionApp({super.key});

  @override
  ConsumerState<AuctionApp> createState() => _AuctionAppState();
}

class _AuctionAppState extends ConsumerState<AuctionApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationServiceProvider)
          .init(onOpenListing: (id) => ref.read(routerProvider).push('/listing/$id'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Authentic',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildAppTheme(),
      themeMode: ThemeMode.light,
      builder: (context, child) => NotificationBridge(child: child ?? const SizedBox()),
    );
  }
}

/// Glue between Firebase and push notifications while the app is running:
/// * saves this device's FCM token on the signed-in user's profile
///   (so the Cloud Function knows where to push), and
/// * shows a local notification for every new in-app notification doc
///   (outbid, won, sold…), which also works without Cloud Functions.
class NotificationBridge extends ConsumerStatefulWidget {
  const NotificationBridge({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<NotificationBridge> createState() => _NotificationBridgeState();
}

class _NotificationBridgeState extends ConsumerState<NotificationBridge> {
  final _startedAt = DateTime.now();
  final _shown = <String>{};
  String? _tokenSavedFor;

  Future<void> _registerToken(String uid) async {
    if (_tokenSavedFor == uid) return;
    _tokenSavedFor = uid;
    final service = ref.read(notificationServiceProvider);
    final users = ref.read(userRepositoryProvider);
    try {
      final token = await service.getToken();
      if (token != null) await users.addFcmToken(uid, token);
      service.onTokenRefresh.listen((t) => users.addFcmToken(uid, t));
    } catch (e) {
      debugPrint('FCM token not available: $e'); // e.g. iOS simulator
    }
  }

  void _showNew(List<AppNotification> items) {
    for (final n in items) {
      if (n.read || n.createdAt.isBefore(_startedAt) || !_shown.add(n.id)) continue;
      ref
          .read(notificationServiceProvider)
          .show(id: n.id.hashCode, title: n.title, body: n.body, listingId: n.listingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      final uid = next.value?.uid;
      if (uid != null) _registerToken(uid);
      if (uid == null) _tokenSavedFor = null;
    });
    ref.listen(notificationsProvider, (_, next) {
      final items = next.value;
      if (items != null) _showNew(items);
    });
    return widget.child;
  }
}
