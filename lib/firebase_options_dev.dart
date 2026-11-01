// A placeholder standing in for the real FlutterFire output, so the dev
// flavor compiles before the dev project exists.
//
// Generate the real thing over the top of it once `filmio-dev` is created —
// the class and member below are the shape FlutterFire writes, so the
// generated file replaces this one with nothing else to change:
//
//   flutterfire configure \
//     --project=filmio-dev \
//     --out=lib/firebase_options_dev.dart \
//     --android-package-name=com.dogukan.filmio.dev \
//     --ios-bundle-id=com.dogukan.filmio.dev
//
// Until then a dev build that is not using the emulators throws on launch
// with the message below, which is the point: the alternative to a build that
// refuses to start is one that quietly opens the production project.

import 'package:firebase_core/firebase_core.dart';

/// The dev project's options, once there is a dev project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'lib/firebase_options_dev.dart has not been generated yet, so there is no dev '
        'project to open. Either run against the emulators '
        '(--dart-define=USE_FIREBASE_EMULATOR=true), or create filmio-dev and generate '
        'this file — docs/firebase-environments.md has both.',
      );
}
