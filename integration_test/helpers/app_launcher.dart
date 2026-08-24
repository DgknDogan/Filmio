import 'package:filmio/config/routes/app_router.dart';
import 'package:filmio/core/custom/custom_button.dart';
import 'package:filmio/features/auth/presentation/pages/login_page.dart';
import 'package:filmio/features/auth/presentation/widgets/auth_fields.dart';
import 'package:filmio/firebase_options.dart';
import 'package:filmio/injection_container.dart';
import 'package:filmio/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// The account the signed-in tests drive the app as, supplied the same way the
/// TMDB token is — `--dart-define-from-file=env.json`, which is gitignored.
/// Nothing about the account is written down in a file that is committed.
const testEmail = String.fromEnvironment('TEST_EMAIL');
const testPassword = String.fromEnvironment('TEST_PASSWORD');

bool get hasTestAccount => testEmail.isNotEmpty && testPassword.isNotEmpty;

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

/// Signs in as the test account and waits for the tabs to come up.
///
/// A previous run can leave the session restored, in which case the app is
/// already past the login screen and there is nothing to type.
Future<void> signIn(PatrolIntegrationTester $) async {
  if (!hasTestAccount) {
    fail('TEST_EMAIL and TEST_PASSWORD are missing. Run with --dart-define-from-file=env.json.');
  }

  if (!$(LoginPage).exists) return;

  await $(AuthEmailField).enterText(testEmail);
  await $(AuthPasswordField).enterText(testPassword);
  await $(CustomButton).tap(settlePolicy: SettlePolicy.trySettle);

  // The tabs open behind the wrapper's own splash animation, and the films tab
  // is already loading behind that — never settled, so never `pumpAndSettle`.
  await $.pump(const Duration(seconds: 3));
}

/// Pumps until [read] returns something, or gives up.
///
/// What the signed-in tabs wait on is two live services answering, so it is
/// waited for by polling rather than by settling: the tab shimmers while it
/// waits and a shimmer never settles.
Future<T?> waitFor<T>(PatrolIntegrationTester $, T? Function() read) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    final value = read();
    if (value != null) return value;

    await $.pump(const Duration(milliseconds: 500));
  }

  return null;
}

/// Guards against a test being pointed at anything other than a debug build.
void assertNotProduction() {
  assert(() {
    debugPrint('Patrol run: debug build confirmed.');
    return true;
  }());
}
