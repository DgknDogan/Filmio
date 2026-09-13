import 'package:filmio/core/custom/numeric_transition_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pumpText(WidgetTester tester, String text) {
    return tester.pumpApp(Scaffold(body: Center(child: NumericTransitionText(text))));
  }

  /// Changes the text from [from] to [to] and runs the roll for [elapsed].
  Future<void> rollFor(WidgetTester tester, {required String from, required String to, required Duration elapsed}) async {
    await pumpText(tester, from);
    await pumpText(tester, to);
    // The first frame starts the roll; the second is [elapsed] into it.
    await tester.pump();
    await tester.pump(elapsed);
  }

  double top(WidgetTester tester, String character) => tester.getTopLeft(find.text(character)).dy;

  testWidgets('is plain text at rest', (tester) async {
    await pumpText(tester, 'Drama');

    expect(find.text('Drama'), findsOneWidget);
  });

  testWidgets('rolls a character at a time and settles on the new text', (tester) async {
    await rollFor(tester, from: 'Drama', to: 'Action', elapsed: const Duration(milliseconds: 100));

    // Mid-roll it is drawn character by character, the old and the new.
    expect(find.text('Action'), findsNothing);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('D'), findsNothing);
  });

  testWidgets('rolls upward: the new character rises from below as the old one leaves above', (tester) async {
    await rollFor(tester, from: 'Drama', to: 'Action', elapsed: const Duration(milliseconds: 100));

    expect(top(tester, 'A'), greaterThan(top(tester, 'D')));
  });

  testWidgets('rolls one character after another, from the start of the text', (tester) async {
    // Five characters in, the last rolling one has not set off yet while the
    // first is well on its way.
    await rollFor(tester, from: 'Drama', to: 'Action', elapsed: const Duration(milliseconds: 120));

    expect(top(tester, 'A'), lessThan(top(tester, 'n')));
  });

  testWidgets('leaves the characters that do not change where they are', (tester) async {
    await rollFor(tester, from: '7.8', to: '7.9', elapsed: const Duration(milliseconds: 100));

    // One of each: the 7 and the point are not rolling out and back in.
    expect(find.text('7'), findsOneWidget);
    expect(find.text('.'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('rolls into the width it settles at, spaces included', (tester) async {
    await pumpText(tester, 'An Action');
    final settled = tester.getSize(find.byType(NumericTransitionText)).width;

    // Nine characters, all rolling: 350 ms each, 200 ms of stagger across
    // them. A few milliseconds before the end, the text is its new width.
    await rollFor(tester, from: 'The Drama', to: 'An Action', elapsed: const Duration(milliseconds: 545));
    expect(find.text('An Action'), findsNothing);
    expect(tester.getSize(find.byType(NumericTransitionText)).width, closeTo(settled, 1));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(NumericTransitionText)).width, settled);
  });

  testWidgets('breaks lines between words while it rolls, as it does at rest', (tester) async {
    Future<void> pumpNarrow(String text) => tester.pumpApp(
          Scaffold(
            body: Center(
              // Room for one five-letter word a line, but not for a word and
              // the space after it.
              child: SizedBox(width: 55, child: NumericTransitionText(text, style: const TextStyle(fontSize: 10))),
            ),
          ),
        );

    await pumpNarrow('Hello World');
    await pumpNarrow('Hello There');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Rolling without overflowing, with the second word on the second line.
    expect(tester.takeException(), isNull);
    expect(top(tester, 'T'), greaterThan(top(tester, 'H')));
  });

  testWidgets('draws each character where the text at rest will have it, with no gaps between them', (tester) async {
    // A size the test font's square glyphs come out fractional at: measured
    // one by one and rounded up, every character would open a gap. No letter
    // spacing, so a character's advance is exactly its size.
    Future<void> pumpSized(String text) => tester.pumpApp(
          Scaffold(
            body: Center(child: NumericTransitionText(text, style: const TextStyle(fontSize: 10.5, letterSpacing: 0))),
          ),
        );

    await pumpSized('Drama');
    await pumpSized('Action');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final start = tester.getTopLeft(find.text('A')).dx;
    expect(tester.getTopLeft(find.text('n')).dx - start, closeTo(5 * 10.5, 0.01));
  });

  testWidgets('finishes its roll exactly where the text at rest draws each character', (tester) async {
    // A tall line and letter spacing, as the app's styles have: a character
    // placed off its own box rather than its line's baseline, or advanced
    // without the spacing, would jump when the roll hands over to the text.
    const style = TextStyle(fontSize: 10.5, height: 1.5, letterSpacing: 0.7);
    Future<void> pumpStyled(String text) => tester.pumpApp(
          Scaffold(body: Center(child: NumericTransitionText(text, style: style))),
        );

    Rect characterBox(Finder text, int index) {
      final paragraph = tester.renderObject<RenderParagraph>(text);
      final box = paragraph.getBoxesForSelection(TextSelection(baseOffset: index, extentOffset: index + 1)).first.toRect();
      return box.shift(paragraph.localToGlobal(Offset.zero));
    }

    await pumpStyled('Drama');
    await pumpStyled('Action');
    await tester.pump();
    // Six characters rolling: 350 ms each and 125 ms of stagger. This is the
    // last frame before it settles, with every character all but home.
    await tester.pump(const Duration(milliseconds: 474));
    final rolled = [for (final character in 'Action'.characters) characterBox(find.text(character), 0)];

    await tester.pumpAndSettle();
    for (final (index, box) in rolled.indexed) {
      final settled = characterBox(find.text('Action'), index);
      expect(box.left, closeTo(settled.left, 0.05), reason: 'character $index across');
      expect(box.top, closeTo(settled.top, 0.05), reason: 'character $index down');
    }
  });

  testWidgets('grows into the lines a longer text needs rather than jumping to them', (tester) async {
    Future<void> pumpNarrow(String text) => tester.pumpApp(
          Scaffold(
            body: Center(
              child: SizedBox(width: 55, child: NumericTransitionText(text, style: const TextStyle(fontSize: 10))),
            ),
          ),
        );
    double height() => tester.getSize(find.byType(NumericTransitionText)).height;

    await pumpNarrow('Hello');
    final oneLine = height();

    await pumpNarrow('Hello There');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));
    final midway = height();

    await tester.pumpAndSettle();
    final twoLines = height();

    expect(twoLines, greaterThan(oneLine));
    expect(midway, greaterThan(oneLine));
    expect(midway, lessThan(twoLines));
  });

  testWidgets('is announced as its new text while it rolls', (tester) async {
    final semantics = tester.ensureSemantics();

    await rollFor(tester, from: 'Drama', to: 'Action', elapsed: const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel('Action'), findsOneWidget);

    await tester.pumpAndSettle();
    semantics.dispose();
  });
}
