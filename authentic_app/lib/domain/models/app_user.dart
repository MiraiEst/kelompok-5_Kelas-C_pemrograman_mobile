import 'package:cloud_firestore/cloud_firestore.dart';

/// Advanced Dart: enhanced enum with a field and a static parser.
enum UserRole {
  user('user'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole parse(Object? raw) =>
      values.firstWhere((r) => r.value == raw, orElse: () => UserRole.user);
}

/// Notification categories a user can switch on/off (push and email).
/// Keys match functions/index.js `prefKeyFor()`.
enum NotificationPref {
  outbid('outbid', 'Outbid'),
  endingSoon('endingSoon', 'Ending soon'),
  wonLost('wonLost', 'Won / lost'),
  newBid('newBid', 'New bid on my item'),
  reserveMet('reserveMet', 'Reserve met'),
  orders('orders', 'Orders & shipping'),
  secondChance('secondChance', 'Second chance');

  const NotificationPref(this.key, this.label);
  final String key;
  final String label;
}

typedef PrefChannels = ({bool push, bool email});

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.createdAt,
    this.phone,
    this.photoUrl,
    this.feedbackScore = 0,
    this.positivePct = 0,
    this.ratingCount = 0,
    this.notificationPrefs = const {},
  });

  final String uid;
  final String displayName;
  final String email;
  final UserRole role;
  final DateTime? createdAt;
  final String? phone;
  final String? photoUrl;
  final int feedbackScore;
  final int positivePct;
  final int ratingCount;
  final Map<String, PrefChannels> notificationPrefs;

  bool get isAdmin => role == UserRole.admin;

  /// Push on by default, email off by default.
  PrefChannels prefFor(NotificationPref p) =>
      notificationPrefs[p.key] ?? (push: true, email: false);

  String get ratingSummary =>
      ratingCount == 0 ? 'No ratings yet' : '$positivePct% positive · $ratingCount ratings';

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final prefs = <String, PrefChannels>{};
    final rawPrefs = d['notificationPrefs'];
    if (rawPrefs is Map) {
      for (final MapEntry(:key, :value) in rawPrefs.entries) {
        if (value is Map) {
          prefs['$key'] = (
            push: value['push'] as bool? ?? true,
            email: value['email'] as bool? ?? false,
          );
        }
      }
    }
    int n(String k) => (d[k] as num?)?.toInt() ?? 0;
    return AppUser(
      uid: doc.id,
      displayName: (d['displayName'] as String?) ?? 'User',
      email: (d['email'] as String?) ?? '',
      role: UserRole.parse(d['role']),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      phone: d['phone'] as String?,
      photoUrl: d['photoUrl'] as String?,
      feedbackScore: n('feedbackScore'),
      positivePct: n('positivePct'),
      ratingCount: n('ratingCount'),
      notificationPrefs: prefs,
    );
  }
}
