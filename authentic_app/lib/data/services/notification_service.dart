import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/models/app_notification.dart';
import '../../firebase_options.dart';

/// Background/terminated FCM messages. With a `notification` payload the OS
/// shows them automatically; this handler just has to exist and be top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Push notifications: Firebase Cloud Messaging + local notifications.
///
/// * Background / closed app: FCM pushes sent by the Cloud Function appear in
///   the system tray.
/// * Foreground: FCM does not show a banner on Android, so we display it with
///   flutter_local_notifications.
/// * Tapping any notification opens the related screen (listing, checkout,
///   order), whether the app was closed, in the background or open.
class NotificationService {
  final _local = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'auction_alerts',
    'Auction alerts',
    description: 'Outbid, won, sold and new-bid alerts',
    importance: Importance.high,
  );

  Future<void> init({required void Function(String route) onOpen}) async {
    if (_initialized) return;
    _initialized = true;

    // flutter_local_notifications has no web implementation, and FCM on web
    // needs a service worker + VAPID key. Skip push setup in the browser so
    // the rest of the app still runs.
    if (kIsWeb) return;

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.startsWith('/')) onOpen(route);
      },
    );

    final android = _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission(); // Android 13+

    await _messaging.requestPermission(); // iOS + Android 13+
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages -> show as a local notification.
    // Pushes created from our Firestore notification docs carry a
    // `notificationId`; those are already shown by the in-app listener
    // (see NotificationBridge in app.dart), so skip them to avoid doubles.
    // Messages from the Firebase console "Messaging" page are shown here.
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null || m.data.containsKey('notificationId')) return;
      show(
        id: m.messageId.hashCode,
        title: n.title ?? 'Imagi Auction',
        body: n.body ?? '',
        route: _route(m.data),
      );
    });

    // Tapped while app was in background.
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final route = _route(m.data);
      if (route != null) onOpen(route);
    });

    // Tapped while app was terminated.
    final initial = await _messaging.getInitialMessage();
    final initialRoute = initial == null ? null : _route(initial.data);
    if (initialRoute != null) onOpen(initialRoute);
  }

  static String? _route(Map<String, dynamic> data) {
    String? s(String k) => (data[k] as String?)?.isEmpty ?? true ? null : data[k] as String;
    return notificationRoute(
      NotificationType.parse(data['type']),
      listingId: s('listingId'),
      orderId: s('orderId'),
    );
  }

  // getToken/onTokenRefresh are deprecated in favour of register()/onRegistered,
  // but those return a Firebase Installation ID, not an FCM registration token.
  // The Cloud Function sends with sendEachForMulticast({tokens}), which needs
  // real FCM tokens, so we keep the token API until the backend is migrated.
  // ignore: deprecated_member_use
  Future<String?> getToken() async => kIsWeb ? null : _messaging.getToken();
  Stream<String> get onTokenRefresh =>
      // ignore: deprecated_member_use
      kIsWeb ? const Stream.empty() : _messaging.onTokenRefresh;

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? route,
  }) async {
    if (kIsWeb) {
      debugPrint('Notification: $title — $body');
      return;
    }
    await _local.show(
      id: id,
      title: title,
      body: body,
      payload: route,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
