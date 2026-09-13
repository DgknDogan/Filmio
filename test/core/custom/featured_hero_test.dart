import 'package:filmio/core/custom/featured_carousel.dart';
import 'package:filmio/core/custom/featured_hero.dart';
import 'package:filmio/core/custom/poster_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// The block's layers: only the artwork slides; the poster, the kicker and
/// the actions stay put, and the poster and the lines beside it change in
/// place after the artwork has set off.
///
/// The artwork never loads under `flutter test` — its shimmer runs for ever —
/// so frames are pumped by hand rather than settled.
void main() {
  FeaturedTitle title(int index) => FeaturedTitle(
        imageUrl: 'https://example.invalid/backdrop$index.jpg',
        posterUrl: 'https://example.invalid/poster$index.jpg',
        title: 'Title $index',
        rating: 7.0 + index,
        metaParts: ['Genre $index'],
        heroTag: 'featured-$index',
      );

  Future<void> pumpHero(WidgetTester tester, {int count = 3, ValueChanged<int>? onAction}) {
    return tester.pumpApp(
      Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: FeaturedHero(
            titles: [for (var index = 0; index < count; index++) title(index)],
            kicker: 'Recommended',
            actionLabel: 'Details',
            onAction: onAction ?? (_) {},
          ),
        ),
      ),
    );
  }

  /// Long enough for the artwork to slide, the still layer to follow, and
  /// everything it starts to finish — a frame at a time, since an animation
  /// only starts on the frame after whatever set it off.
  Future<void> letItFinish(WidgetTester tester) async {
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  final next = find.byKey(const Key('featuredNext'));

  testWidgets('keeps the poster, the kicker and the actions where they are while the artwork slides', (tester) async {
    await pumpHero(tester);
    Offset at(Finder finder) => tester.getTopLeft(finder);

    final poster = at(find.byType(PosterCard));
    final kicker = at(find.text('RECOMMENDED'));
    final details = at(find.text('Details'));
    final arrow = at(next);

    await tester.tap(next);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    // The artwork is on its way across…
    expect(find.byType(PageView), findsOneWidget);
    // …and nothing else has moved.
    expect(at(find.byType(PosterCard).first), poster);
    expect(at(find.text('RECOMMENDED')), kicker);
    expect(at(find.text('Details')), details);
    expect(at(next), arrow);

    await letItFinish(tester);
    expect(at(find.byType(PosterCard)), poster);
    expect(at(find.text('RECOMMENDED')), kicker);
    expect(at(find.text('Details')), details);
  });

  testWidgets('changes the title in place once the artwork has had its head start', (tester) async {
    await pumpHero(tester);

    await tester.tap(next);
    await tester.pump();
    await tester.pump(FeaturedCarousel.followDelay - const Duration(milliseconds: 1));
    expect(find.text('Title 0'), findsOneWidget);
    expect(find.text('Genre 0'), findsOneWidget);

    await letItFinish(tester);
    expect(find.text('Title 1'), findsOneWidget);
    expect(find.text('Genre 1'), findsOneWidget);
    expect(find.text('8.0'), findsOneWidget);
  });

  testWidgets('cross-fades the poster rather than sliding it', (tester) async {
    await pumpHero(tester);

    await tester.tap(next);
    await tester.pump();
    await tester.pump(FeaturedCarousel.followDelay);
    await tester.pump(const Duration(milliseconds: 150));
    // Mid-fade, the outgoing poster and the incoming one, in the same place.
    expect(find.byType(PosterCard), findsNWidgets(2));
    expect(tester.getTopLeft(find.byType(PosterCard).first), tester.getTopLeft(find.byType(PosterCard).last));

    await letItFinish(tester);
    expect(find.byType(PosterCard), findsOneWidget);
  });

  testWidgets('opens the title it is showing', (tester) async {
    final opened = <int>[];
    await pumpHero(tester, onAction: opened.add);

    await tester.tap(find.text('Details'));
    await tester.tap(next);
    await letItFinish(tester);
    await tester.tap(find.text('Details'));

    expect(opened, [0, 1]);
  });

  testWidgets('a swipe does not change the title — only the arrows do', (tester) async {
    await pumpHero(tester);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await letItFinish(tester);

    expect(find.text('Title 0'), findsOneWidget);
  });

  testWidgets('a single title has the action row to itself', (tester) async {
    await pumpHero(tester, count: 1);

    expect(find.text('Details'), findsOneWidget);
    expect(next, findsNothing);
    expect(find.byKey(const Key('featuredPrevious')), findsNothing);
  });
}
