import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  outbid('outbid'),
  newBid('new_bid'),
  endingSoon('ending_soon'),
  reserveMet('reserve_met'),
  won('won'),
  lost('lost'),
  sold('sold'),
  unsold('unsold'),
  paymentReminder('payment_reminder'),
  paymentReceived('payment_received'),
  shipped('shipped'),
  delivered('delivered'),
  secondChance('second_chance'),
  other('other');

  const NotificationType(this.value);
  final String value;

  static NotificationType parse(Object? raw) =>
      values.firstWhere((t) => t.value == raw, orElse: () => NotificationType.other);
}

/// Where tapping a notification (in-app or push) should go.
String? notificationRoute(NotificationType type, {String? listingId, String? orderId}) {
  final order = orderId ?? listingId; // order id == listing id
  return switch (type) {
    NotificationType.won ||
    NotificationType.paymentReminder when order != null => '/checkout/$order',
    NotificationType.shipped ||
    NotificationType.delivered ||
    NotificationType.paymentReceived when order != null => '/orders/$order',
    _ when listingId != null => '/listing/$listingId',
    _ => null,
  };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.listingId,
    required this.read,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? listingId;
  final String? orderId;
  final bool read;
  final DateTime createdAt;

  String? get route => notificationRoute(type, listingId: listingId, orderId: orderId);

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return AppNotification(
      id: doc.id,
      type: NotificationType.parse(d['type']),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      listingId: d['listingId'] as String?,
      orderId: d['orderId'] as String?,
      read: d['read'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
