import 'dart:math' show max, min;

import 'package:flutter/material.dart';

/// Text that rolls over to its new value when it changes, a character at a
/// time — Flutter's take on SwiftUI's `.contentTransition(.numericText())`, for
/// words as well as numbers.
///
/// Each character that differs from the one it replaces rolls upward: the old
/// one slides up out of its line where it stood and fades, the new one slides
/// up into its line from below where it will stand. Characters that are the
/// same in both stay put, or glide to their new place if the text around them
/// has moved them. The rolling characters set off one after another from the
/// start of the text to the end, [stagger] apart.
///
/// Both texts are laid out exactly as a [Text] in the same place lays them
/// out, and every character is drawn where that layout puts it — so line
/// breaks never change mid-roll, and the last frame of the roll is the text at
/// rest, to the pixel. Between the two, the block runs from the old text's
/// size to the new one's, so a title that needs another line grows into it
/// rather than jumping.
///
/// At rest it is a plain [Text]. The characters are only drawn one by one
/// while they roll. It measures itself against the width it is given, so it
/// cannot sit under a widget that asks for intrinsic sizes mid-roll.
class NumericTransitionText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;

  /// How the text ends when it runs out of room — at rest and while rolling.
  /// Clipped by default, as a [Text] is: an ellipsis with no [maxLines] would
  /// hold the text to a single line.
  final TextOverflow overflow;

  /// How long one character takes to roll.
  final Duration duration;

  /// How long after the character before it each rolling character sets off.
  /// However long the text, the stagger never adds up to more than [duration],
  /// so a long title does not take seconds to settle.
  final Duration stagger;

  final Curve curve;

  const NumericTransitionText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.duration = const Duration(milliseconds: 350),
    this.stagger = const Duration(milliseconds: 25),
    this.curve = Curves.easeInOut,
  });

  @override
  State<NumericTransitionText> createState() => _NumericTransitionTextState();
}

/// Everything a [Text] takes from its surroundings that decides where its
/// characters land. Records compare by value, so a rebuild in the same place
/// reuses the layout worked out against them.
typedef _LayoutInputs = ({
  TextStyle style,
  TextScaler textScaler,
  TextDirection textDirection,
  TextAlign textAlign,
  TextWidthBasis textWidthBasis,
  TextHeightBehavior? textHeightBehavior,
  Locale? locale,
  int? maxLines,
  bool ellipsis,
  double maxWidth,
});

class _NumericTransitionTextState extends State<NumericTransitionText> with SingleTickerProviderStateMixin {
  /// Settled until the text first changes.
  late final AnimationController _roll = AnimationController(vsync: this, value: 1);

  /// What is rolling out and what is rolling in, character by character as
  /// the reader sees them — an accented letter or an emoji is one, not two.
  List<String> _from = const [];

  /// Set in [initState] rather than lazily: at rest nothing reads it, and a
  /// first read inside [didUpdateWidget] would already see the new text.
  late List<String> _to;

  /// Where each character's roll starts and ends, as a share of the whole
  /// roll. Null for a character that is the same in both texts.
  List<Interval?> _intervals = const [];

  _LayoutInputs? _laidOutFor;
  late _Layout _fromLayout;
  late _Layout _toLayout;

  @override
  void initState() {
    super.initState();
    _to = widget.text.characters.toList();
  }

  @override
  void didUpdateWidget(NumericTransitionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text == oldWidget.text) return;

    _from = _to;
    _to = widget.text.characters.toList();
    _laidOutFor = null;
    _plan();
    _roll.forward(from: 0);
  }

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  static String _at(List<String> characters, int index) => index < characters.length ? characters[index] : '';

  /// Works out which characters roll and when each of them sets off.
  void _plan() {
    final length = max(_from.length, _to.length);
    final rolling = [
      for (var index = 0; index < length; index++)
        if (_at(_from, index) != _at(_to, index)) index,
    ];

    final roll = widget.duration.inMicroseconds;
    final spread = rolling.length < 2 ? 0 : min(widget.stagger.inMicroseconds * (rolling.length - 1), roll);
    final total = roll + spread;
    _roll.duration = Duration(microseconds: total);

    final intervals = List<Interval?>.filled(length, null);
    for (final (rank, index) in rolling.indexed) {
      final start = rolling.length < 2 ? 0.0 : spread * rank / (rolling.length - 1) / total;
      intervals[index] = Interval(start, min(1.0, start + roll / total), curve: widget.curve);
    }
    _intervals = intervals;
  }

  /// Lays both texts out the way the [Text] at rest is laid out in the same
  /// place — once per change, not once per frame.
  void _layOut(BuildContext context, double maxWidth) {
    final defaults = DefaultTextStyle.of(context);
    final inputs = (
      style: defaults.style.merge(widget.style),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      textAlign: defaults.textAlign ?? TextAlign.start,
      textWidthBasis: defaults.textWidthBasis,
      textHeightBehavior: defaults.textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: widget.maxLines ?? defaults.maxLines,
      ellipsis: widget.overflow == TextOverflow.ellipsis,
      maxWidth: maxWidth,
    );
    if (inputs == _laidOutFor) return;

    _laidOutFor = inputs;
    _fromLayout = _Layout.of(_from, inputs);
    _toLayout = _Layout.of(_to, inputs);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _roll,
      builder: (context, _) {
        if (!_roll.isAnimating) {
          return Text(widget.text, style: widget.style, maxLines: widget.maxLines, overflow: widget.overflow);
        }

        return Semantics(
          // Announced as what it is becoming, not as a heap of letters.
          label: widget.text,
          child: ExcludeSemantics(
            child: LayoutBuilder(builder: (context, constraints) => _rolling(context, constraints.maxWidth)),
          ),
        );
      },
    );
  }

  Widget _rolling(BuildContext context, double maxWidth) {
    _layOut(context, maxWidth);
    final inputs = _laidOutFor!;
    final overall = widget.curve.transform(_roll.value);

    Widget glyph(String character, Rect box, {double rise = 0, double opacity = 1}) => _Placed(
          character: character,
          box: box,
          rise: rise,
          opacity: opacity,
          style: inputs.style,
          textScaler: inputs.textScaler,
        );

    final glyphs = <Widget>[];
    for (var index = 0; index < _intervals.length; index++) {
      final from = _at(_from, index);
      final to = _at(_to, index);
      final fromBox = _fromLayout.boxAt(index);
      final toBox = _toLayout.boxAt(index);
      final interval = _intervals[index];

      if (interval == null) {
        // The same character in both. Where the text around it has moved it —
        // a longer word before it, a line that now breaks earlier — it glides
        // to its new place with the rest of the reflow.
        if (toBox == null) continue;
        glyphs.add(glyph(to, fromBox == null ? toBox : Rect.lerp(fromBox, toBox, overall)!));
        continue;
      }

      final progress = interval.transform(_roll.value);
      if (fromBox != null) glyphs.add(glyph(from, fromBox, rise: -progress, opacity: 1 - progress));
      if (toBox != null) glyphs.add(glyph(to, toBox, rise: 1 - progress, opacity: progress));
    }

    // The ellipsis of a text cut short is not one of its characters; it goes
    // over with the text as a whole.
    final fromEllipsis = _fromLayout.ellipsis;
    final toEllipsis = _toLayout.ellipsis;
    if (fromEllipsis != null && fromEllipsis == toEllipsis) {
      glyphs.add(glyph(_ellipsis, toEllipsis!));
    } else {
      if (fromEllipsis != null) glyphs.add(glyph(_ellipsis, fromEllipsis, rise: -overall, opacity: 1 - overall));
      if (toEllipsis != null) glyphs.add(glyph(_ellipsis, toEllipsis, rise: 1 - overall, opacity: overall));
    }

    final size = Size.lerp(_fromLayout.size, _toLayout.size, overall)!;

    // Held to its own height as it grows or shrinks: a line on its way in or
    // out does not show below the block before the block has room for it.
    return ClipRect(
      clipper: _LineClipper(slack: size.height),
      child: SizedBox.fromSize(
        size: size,
        child: Stack(clipBehavior: Clip.none, children: glyphs),
      ),
    );
  }
}

const String _ellipsis = '…';

/// A space has nothing to draw, and '' — the old text's tail, where it was
/// the longer — has no place in the new text.
bool _isSpace(String character) => character.isNotEmpty && character.trim().isEmpty;

/// Where a [Text] would draw each character of a text.
class _Layout {
  final Size size;

  /// Where each character's own [Text] goes, by index, so that the character
  /// lands where the whole text draws it. Null for a space, and for a
  /// character the text was cut short before.
  final List<Rect?> _boxes;

  /// Where the ellipsis's own [Text] goes, when the text is cut short.
  final Rect? ellipsis;

  const _Layout._(this.size, this._boxes, this.ellipsis);

  factory _Layout.of(List<String> characters, _LayoutInputs inputs) {
    TextPainter painterFor(String text, {int? maxLines, String? ellipsis}) => TextPainter(
          text: TextSpan(text: text, style: inputs.style, locale: inputs.locale),
          textAlign: inputs.textAlign,
          textDirection: inputs.textDirection,
          textScaler: inputs.textScaler,
          textWidthBasis: inputs.textWidthBasis,
          textHeightBehavior: inputs.textHeightBehavior,
          locale: inputs.locale,
          maxLines: maxLines,
          ellipsis: ellipsis,
        );

    // Each character is drawn by a Text of its own, and within that Text the
    // character does not start at the corner: letter spacing is shared out
    // either side of it, and a tall line puts room above it. Lining its box in
    // its own Text up with its box in the whole text is what lands it exactly
    // where the whole text draws it.
    final own = <String, (Rect, Size)>{};
    Rect place(String character, Rect box) {
      final (ownBox, ownSize) = own.putIfAbsent(character, () {
        final probe = painterFor(character)..layout();
        final boxes = probe.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: character.length));
        final measured = (boxes.isEmpty ? Offset.zero & probe.size : boxes.first.toRect(), probe.size);
        probe.dispose();
        return measured;
      });
      return Offset(box.left - ownBox.left, box.top - ownBox.top) & ownSize;
    }

    final painter = painterFor(
      characters.join(),
      maxLines: inputs.maxLines,
      ellipsis: inputs.ellipsis ? _ellipsis : null,
    )..layout(maxWidth: inputs.maxWidth);

    final boxes = <Rect?>[];
    Rect? last;
    var offset = 0;
    for (final character in characters) {
      final end = offset + character.length;
      Rect? placed;
      if (!_isSpace(character)) {
        final found = painter.getBoxesForSelection(TextSelection(baseOffset: offset, extentOffset: end));
        if (found.isNotEmpty) {
          final box = found.first.toRect();
          placed = place(character, box);
          if (last == null || box.top > last.top || (box.top == last.top && box.right > last.right)) last = box;
        }
      }
      boxes.add(placed);
      offset = end;
    }

    // The ellipsis follows the last character the text had room for.
    final cut = inputs.ellipsis && painter.didExceedMaxLines && last != null;
    final layout = _Layout._(
      painter.size,
      boxes,
      cut ? place(_ellipsis, Rect.fromLTWH(last.right, last.top, 0, last.height)) : null,
    );
    painter.dispose();
    return layout;
  }

  Rect? boxAt(int index) => index < _boxes.length ? _boxes[index] : null;
}

/// One character's own [Text], set where it lines the character up with the
/// whole text, [rise] lines below that — negative on the way out above,
/// positive on the way in from below — and kept to its own line while it is
/// anywhere but home.
class _Placed extends StatelessWidget {
  final String character;
  final Rect box;
  final double rise;
  final double opacity;
  final TextStyle style;
  final TextScaler textScaler;

  const _Placed({
    required this.character,
    required this.box,
    required this.rise,
    required this.opacity,
    required this.style,
    required this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    final glyph = _Glyph(character, style: style, textScaler: textScaler, opacity: opacity);

    return Positioned.fromRect(
      rect: box,
      child: rise == 0
          ? Stack(clipBehavior: Clip.none, children: [Positioned(left: 0, top: 0, child: glyph)])
          : ClipRect(
              clipper: _LineClipper(slack: box.height),
              child: Stack(
                clipBehavior: Clip.none,
                children: [Positioned(left: 0, top: rise * box.height, child: glyph)],
              ),
            ),
    );
  }
}

/// A single character, never wrapped. Faded through its colour rather than
/// through an [Opacity], which would give every rolling character a layer of
/// its own.
class _Glyph extends StatelessWidget {
  final String character;
  final TextStyle style;
  final TextScaler textScaler;
  final double opacity;

  const _Glyph(this.character, {required this.style, required this.textScaler, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    final color = style.color;
    final faded = color == null || opacity >= 1 ? style : style.copyWith(color: color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0)));

    return Text(
      character,
      style: faded,
      textScaler: textScaler,
      softWrap: false,
      overflow: TextOverflow.visible,
    );
  }
}

/// Keeps what it clips to its own height, and only to its height: a glyph may
/// still reach out sideways past the box it stands in, but not up into the
/// line above or down into the one below.
class _LineClipper extends CustomClipper<Rect> {
  /// How far out to either side a glyph may reach.
  final double slack;

  const _LineClipper({required this.slack});

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-slack, 0, size.width + slack, size.height);

  @override
  bool shouldReclip(_LineClipper oldClipper) => oldClipper.slack != slack;
}
