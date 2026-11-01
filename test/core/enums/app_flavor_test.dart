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
}
