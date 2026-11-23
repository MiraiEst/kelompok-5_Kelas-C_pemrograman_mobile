import 'package:cloud_firestore/cloud_firestore.dart';

/// Public reputation of a user (mirrored by Cloud Functions from users/{uid}).
class PublicProfile {
  const PublicProfile({
    required this.uid,
    required this.maskedName,
    required this.positivePct,
    required this.ratingCount,
    required this.feedbackScore,
    this.memberSince,
  });

  final String uid;
  final String maskedName;
  final int positivePct;
  final int ratingCount;
  final int feedbackScore;
  final DateTime? memberSince;

  /// "98% positive · 124 ratings" or "New seller".
  String summary({String empty = 'New seller'}) =>
      ratingCount == 0 ? empty : '$positivePct% positive · $ratingCount ratings';

  factory PublicProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return PublicProfile(
      uid: doc.id,
      maskedName: d['maskedName'] as String? ?? '***',
      positivePct: (d['positivePct'] as num?)?.toInt() ?? 0,
      ratingCount: (d['ratingCount'] as num?)?.toInt() ?? 0,
      feedbackScore: (d['feedbackScore'] as num?)?.toInt() ?? 0,
      memberSince: (d['memberSince'] as Timestamp?)?.toDate(),
    );
  }
}
