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

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      displayName: (d['displayName'] as String?) ?? 'User',
      email: (d['email'] as String?) ?? '',
      role: UserRole.parse(d['role']),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
