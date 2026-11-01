import 'package:filmio/core/enums/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavor.resolve', () {
    test('reads the flavor the build was started with', () {
      expect(AppFlavor.resolve(buildFlavor: 'prod'), AppFlavor.prod);
      expect(AppFlavor.resolve(buildFlavor: 'dev'), AppFlavor.dev);
    });

    test('falls back to the define when the build named no flavor', () {
      expect(AppFlavor.resolve(defined: 'prod'), AppFlavor.prod);
      expect(AppFlavor.resolve(buildFlavor: null, defined: 'prod'), AppFlavor.prod);
      expect(AppFlavor.resolve(buildFlavor: '', defined: 'prod'), AppFlavor.prod);
    });

    test('prefers the build flavor, which is what the native config follows', () {
      expect(AppFlavor.resolve(buildFlavor: 'prod', defined: 'dev'), AppFlavor.prod);
      expect(AppFlavor.resolve(buildFlavor: 'dev', defined: 'prod'), AppFlavor.dev);
    });

    test('is dev when nothing says otherwise', () {
      expect(AppFlavor.resolve(), AppFlavor.dev);
      expect(AppFlavor.resolve(buildFlavor: '', defined: ''), AppFlavor.dev);
    });

    test('is dev rather than prod for a name it does not recognise', () {
      expect(AppFlavor.resolve(buildFlavor: 'staging'), AppFlavor.dev);
      expect(AppFlavor.resolve(defined: 'production'), AppFlavor.dev);
      expect(AppFlavor.resolve(buildFlavor: 'PROD'), AppFlavor.dev);
    });
  });

  group('AppFlavor.usesEmulators', () {
    test('does what the build asked for, when it asked', () {
      expect(AppFlavor.usesEmulators(defined: true, flavor: AppFlavor.prod), isTrue);
      expect(AppFlavor.usesEmulators(defined: false, flavor: AppFlavor.dev), isFalse);
    });

    test('a dev build that said nothing gets the emulators', () {
      // There is a cloud dev project only once somebody creates one, so the
      // alternative here is not a dev project but a crash on launch. A plain
      // `flutter run` gets the environment that is always there.
      expect(AppFlavor.usesEmulators(defined: null, flavor: AppFlavor.dev), isTrue);
    });

    test('a prod build that said nothing gets the real project', () {
      // Never the emulators by accident: a release build is this case, and
      // pointing it at a machine that is not there would ship an app that
      // cannot sign anybody in.
      expect(AppFlavor.usesEmulators(defined: null, flavor: AppFlavor.prod), isFalse);
    });
  });
}
