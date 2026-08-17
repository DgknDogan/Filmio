import 'package:filmio/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_launcher.dart';

void main() {
  patrolTest('an unauthenticated launch lands on the login screen', ($) async {
    await createApp($);
    await waitPastSplash($);

    // The one thing unit tests cannot check: that DI, the router, the splash
    // cubit and the real Firebase session agree on where a cold start goes.
    expect($(LoginPage).exists, true);
  });
}
