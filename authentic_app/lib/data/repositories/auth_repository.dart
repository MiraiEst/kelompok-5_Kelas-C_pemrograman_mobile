import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication (Firebase Auth, email + password).
/// Every new account gets a `users/{uid}` profile with role "user".
/// Admins are promoted manually in the Firebase console (see README).
class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'displayName': name.trim(),
      'email': email.trim(),
      'role': 'user', // security rules forbid creating yourself as admin
      'fcmTokens': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}

/// Friendly messages for Firebase Auth error codes.
String authErrorMessage(Object e) => switch (e) {
      FirebaseAuthException(code: 'invalid-email') => 'That email address is not valid.',
      FirebaseAuthException(code: 'user-disabled') => 'This account has been disabled.',
      FirebaseAuthException(code: 'email-already-in-use') => 'An account already exists for that email.',
      FirebaseAuthException(code: 'weak-password') => 'Use at least 6 characters for the password.',
      FirebaseAuthException(code: 'invalid-credential' || 'wrong-password' || 'user-not-found') =>
        'Wrong email or password.',
      FirebaseAuthException(code: 'too-many-requests') => 'Too many attempts. Try again later.',
      FirebaseAuthException(:final message) => message ?? 'Authentication failed.',
      _ => 'Something went wrong: $e',
    };
