import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses a photo to JPEG, max ~1600px on the long side, quality 80.
/// Falls back to the original bytes where compression isn't available
/// (e.g. some browsers); image_picker already limits the size to 1600px.
Future<Uint8List> compressPhoto(Uint8List bytes, {int maxSide = 1600, int quality = 80}) async {
  try {
    final out = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxSide,
      minHeight: maxSide,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    return out.isEmpty ? bytes : out;
  } catch (e) {
    debugPrint('Image compression unavailable, uploading original: $e');
    return bytes;
  }
}
