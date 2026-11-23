import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication (Firebase Auth: email + password, and Google).
/// Every new account gets a `users/{uid}` profile with role "user".
/// Admins are promoted manually in the Firebase console (see README).
class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  bool _googleReady = false;

  /// Emits on sign-in/out *and* on profile changes such as a reload after
  /// verifying the email, so the router can react to `emailVerified`.
  Stream<User?> authStateChanges() => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _createProfile(user, name: name.trim(), phone: phone.trim());
    await user.sendEmailVerification();
  }

  /// Google sign-in. Web uses the Firebase popup; Android/iOS use the
  /// google_sign_in package. Creates the profile the first time.
  Future<void> signInWithGoogle() async {
    final UserCredential cred;
    if (kIsWeb) {
      cred = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize();
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    }
    final user = cred.user!;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _createProfile(user, name: user.displayName ?? user.email?.split('@').first ?? 'User');
    }
  }

  Future<void> _createProfile(User user, {required String name, String? phone}) =>
      _db.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': user.email ?? '',
        'phone': ?phone,
        'photoUrl': user.photoURL,
        'role': 'user', // security rules forbid creating yourself as admin
        'fcmTokens': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> resendVerification() async => _auth.currentUser?.sendEmailVerification();

  /// Reloads the user and refreshes the ID token so Firestore rules see the
  /// new `email_verified` claim. Returns true when verified.
  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final fresh = _auth.currentUser;
    if (fresh?.emailVerified ?? false) {
      await fresh!.getIdToken(true);
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    if (!kIsWeb && _googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }
}

/// True when the user must verify their email before using the app.
/// Google accounts are already verified by Google.
bool needsEmailVerification(User user) =>
    !user.emailVerified && !user.providerData.any((p) => p.providerId == 'google.com');

/// Friendly messages for Firebase Auth error codes.
String authErrorMessage(Object e) => switch (e) {
  FirebaseAuthException(code: 'invalid-email') => 'That email address is not valid.',
  FirebaseAuthException(code: 'user-disabled') => 'This account has been disabled.',
  FirebaseAuthException(code: 'email-already-in-use') =>
    'An account already exists for that email.',
  FirebaseAuthException(code: 'weak-password') => 'Use at least 8 characters for the password.',
  FirebaseAuthException(code: 'invalid-credential' || 'wrong-password' || 'user-not-found') =>
    'Wrong email or password.',
  FirebaseAuthException(code: 'too-many-requests') => 'Too many attempts. Try again later.',
  FirebaseAuthException(code: 'popup-closed-by-user' || 'cancelled-popup-request') =>
    'Google sign-in was cancelled.',
  GoogleSignInException(code: GoogleSignInExceptionCode.canceled) =>
    'Google sign-in was cancelled.',
  FirebaseAuthException(:final message) => message ?? 'Authentication failed.',
  _ => 'Something went wrong: $e',
};
