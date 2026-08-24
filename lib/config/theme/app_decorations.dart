import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Surfaces that appear on more than one screen, so no widget assembles the
/// same `BoxDecoration` twice.
class AppDecorations {
  final AppPalette _palette;

  const AppDecorations(this._palette);

  /// The bloom behind the logo at the top of an auth screen.
  ///
  /// It is a wash, not a banner: no fill, no edge, no clip — the colour is
  /// brightest just off the top of the screen and is gone by two thirds of
  /// the way down, so the page below it is the same ground throughout.
  BoxDecoration get authHero => BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1.28),
          radius: 1.15,
          colors: [_palette.headerGradientStart, _palette.headerGradientEnd],
          stops: const [0, 0.68],
        ),
      );

  /// The bloom behind the account header. Anchored off the top-left rather
  /// than centred, which is what keeps the screen asymmetric.
  BoxDecoration get accountHero => BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.76, -1.2),
          radius: 1.1,
          colors: [_palette.headerGradientStart, _palette.headerGradientEnd],
          stops: const [0, 0.7],
        ),
      );

  /// The pool of colour under the primary action. On a dark ground elevation
  /// is an edge plus ambient light, so this is a wide, soft, offset glow
  /// rather than a stacked shadow.
  BoxDecoration get primaryActionGlow => BoxDecoration(
        borderRadius: AppRadius.smAll,
        boxShadow: [
          BoxShadow(
            color: _palette.buttonGlow.withValues(alpha: 0.55),
            blurRadius: 34,
            spreadRadius: -14,
            offset: const Offset(0, 12),
          ),
        ],
      );

  /// A poster thumbnail: the system's hairline edge, plus enough ambient
  /// darkness under it to lift it off the page.
  BoxDecoration get poster => BoxDecoration(
        borderRadius: AppRadius.mdAll,
        color: _palette.surfaceMuted,
        border: Border.all(color: _palette.inputBorder),
        boxShadow: [
          BoxShadow(
            color: _palette.shadow,
            blurRadius: 22,
            spreadRadius: -12,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// The panel every list row, settings row and stat block is built on:
  /// a filled surface with a hairline edge and no shadow. On a dark ground
  /// elevation is an edge, not a stack of shadows.
  BoxDecoration get panel => BoxDecoration(
        borderRadius: AppRadius.smAll,
        color: _palette.surfaceRaised,
        border: Border.all(color: _palette.inputBorder),
      );

  /// A circular icon button over artwork — the back arrow, the search button.
  BoxDecoration get circleButton => BoxDecoration(
        shape: BoxShape.circle,
        color: _palette.surface.withValues(alpha: 0.7),
        border: Border.all(color: _palette.controlBorder),
      );

  /// The sheet that carries a film's details, curved along its top edge only.
  BoxDecoration get detailSheet => BoxDecoration(
        color: _palette.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border(top: BorderSide(color: _palette.divider)),
      );

  /// The bar at the foot of the tab pages: the page's own ground, near-opaque,
  /// with a hairline where the content passes under it.
  BoxDecoration get navBar => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _palette.surface.withValues(alpha: 0.95),
            _palette.surface,
            _palette.surface,
          ],
        ),
        border: Border(top: BorderSide(color: _palette.divider)),
      );

  /// The scrim over a backdrop, so the text on it stays readable while the
  /// artwork still shows through. It fades to the page's own colour at the
  /// bottom, which is what joins the image to the page.
  ///
  /// The middle stop is [AppPalette.backdropWash] rather than a fixed fraction
  /// of [AppPalette.surface]: the title and its meta line sit in that band, and
  /// how much wash they need to be read through is the one thing about this
  /// gradient that is not the same in both brightnesses.
  BoxDecoration get backdropScrim => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _palette.surface,
            _palette.backdropWash.withValues(alpha: 0.2),
            _palette.surface.withValues(alpha: 0.2),
          ],
          stops: const [0.04, 0.55, 1],
        ),
      );

  /// The ground a top bar takes on as the page climbs under it.
  ///
  /// It is not a bar so much as a scrim: solid down past the row the buttons
  /// sit in — the page has to pass under that, not through it — and thinning
  /// over the tail below, so it meets the artwork without an edge.
  /// [opacity] is how far the bar has arrived — 0 leaves the artwork untouched.
  BoxDecoration topBarScrim(double opacity) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _palette.sheet.withValues(alpha: opacity),
            _palette.sheet.withValues(alpha: opacity),
            _palette.sheet.withValues(alpha: opacity),
          ],
          stops: const [0, 0.78, 1],
        ),
      );
}
