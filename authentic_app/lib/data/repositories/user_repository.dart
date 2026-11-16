import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';

class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  Stream<AppUser?> watchUser(String uid) => _user(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromDoc(s) : null);

  // --- FCM tokens (a user can be logged in on several devices) -------------

  Future<void> addFcmToken(String uid, String token) =>
      _user(uid).update({'fcmTokens': FieldValue.arrayUnion([token])});

  Future<void> removeFcmToken(String uid, String token) =>
      _user(uid).update({'fcmTokens': FieldValue.arrayRemove([token])});

  // --- In-app notifications --------------------------------------------------

  Stream<List<AppNotification>> watchNotifications(String uid) => _user(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((q) => q.docs.map(AppNotification.fromDoc).toList());

  Future<void> markRead(String uid, String notificationId) => _user(uid)
      .collection('notifications')
      .doc(notificationId)
      .update({'read': true});

  Future<void> markAllRead(String uid, List<AppNotification> items) async {
    final batch = _db.batch();
    for (final n in items.where((n) => !n.read)) {
      batch.update(_user(uid).collection('notifications').doc(n.id), {'read': true});
    }
    await batch.commit();
  }

  // --- Watchlist ---------------------------------------------------------------

  Stream<Set<String>> watchWatchlistIds(String uid) => _user(uid)
      .collection('watchlist')
      .snapshots()
      .map((q) => q.docs.map((d) => d.id).toSet());

  /// Adds/removes a listing from the watchlist and keeps the listing's
  /// public watcher count in sync, atomically.
  Future<void> toggleWatch(String uid, Listing listing) {
    final watchRef = _user(uid).collection('watchlist').doc(listing.id);
    final listingRef = _db.collection('listings').doc(listing.id);
    return _db.runTransaction((tx) async {
      final watched = (await tx.get(watchRef)).exists;
      if (watched) {
        tx.delete(watchRef);
        tx.update(listingRef, {'watcherCount': FieldValue.increment(-1)});
      } else {
        tx.set(watchRef, {
          'title': listing.title,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(listingRef, {'watcherCount': FieldValue.increment(1)});
      }
    });
  }
}
