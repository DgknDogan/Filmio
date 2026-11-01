import 'package:filmio/config/firebase/firebase_setup.dart';
import 'package:filmio/config/routes/app_router.dart';
import 'package:filmio/core/constants/env.dart';
import 'package:filmio/core/custom/custom_button.dart';
import 'package:filmio/core/enums/app_flavor.dart';
import 'package:filmio/features/auth/presentation/pages/login_page.dart';
import 'package:filmio/features/auth/presentation/widgets/auth_fields.dart';
import 'package:filmio/injection_container.dart';
import 'package:filmio/main.dart';
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
///
/// Firebase comes up through the app's own [initializeFirebase] rather than a
/// second [Firebase.initializeApp] here. That is what puts these tests on the
/// same switch as every other build: a run that names no flavor gets dev, and
/// a run with the emulator define never leaves the machine. Initialising
/// directly with the production options — which is what this used to do — is
/// how a test suite that signs in, likes titles and un-likes them again ends
/// up doing it in the account real people share.
Future<void> createApp(PatrolIntegrationTester $) async {
  assertNotProduction();

  await initializeFirebase();
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

/// Refuses to run the suite against the production project.
///
/// These tests drive a real account through real writes: they sign in, like
/// titles and take the likes back. Pointed at production that is somebody's
/// actual list, and a run that fails halfway leaves it half-changed.
///
/// Called from [createApp], so there is no way to boot the app in a test
/// without going past it. It throws rather than `assert`s because an assert is
/// compiled out of a profile or release build, and a release run is exactly
/// the one nobody is watching.
void assertNotProduction() {
  if (useFirebaseEmulator) return;

  if (currentFlavor == AppFlavor.prod) {
    fail(
      'This suite writes to the account it signs in as, so it does not run against the '
      'production project. Run it against the emulators '
      '(--dart-define=USE_FIREBASE_EMULATOR=true) or the dev project (--flavor dev, or '
      '--dart-define=FLAVOR=dev on iOS).',
    );
  }
}
