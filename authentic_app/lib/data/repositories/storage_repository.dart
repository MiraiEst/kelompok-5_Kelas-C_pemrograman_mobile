import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../services/image_compressor.dart';

/// Photo uploads to Supabase Storage (public bucket, see supabase/storage.sql).
/// Only the files live in Supabase: the returned public URL is saved in
/// Firestore like before. Uses the Storage REST API directly.
class StorageRepository {
  StorageRepository(this._client);

  final http.Client _client;
  static final _url = AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '');
  static const _anonKey = AppConfig.supabaseAnonKey;
  static const _bucket = AppConfig.supabaseBucket;

  /// Compresses and uploads `listings/{uid}/{listingId}/{index}.jpg`.
  /// [onProgress] gets 0..1. Returns the public URL.
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
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'Photo upload is not configured: run with '
        '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... (see README).',
      );
    }
    onProgress?.call(0);
    final bytes = await compressPhoto(raw);
    onProgress?.call(0.3);
    final res = await _client.post(
      Uri.parse('$_url/storage/v1/object/$_bucket/$path'),
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'image/jpeg',
        'x-upsert': 'true', // re-uploading a photo (e.g. new avatar) replaces it
      },
      body: bytes,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw http.ClientException('Upload failed (${res.statusCode}): ${_message(res)}');
    }
    onProgress?.call(1);
    // The version query makes cached images refresh when a file is replaced.
    final version = DateTime.now().millisecondsSinceEpoch;
    return '$_url/storage/v1/object/public/$_bucket/$path?v=$version';
  }

  static String _message(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map) return '${body['message'] ?? body['error'] ?? res.body}';
    } catch (_) {}
    return res.body;
  }
}
