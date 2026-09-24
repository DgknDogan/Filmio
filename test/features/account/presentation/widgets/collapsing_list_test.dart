import 'dart:async';

import 'package:filmio/features/account/presentation/widgets/collapsing_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Asserts that a row leaves by folding rather than by disappearing between
/// two frames, and that the empty message waits for it. Says nothing about how
/// far it has folded at any given moment — that is the animation's business.
void main() {
  /// A handle on the list's items, so a test can change them the way a reread
  /// does.
  late StateSetter setItems;
  late List<String> items;

  Future<void> pumpList(WidgetTester tester, List<String> initial) {
    items = initial;

    return tester.pumpApp(
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            setItems = setState;

            return CollapsingList<String>(
              items: items,
              idOf: (item) => item,
              padding: EdgeInsets.zero,
              emptyBuilder: (context) => const Text('Nothing liked yet'),
              itemBuilder: (context, item, index) => SizedBox(height: 80, child: Text(item)),
            );
          },
        ),
      ),
    );
  }

  Future<void> change(WidgetTester tester, List<String> next) async {
    setItems(() => items = next);
    await tester.pump();
  }

  testWidgets('draws the rows it was given', (tester) async {
    await pumpList(tester, ['A', 'B', 'C']);

    expect(find.text('A'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('a row that has gone folds away rather than vanishing', (tester) async {
    await pumpList(tester, ['A', 'B', 'C']);

    await change(tester, ['A', 'C']);

    // Still drawn, part-way through folding — this is the whole point: the
    // rows below rise into the space instead of jumping up in one frame.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('B'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('B'), findsNothing);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('a row that has gone leaves to the left', (tester) async {
    await pumpList(tester, ['A', 'B', 'C']);

    await change(tester, ['A', 'C']);
    await tester.pump(const Duration(milliseconds: 80));

    final leaving = tester.widget<SlideTransition>(find.ancestor(of: find.text('B'), matching: find.byType(SlideTransition)).first);

    expect(leaving.position.value.dx, isNegative);

    await tester.pumpAndSettle();
  });

  testWidgets('several rows going at once all fold away', (tester) async {
    await pumpList(tester, ['A', 'B', 'C', 'D']);

    await change(tester, ['C']);
    await tester.pumpAndSettle();

    expect(find.text('C'), findsOneWidget);
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(find.text('D'), findsNothing);
  });

  testWidgets('the empty message waits for the last row to finish folding', (tester) async {
    await pumpList(tester, ['A']);

    await change(tester, []);
    await tester.pump(const Duration(milliseconds: 100));

    // Replacing the row with the message on the first frame would be the same
    // jump this widget exists to avoid.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Nothing liked yet'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(find.text('Nothing liked yet'), findsOneWidget);
  });

  testWidgets('a list that was empty to begin with says so at once', (tester) async {
    await pumpList(tester, []);

    expect(find.text('Nothing liked yet'), findsOneWidget);
  });

  testWidgets('a row arriving is drawn rather than animated', (tester) async {
    await pumpList(tester, ['A']);

    // Not something closing a details screen produces, so it is not worth an
    // animation — but it must still be drawn correctly.
    await change(tester, ['A', 'B']);
    await tester.pumpAndSettle();

    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('a reread that changes nothing leaves the rows alone', (tester) async {
    await pumpList(tester, ['A', 'B']);

    await change(tester, ['A', 'B']);
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('waits for the screen above to close before folding anything', (tester) async {
    await pumpList(tester, ['A', 'B', 'C']);

    // A title's own screen, opened from a row.
    final navigator = Navigator.of(tester.element(find.text('A')));
    unawaited(navigator.push(MaterialPageRoute<void>(builder: (context) => const Scaffold(body: Text('Details')))));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);

    // Closing it hands control back as the pop begins, not when it ends — so
    // this is the reread arriving under a poster still flying home.
    navigator.pop();
    await change(tester, ['A', 'C']);
    await tester.pump(CollapsingList.collapse);

    // Long enough for the fold to have finished, had it started at the pop.
    expect(find.text('B'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('B'), findsNothing);
  });
}
