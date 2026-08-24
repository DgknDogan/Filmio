import 'package:filmio/core/custom/browse_skeleton.dart';
import 'package:filmio/core/custom/featured_hero.dart';
import 'package:filmio/core/custom/poster_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Asserts that the wait draws the page's structure rather than a spinner —
/// the headings that will be there, and a stand-in where each poster lands.
/// Deliberately says nothing about padding, colours, or font sizes.
void _noop() {}

void main() {
  Future<void> pumpSkeleton(WidgetTester tester) async {
    await tester.pumpApp(
      // The tab is a page body in the app; the bar it carries is a Material one.
      const Scaffold(
        body: BrowseSkeleton(
          searchHeroTag: 'search',
          searchHint: 'Search films',
          onSearch: _noop,
          rowTitles: ['Popular Movies', 'Top Movies'],
        ),
      ),
    );
    // A shimmer never settles, so the frames are pumped by hand.
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('names the rows that are coming instead of leaving the page blank', (tester) async {
    await pumpSkeleton(tester);

    expect(find.text('Popular Movies'), findsOneWidget);
    expect(find.text('Top Movies'), findsOneWidget);
  });

  testWidgets('stands a placeholder where each poster will land', (tester) async {
    await pumpSkeleton(tester);

    // Enough of them to run off the right edge, which is what says the row
    // scrolls. Only the ones on screen are built.
    expect(find.byType(PosterCardSkeleton), findsWidgets);
    // The real cards are not built until there is artwork for them.
    expect(find.byType(PosterCard), findsNothing);
  });

  testWidgets('holds the featured block open at its own height', (tester) async {
    await pumpSkeleton(tester);

    // The block must not resize when the title arrives, or the rows under it
    // would jump.
    final skeleton = tester.getSize(find.byType(FeaturedHeroSkeleton));
    expect(skeleton.height, FeaturedHero.height);
  });

  testWidgets('does not spin', (tester) async {
    await pumpSkeleton(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
