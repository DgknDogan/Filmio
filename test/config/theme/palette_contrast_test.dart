import 'dart:math' as math;

import 'package:filmio/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The WCAG floors, so the numbers in the expectations below say what they are.
const _textFloor = 4.5;
const _largeTextFloor = 3.0;
const _controlFloor = 3.0;

/// Relative luminance, per WCAG 2.1. Straight from the definition rather than
/// from `Color.computeLuminance`, so a change in Flutter's rounding cannot
/// quietly move the floor this file is guarding.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
}

/// [foreground] laid over [background], which is what the eye actually reads
/// when the foreground carries alpha.
Color _over(Color foreground, Color background) => Color.alphaBlend(foreground, background);

double _contrast(Color foreground, Color background) {
  final a = _luminance(_over(foreground, background));
  final b = _luminance(background);
  final (lighter, darker) = a > b ? (a, b) : (b, a);

  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  // Both brightnesses are checked against the same list. A slot that reads in
  // one and not the other is the failure this file exists to catch: the app
  // was drawn dark first, and light inherited white text for grounds that had
  // become white underneath it.
  for (final (name, palette) in [('light', AppPalette.light), ('dark', AppPalette.dark)]) {
    group('$name palette', () {
      test('text clears 4.5:1 on the ground it is drawn on', () {
        expect(_contrast(palette.textPrimary, palette.surface), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.textSecondary, palette.surface), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.heading, palette.surface), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.textPrimary, palette.sheet), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.textSecondary, palette.sheet), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.textPrimary, palette.surfaceRaised), greaterThanOrEqualTo(_textFloor));

        // The hint inside a field, which sits on the fill rather than the page.
        expect(_contrast(palette.textSecondary, palette.surfaceMuted), greaterThanOrEqualTo(_textFloor));

        expect(_contrast(palette.onSnackBar, palette.snackBarBackground), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.onImage, palette.appBar), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.onTagAccent, palette.tagAccentBackground), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.onTagNeutral, palette.tagNeutralBackground), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.danger, palette.surface), greaterThanOrEqualTo(_textFloor));
      });

      test('the button label reads on the wash it sits in', () {
        final wash = _over(palette.buttonBackground, palette.surface);

        expect(_contrast(palette.onButton, wash), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.buttonBorder, palette.surface), greaterThanOrEqualTo(_controlFloor));
      });

      // The bottom of the featured block is the page's own colour — the scrim's
      // first stop is [surface], opaque. Whatever is printed there has to be
      // read off that, which is what white text stopped doing the moment the
      // page underneath it turned white.
      test('the featured block reads where its scrim has resolved to the page', () {
        expect(_contrast(palette.onBackdrop, palette.surface), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.onBackdropMuted, palette.surface), greaterThanOrEqualTo(_textFloor));
        expect(_contrast(palette.accentSoft, palette.surface), greaterThanOrEqualTo(_textFloor));
      });

      // Higher up the block the wash is all there is between the title and the
      // still, so the still is what decides whether the title reads — and the
      // one that works against a brightness is the one at the far end of it: a
      // black frame under a light wash, a white one under a dark wash.
      //
      // Only the title is held here, at the large-text floor it is drawn at.
      // The meta line under it and the kicker over it are small, and holding
      // those to 4.5:1 against an arbitrary photograph is a bar no wash short
      // of opaque clears — they are held on the resolved ground above instead,
      // which is where the block actually puts them.
      test('the backdrop wash carries the title over the artwork', () {
        // What the block's colour filter can hand the scrim: it takes the
        // still down to 80% brightness before any of this.
        const brightest = Color(0xffCCCCCC);
        const darkest = Color(0xff000000);
        final worst = _luminance(palette.surface) > 0.5 ? darkest : brightest;
        final band = _over(palette.backdropWash, worst);

        expect(_contrast(palette.onBackdrop, band), greaterThanOrEqualTo(_largeTextFloor));
      });

      // A control's edge is the only thing saying where the control is, so it
      // is held to the non-text floor rather than left to the hairline.
      test('a control edge clears 3:1 on both grounds it is drawn on', () {
        expect(_contrast(palette.controlBorder, palette.surface), greaterThanOrEqualTo(_controlFloor));
        expect(_contrast(palette.controlBorder, palette.surfaceMuted), greaterThanOrEqualTo(_controlFloor));
        expect(_contrast(palette.focusRing, palette.surfaceMuted), greaterThanOrEqualTo(_controlFloor));
        expect(_contrast(palette.accent, palette.surface), greaterThanOrEqualTo(_controlFloor));
      });

      // A placeholder stands in for a picture that has not arrived. It reads as
      // absence by sitting near the page, not by being the loudest block on it.
      test('a loading placeholder stays quieter than the text on the page', () {
        expect(_contrast(palette.shimmerBase, palette.surface), lessThan(_controlFloor));
        expect(_contrast(palette.shimmerHighlight, palette.surface), lessThan(_controlFloor));
      });
    });
  }
}
