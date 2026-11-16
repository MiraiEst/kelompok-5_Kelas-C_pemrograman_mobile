import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  outbid('outbid'),
  newBid('new_bid'),
  won('won'),
  lost('lost'),
  sold('sold'),
  unsold('unsold'),
  other('other');

  const NotificationType(this.value);
  final String value;

  static NotificationType parse(Object? raw) =>
      values.firstWhere((t) => t.value == raw, orElse: () => NotificationType.other);
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
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? listingId;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return AppNotification(
      id: doc.id,
      type: NotificationType.parse(d['type']),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      listingId: d['listingId'] as String?,
      read: d['read'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
