// Firebase configuration for project `imagi-auction-k5c`.
// Regenerate with: flutterfire configure --project=imagi-auction-k5c
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions only configured for web. '
      'Run `flutterfire configure` to add other platforms.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6_LTavFxkFrcVDvB86sLAlDWhqMqe8Yc',
    appId: '1:526772532249:web:58966146f361144e476688',
    messagingSenderId: '526772532249',
    projectId: 'imagi-auction-k5c',
    authDomain: 'imagi-auction-k5c.firebaseapp.com',
    storageBucket: 'imagi-auction-k5c.firebasestorage.app',
  );
}
