import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../services/image_compressor.dart';

/// Photo uploads to Firebase Storage (see storage.rules).
class StorageRepository {
  StorageRepository(this._storage);
  final FirebaseStorage _storage;

  /// Compresses and uploads `listings/{uid}/{listingId}/{index}.jpg`.
  /// [onProgress] gets 0..1. Returns the download URL.
  Future<String> uploadListingPhoto({
    required String uid,
    required String listingId,
    required int index,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) => _upload('listings/$uid/$listingId/$index.jpg', bytes, onProgress);

  Future<String> uploadAvatar({required String uid, required Uint8List bytes}) =>
      _upload('users/$uid/avatar.jpg', bytes, null);

  Future<String> uploadCasePhoto({
    required String uid,
    required String caseId,
    required int index,
    required Uint8List bytes,
  }) => _upload('cases/$uid/$caseId/$index.jpg', bytes, null);

  Future<String> _upload(String path, Uint8List raw, void Function(double)? onProgress) async {
    final bytes = await compressPhoto(raw);
    final ref = _storage.ref(path);
    final task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final sub = task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) onProgress?.call(s.bytesTransferred / s.totalBytes);
    });
    try {
      await task;
    } finally {
      await sub.cancel();
    }
    onProgress?.call(1);
    return ref.getDownloadURL();
  }
}
