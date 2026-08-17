import 'package:filmio/core/custom/app_network_image.dart';
import 'package:filmio/core/custom/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Every remote image in the app goes through this widget, so its placeholder
/// is the app's loading behaviour everywhere.
///
/// The *error* path is not covered here: `cached_network_image` resolves
/// through `flutter_cache_manager`, which needs file IO that a widget test does
/// not provide, so a failing URL never reaches `errorWidget` under `flutter
/// test`. Covering it would mean injecting a cache manager into production code
/// purely for the test. The integration test in `integration_test/` is where a
/// real dead URL gets exercised.
void main() {
  testWidgets('shows a shimmer while the image is still loading', (tester) async {
    await tester.pumpApp(
      const SizedBox(width: 100, height: 150, child: AppNetworkImage(url: 'https://example.invalid/a.jpg')),
    );

    expect(find.byType(AppShimmer), findsOneWidget);
  });
}
