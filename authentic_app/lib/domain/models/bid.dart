import 'package:cloud_firestore/cloud_firestore.dart';

/// One entry of the public bid history.
/// The bidder's hidden maximum is never written to the public bid history.
class Bid {
  const Bid({
    required this.id,
    required this.userId,
    required this.maskedName,
    required this.priceAfter,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String maskedName;

  /// Visible current price right after this bid was processed.
  final int priceAfter;
  final DateTime createdAt;

  factory Bid.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Bid(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      maskedName: d['maskedName'] as String? ?? '***',
      priceAfter: (d['priceAfter'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
