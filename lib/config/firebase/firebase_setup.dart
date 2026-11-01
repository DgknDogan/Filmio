import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/constants/env.dart';
import '../../core/enums/app_flavor.dart';
import '../../firebase_options.dart' as prod;
import '../../firebase_options_dev.dart' as dev;

/// The flavor this build is running as, and with it the project every
/// Firestore read and write in the app lands in.
final currentFlavor = AppFlavor.resolve(buildFlavor: appFlavor, defined: flavorName);

/// The ports in `firebase.json`. Changing one there means changing it here —
/// the emulators bind what that file says, and the app has no way to ask.
const _firestoreEmulatorPort = 8080;
const _authEmulatorPort = 9099;

/// What the app initialises with when it is talking to the emulators.
///
/// The project id is what the emulators file their data under, and the
/// `demo-` prefix is what tells the Firebase tooling there is no cloud
/// project behind it — the same id the rules tests use, so both work on the
/// same data. The rest is the shape [FirebaseOptions] requires; none of it is
/// a credential for anything, and with the redirection below none of it is
/// ever sent anywhere.
const _emulatorOptions = FirebaseOptions(
  apiKey: 'demo-api-key',
  appId: '1:000000000000:android:0000000000000000',
  messagingSenderId: '000000000000',
  projectId: 'demo-filmio',
);

/// Brings up Firebase for the flavor this build carries.
///
/// Call this instead of [Firebase.initializeApp] — it is the only place that
/// decides which project the app is pointed at, and the only place the
/// emulators are wired in.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: _firebaseOptions);

  if (useFirebaseEmulator) {
    final host = _emulatorHost;

    FirebaseFirestore.instance.useFirestoreEmulator(host, _firestoreEmulatorPort);
    await FirebaseAuth.instance.useAuthEmulator(host, _authEmulatorPort);

    debugPrint(
      'Firebase: emulators on $host (Firestore $_firestoreEmulatorPort, Auth $_authEmulatorPort). '
      'No cloud project is being read or written.',
    );
    return;
  }

  // Loud on purpose. A release build that reached here as dev is a build that
  // was handed to testers — or to the stores — pointed at a project with none
  // of their data in it, and the symptom on the device is an account that
  // appears not to exist.
  if (kReleaseMode && currentFlavor == AppFlavor.dev) {
    debugPrint(
      'Firebase: this RELEASE build is pointed at the dev project. '
      'Build with --flavor prod (or --dart-define=FLAVOR=prod on iOS).',
    );
  }
}

/// Which project to initialise against.
///
/// The emulator check comes first because an emulator run has no cloud
/// project to need options for, and that is what lets the emulators be used
/// before a dev project exists at all.
FirebaseOptions get _firebaseOptions {
  if (useFirebaseEmulator) return _emulatorOptions;

  return switch (currentFlavor) {
    AppFlavor.dev => dev.DefaultFirebaseOptions.currentPlatform,
    AppFlavor.prod => prod.DefaultFirebaseOptions.currentPlatform,
  };
}

/// Where the emulators are, from the device's point of view.
///
/// `localhost` on a device means the device itself, which on the Android
/// emulator is not the machine running the emulators: 10.0.2.2 is the address
/// it is given for its host.
String get _emulatorHost {
  if (firebaseEmulatorHost.isNotEmpty) return firebaseEmulatorHost;

  return defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
}
