// PLACEHOLDER — this file is overwritten when you run:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// See README.md, step 2.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Firebase is not configured yet. Run `flutterfire configure` '
        'in the project folder to generate lib/firebase_options.dart.',
      );
}
