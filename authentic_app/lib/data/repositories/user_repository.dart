import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';
import '../../domain/models/order.dart';
import '../../domain/models/payout_account.dart';
import '../../domain/models/public_profile.dart';

class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  Stream<AppUser?> watchUser(String uid) =>
      _user(uid).snapshots().map((s) => s.exists ? AppUser.fromDoc(s) : null);

  /// Public, read-only seller/buyer reputation (written by Cloud Functions).
  Stream<PublicProfile?> watchPublicProfile(String uid) => _db
      .collection('publicProfiles')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? PublicProfile.fromDoc(s) : null);

  // --- Profile -------------------------------------------------------------------

  Future<void> updateProfile(String uid, {String? displayName, String? phone, String? photoUrl}) =>
      _user(uid).update({'displayName': ?displayName, 'phone': ?phone, 'photoUrl': ?photoUrl});

  Future<void> setNotificationPref(String uid, NotificationPref pref, PrefChannels value) =>
      _user(uid).set({
        'notificationPrefs': {
          pref.key: {'push': value.push, 'email': value.email},
        },
      }, SetOptions(merge: true));

  // --- Payout account (users/{uid}/private/payout, owner + admin only) -------------

  DocumentReference<Map<String, dynamic>> _payout(String uid) =>
      _user(uid).collection('private').doc('payout');

  Stream<PayoutAccount?> watchPayout(String uid) =>
      _payout(uid).snapshots().map((s) => s.exists ? PayoutAccount.fromMap(s.data()!) : null);

  Future<void> savePayout(String uid, PayoutAccount a) => _payout(uid).set(a.toMap());

  // --- FCM tokens (a user can be logged in on several devices) -------------

  Future<void> addFcmToken(String uid, String token) => _user(uid).update({
    'fcmTokens': FieldValue.arrayUnion([token]),
  });

  Future<void> removeFcmToken(String uid, String token) => _user(uid).update({
    'fcmTokens': FieldValue.arrayRemove([token]),
  });

  // --- In-app notifications --------------------------------------------------

  Stream<List<AppNotification>> watchNotifications(String uid) => _user(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((q) => q.docs.map(AppNotification.fromDoc).toList());

  /// Paged list for the Notifications screen (limit grows by 30).
  Stream<List<AppNotification>> watchNotificationsPage(String uid, int limit) => _user(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((q) => q.docs.map(AppNotification.fromDoc).toList());

  Future<void> deleteNotification(String uid, String id) =>
      _user(uid).collection('notifications').doc(id).delete();

  Future<void> markRead(String uid, String notificationId) =>
      _user(uid).collection('notifications').doc(notificationId).update({'read': true});

  Future<void> markAllRead(String uid, List<AppNotification> items) async {
    final batch = _db.batch();
    for (final n in items.where((n) => !n.read)) {
      batch.update(_user(uid).collection('notifications').doc(n.id), {'read': true});
    }
    await batch.commit();
  }

  // --- Addresses (users/{uid}/addresses) -------------------------------------------

  CollectionReference<Map<String, dynamic>> _addresses(String uid) =>
      _user(uid).collection('addresses');

  Stream<List<Address>> watchAddresses(String uid) => _addresses(uid).snapshots().map(
    (q) =>
        q.docs.map(Address.fromDoc).toList()
          ..sort((a, b) => (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0)),
  );

  /// Adds or updates an address. The first address becomes the default.
  Future<String> saveAddress(String uid, Address a, {bool makeDefault = false}) async {
    final col = _addresses(uid);
    final ref = a.id.isEmpty ? col.doc() : col.doc(a.id);
    final isFirst = (await col.limit(1).get()).docs.isEmpty;
    await ref.set({...a.toMap(), 'isDefault': a.isDefault || isFirst});
    if (makeDefault) await setDefaultAddress(uid, ref.id);
    return ref.id;
  }

  Future<void> deleteAddress(String uid, String id) => _addresses(uid).doc(id).delete();

  Future<void> setDefaultAddress(String uid, String id) async {
    final all = await _addresses(uid).get();
    final batch = _db.batch();
    for (final d in all.docs) {
      batch.update(d.reference, {'isDefault': d.id == id});
    }
    await batch.commit();
  }

  // --- Watchlist ---------------------------------------------------------------

  Stream<Set<String>> watchWatchlistIds(String uid) =>
      _user(uid).collection('watchlist').snapshots().map((q) => q.docs.map((d) => d.id).toSet());

  /// Adds/removes a listing from the watchlist and keeps the listing's
  /// public watcher count in sync, atomically.
  Future<void> toggleWatch(String uid, Listing listing) {
    final watchRef = _user(uid).collection('watchlist').doc(listing.id);
    final listingRef = _db.collection('listings').doc(listing.id);
    return _db.runTransaction((tx) async {
      final watched = (await tx.get(watchRef)).exists;
      if (watched) {
        tx.delete(watchRef);
        tx.update(listingRef, {
          'watcherCount': FieldValue.increment(-1),
          'watcherIds': FieldValue.arrayRemove([uid]),
        });
      } else {
        tx.set(watchRef, {'title': listing.title, 'createdAt': FieldValue.serverTimestamp()});
        // watcherIds lets the "ending soon" Cloud Function find watchers.
        tx.update(listingRef, {
          'watcherCount': FieldValue.increment(1),
          'watcherIds': FieldValue.arrayUnion([uid]),
        });
      }
    });
  }
}
