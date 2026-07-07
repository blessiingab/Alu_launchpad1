// GENERATED PLACEHOLDER — replace this entire file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// from the project root, after creating a Firebase project at
// https://console.firebase.google.com and enabling Authentication
// (Email/Password) + Firestore. That command overwrites this file with
// real per-platform config (web/android/ios) pulled from your project —
// do not hand-edit values below, they are intentionally invalid.
//
// See README.md "Firebase setup" section for the full walkthrough.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured. '
        'Run `flutterfire configure` from the project root.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this '
          'platform. Run `flutterfire configure` from the project root.',
        );
    }
  }
}
