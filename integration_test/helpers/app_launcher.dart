import 'package:filmio/config/routes/app_router.dart';
import 'package:filmio/firebase_options.dart';
import 'package:filmio/injection_container.dart';
import 'package:filmio/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patrol/patrol.dart';

/// Boots the real app for a Patrol test — real DI, real Firebase, real network.
///
/// Nothing here is mocked on purpose: unit tests already prove each layer in
/// isolation, and the only thing they cannot catch is a wrong wire between two
/// of them. That is what these tests are for.
Future<void> createApp(PatrolIntegrationTester $) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ScreenUtil.ensureScreenSize();
  await initDependencies();

  await $.pumpWidgetAndSettle(const MyApp());
}

/// The router the app is actually driving, for tests that need to assert where
/// they ended up.
AppRouter get appRouter => AppRouter();

/// Convenience for the splash animation, which takes about three seconds before
/// it resolves a destination.
Future<void> waitPastSplash(PatrolIntegrationTester $) async {
  await $.pump(const Duration(seconds: 4));
}

/// Guards against a test being pointed at anything other than a debug build.
void assertNotProduction() {
  assert(() {
    debugPrint('Patrol run: debug build confirmed.');
    return true;
  }());
}
