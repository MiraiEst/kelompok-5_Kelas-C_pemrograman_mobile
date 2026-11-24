import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../l10n/l10n.dart';

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
    final created = await ensureProfile(user, name: name.trim(), phone: phone.trim());
    if (!created) {
      // The app's fallback may have created the profile first: fill in the form values.
      await _db.collection('users').doc(user.uid).update({
        'displayName': name.trim(),
        'phone': phone.trim(),
      });
    }
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
    await ensureProfile(cred.user!);
  }

  /// Creates `users/{uid}` if it does not exist yet; never overwrites one.
  /// Also used as a fallback for accounts whose profile is missing (e.g. made
  /// in the Firebase console or by an older app version). Returns true if it
  /// created the profile.
  Future<bool> ensureProfile(User user, {String? name, String? phone}) {
    final ref = _db.collection('users').doc(user.uid);
    return _db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return false;
      var displayName = (name ?? user.displayName ?? '').trim();
      if (displayName.length < 3) displayName = user.email?.split('@').first ?? 'User';
      if (displayName.length < 3) displayName = 'User';
      tx.set(ref, {
        'displayName': displayName,
        'email': user.email ?? '',
        'phone': ?phone,
        'photoUrl': user.photoURL,
        'role': 'user', // security rules forbid creating yourself as admin
        'fcmTokens': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  /// True for accounts that sign in with email + password (vs Google).
  bool get usesPassword =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  /// Firebase only deletes accounts that signed in recently, so confirm the
  /// login again right before deleting. Throws FirebaseAuthException
  /// (e.g. 'wrong-password' / 'invalid-credential') if it fails.
  Future<void> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError(currentL10n.notSignedIn);
    if (usesPassword) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email ?? '', password: password ?? ''),
      );
    } else if (kIsWeb) {
      await user.reauthenticateWithPopup(GoogleAuthProvider());
    } else {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize();
        _googleReady = true;
      }
      final account = await google.authenticate();
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: account.authentication.idToken),
      );
    }
  }

  /// Deletes the Firebase Auth login. Call after the user's data is deleted.
  Future<void> deleteLogin() async {
    await _auth.currentUser?.delete();
    if (!kIsWeb) await GoogleSignIn.instance.signOut().catchError((_) {});
  }

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
    await _auth.signOut();
    // Also forget the Google account so the next Google login shows the
    // account picker. Done after (and without waiting for) the Firebase
    // sign-out: on some phones this call never returns.
    if (!kIsWeb && _googleReady) {
      unawaited(GoogleSignIn.instance.signOut().catchError((_) {}));
    }
  }
}

/// True when the user must verify their email before using the app.
/// Google accounts are already verified by Google.
bool needsEmailVerification(User user) =>
    !user.emailVerified && !user.providerData.any((p) => p.providerId == 'google.com');

/// Friendly messages for Firebase Auth error codes.
String authErrorMessage(Object e) {
  final l = currentL10n;
  return switch (e) {
    FirebaseAuthException(code: 'invalid-email') => l.authInvalidEmail,
    FirebaseAuthException(code: 'user-disabled') => l.authDisabled,
    FirebaseAuthException(code: 'email-already-in-use') => l.authEmailInUse,
    FirebaseAuthException(code: 'weak-password') => l.authWeakPassword,
    FirebaseAuthException(code: 'invalid-credential' || 'wrong-password' || 'user-not-found') =>
      l.authWrongCredentials,
    FirebaseAuthException(code: 'too-many-requests') => l.authTooMany,
    FirebaseAuthException(code: 'network-request-failed') => l.noConnection,
    FirebaseAuthException(code: 'popup-closed-by-user' || 'cancelled-popup-request') =>
      l.authGoogleCancelled,
    GoogleSignInException(code: GoogleSignInExceptionCode.canceled) => l.authGoogleCancelled,
    FirebaseAuthException(:final message) => message ?? l.authFailed,
    _ => l.somethingWrong('$e'),
  };
}
