import 'package:filmio/core/custom/featured_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Stands in for the featured block's still layer: the title it shows, and a
/// row of controls wired the way `FeaturedHero` wires its action and arrows.
/// Says nothing about the artwork.
Widget _overlay(FeaturedCarouselControls controls, ValueChanged<int> onDetails) {
  final previous = controls.onPrevious;
  final next = controls.onNext;

  return Align(
    alignment: Alignment.bottomCenter,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('shown ${controls.shown}'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (previous != null) TextButton(onPressed: previous, child: const Text('previous')),
            TextButton(onPressed: () => onDetails(controls.shown), child: const Text('details')),
            if (next != null) TextButton(onPressed: next, child: const Text('next')),
          ],
        ),
      ],
    ),
  );
}

void _ignore(int _) {}

void main() {
  Future<void> pumpCarousel(WidgetTester tester, {required int count, ValueChanged<int> onDetails = _ignore}) {
    return tester.pumpApp(
      Scaffold(
        body: FeaturedCarousel(
          count: count,
          pageBuilder: (context, index) => Center(child: Text('title $index')),
          overlayBuilder: (context, controls) => _overlay(controls, onDetails),
        ),
      ),
    );
  }

  /// Until the pages are at rest and the still layer has caught up with them.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(FeaturedCarousel.followDelay);
    await tester.pumpAndSettle();
  }

  Future<void> step(WidgetTester tester, String arrow) async {
    await tester.tap(find.text(arrow));
    await settle(tester);
  }

  void expectOn(int index) {
    expect(find.text('title $index'), findsOneWidget);
    expect(find.text('shown $index'), findsOneWidget);
  }

  testWidgets('opens on the best-ranked title', (tester) async {
    await pumpCarousel(tester, count: 3);

    expectOn(0);
  });

  testWidgets('steps on past the last title round to the first', (tester) async {
    await pumpCarousel(tester, count: 3);

    await step(tester, 'next');
    expectOn(1);
    await step(tester, 'next');
    expectOn(2);
    await step(tester, 'next');
    expectOn(0);
  });

  testWidgets('steps back from the first title round to the last', (tester) async {
    await pumpCarousel(tester, count: 3);

    await step(tester, 'previous');
    expectOn(2);
  });

  testWidgets('the still layer follows the pages 200 ms after they set off', (tester) async {
    await pumpCarousel(tester, count: 3);

    await tester.tap(find.text('next'));
    await tester.pump();
    await tester.pump(FeaturedCarousel.followDelay - const Duration(milliseconds: 1));
    expect(find.text('shown 0'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('shown 1'), findsOneWidget);

    await settle(tester);
    expectOn(1);
  });

  testWidgets('arrows pressed faster than the pages move go a title each, skipping the ones they pass', (tester) async {
    await pumpCarousel(tester, count: 3);

    await tester.tap(find.text('next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('next'));
    await tester.pump();

    // The first press would have caught the still layer up by now; the second
    // has put that off, so the title it passed through is never shown.
    await tester.pump(const Duration(milliseconds: 190));
    expect(find.text('shown 0'), findsOneWidget);

    await settle(tester);
    expectOn(2);
  });

  testWidgets('swipes as well as stepping, with no end either way', (tester) async {
    await pumpCarousel(tester, count: 3);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await settle(tester);
    expectOn(1);

    // An arrow steps on from wherever a swipe left the pages.
    await step(tester, 'next');
    expectOn(2);

    for (var swipe = 0; swipe < 3; swipe++) {
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await settle(tester);
    }
    expectOn(2);
  });

  testWidgets('keeps the still layer where it is while the titles move under it', (tester) async {
    await pumpCarousel(tester, count: 3);
    final before = tester.getTopLeft(find.text('next'));

    await tester.tap(find.text('next'));
    // The first frame starts the step; the second is part-way through it,
    // with both titles on screen, sliding.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('title 0'), findsOneWidget);
    expect(find.text('title 1'), findsOneWidget);

    // One set of controls, exactly where it was — not one sliding out while
    // another slides in.
    expect(find.text('next'), findsOneWidget);
    expect(tester.getTopLeft(find.text('next')), before);

    await settle(tester);
    expect(tester.getTopLeft(find.text('next')), before);
  });

  testWidgets('tells the still layer which title it is showing', (tester) async {
    final opened = <int>[];
    await pumpCarousel(tester, count: 3, onDetails: opened.add);

    await tester.tap(find.text('details'));
    await step(tester, 'previous');
    await tester.tap(find.text('details'));
    await step(tester, 'next');
    await step(tester, 'next');
    await tester.tap(find.text('details'));

    expect(opened, [0, 2, 1]);
  });

  testWidgets('draws a single title on its own, with nothing to step to', (tester) async {
    final opened = <int>[];
    await pumpCarousel(tester, count: 1, onDetails: opened.add);

    expectOn(0);
    expect(find.byType(PageView), findsNothing);
    expect(find.text('next'), findsNothing);
    expect(find.text('previous'), findsNothing);

    await tester.tap(find.text('details'));
    expect(opened, [0]);
  });

  testWidgets('starts over at the first title when the number of titles changes', (tester) async {
    await pumpCarousel(tester, count: 3);
    await step(tester, 'next');
    expectOn(1);

    await pumpCarousel(tester, count: 2);
    await settle(tester);
    expectOn(0);

    // And it still steps, on the controller that replaced the old one.
    await step(tester, 'next');
    expectOn(1);
  });
}
