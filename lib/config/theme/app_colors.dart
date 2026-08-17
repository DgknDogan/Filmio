import 'package:flutter/material.dart';

/// Every colour the app uses, named by the job it does rather than by what it
/// looks like. This is the only file in `lib/` allowed to contain a `Color`
/// literal.
///
/// Both brightnesses are built from the same field list, so a new slot has to
/// be given a deliberate value in each — they cannot drift apart.
///
/// The dark set is the Nocturne design system verbatim — a blue-grey ground
/// (#161826), one blurple accent (#9184d9) used as a line and a glow rather
/// than a flood, and the neutral/accent ramps it derives everything else from.
/// The light set is the same roles resolved for a light ground: the accent
/// drops to the ramp step that carries text contrast there (#5d5294), because
/// the blurple itself is a 2:1 grey on white.
class AppPalette {
  /// Scaffold background.
  final Color surface;

  /// Bars and sheets that sit above [surface] — bottom navigation, cards.
  final Color surfaceRaised;

  /// Quiet filled areas: text fields, menus, secondary buttons.
  final Color surfaceMuted;

  /// App bar background.
  final Color appBar;

  /// The brand colour: selected navigation, checked checkboxes.
  final Color accent;

  /// The accent one step lighter than [accent] on a dark ground — the step
  /// the system reserves for icons and kickers that sit on a surface. On a
  /// light ground there is no lighter step to take, so it is the accent.
  final Color accentSoft;

  /// The hairline between a bar and the page it floats over.
  final Color divider;

  /// The sheet that carries a film's details, one step off [surface] so its
  /// edge reads without a border.
  final Color sheet;

  /// Ambient darkness under a raised thing. Heavier on a dark ground, where
  /// there is no lighter page for an edge to read against.
  final Color shadow;

  /// The scrim under a poster's caption. Dark in both brightnesses, because
  /// the artwork it sits on does not change.
  final Color captionScrim;

  /// Genre chips. The first genre takes the accent pair, the rest the neutral
  /// one — which is how the system tells a primary label from a secondary.
  final Color tagAccentBackground;
  final Color onTagAccent;
  final Color tagNeutralBackground;
  final Color onTagNeutral;

  /// The primary action. Nocturne outlines its buttons rather than filling
  /// them: [buttonBackground] is a wash of the accent, [buttonBorder] draws
  /// the edge that actually reads as the button, and [buttonGlow] is the soft
  /// pool of colour underneath it.
  final Color buttonBackground;
  final Color buttonBorder;
  final Color buttonGlow;
  final Color onButton;

  /// Headline text. Brand-coloured in light, plain in dark.
  final Color heading;

  final Color textPrimary;
  final Color textSecondary;

  /// Standalone icons that are not part of a themed component.
  final Color icon;

  final Color cursor;

  /// The bloom behind the logo at the top of an auth screen: a radial wash
  /// from [headerGradientStart] out to [headerGradientEnd], which is the same
  /// hue at zero alpha so it dissolves into the page instead of ending on a
  /// visible edge.
  final Color headerGradientStart;
  final Color headerGradientEnd;

  /// Loading placeholders.
  final Color shimmerBase;
  final Color shimmerHighlight;

  /// Scrim drawn over poster art so text stays readable.
  final Color overlayScrim;

  /// Text and icons that sit directly on poster art or the scrim. Fixed across
  /// brightnesses on purpose — the artwork underneath does not change.
  final Color onImage;

  /// Supporting text on poster art or the auth gradient — the line that reads
  /// as secondary without dropping below the contrast floor.
  final Color onImageMuted;

  /// A liked title.
  final Color favourite;

  /// The rating star.
  final Color rating;

  /// Validation errors.
  final Color danger;

  /// The light card used by the liked-movies list and the search field.
  final Color card;
  final Color onCard;

  /// Behind the profile avatar while it loads.
  final Color avatarBackground;

  /// A message that floats over the page. Deliberately the opposite of
  /// [surface] in light, so it does not vanish into the page behind it.
  final Color snackBarBackground;
  final Color onSnackBar;

  /// The resting outline of a text field. Quiet enough to read as an edge
  /// rather than a rule, in both brightnesses.
  final Color inputBorder;

  /// The outline of the field that currently has focus, and of anything else
  /// that has to say "you are here".
  final Color focusRing;

  const AppPalette({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.appBar,
    required this.accent,
    required this.accentSoft,
    required this.divider,
    required this.sheet,
    required this.shadow,
    required this.captionScrim,
    required this.tagAccentBackground,
    required this.onTagAccent,
    required this.tagNeutralBackground,
    required this.onTagNeutral,
    required this.buttonBackground,
    required this.buttonBorder,
    required this.buttonGlow,
    required this.onButton,
    required this.heading,
    required this.textPrimary,
    required this.textSecondary,
    required this.icon,
    required this.cursor,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.overlayScrim,
    required this.onImage,
    required this.onImageMuted,
    required this.favourite,
    required this.rating,
    required this.danger,
    required this.card,
    required this.onCard,
    required this.avatarBackground,
    required this.snackBarBackground,
    required this.onSnackBar,
    required this.inputBorder,
    required this.focusRing,
  });

  static const light = AppPalette(
    surface: Color(0xffFAFAFA),
    surfaceRaised: Colors.white,
    // The field fill. Near-white with a drawn edge, so the hint clears 4.5:1
    // with [textSecondary] — the old #d3d3d3 left it at 2.9:1.
    surfaceMuted: Color(0xffF4F4F8),
    // Follows the accent rather than the old indigo, which no longer belongs
    // to any ramp in the system.
    appBar: Color(0xff5d5294),
    // Nocturne's blurple is a 2:1 grey on white, so light takes accent-700
    // from the same ramp — the step that carries text there.
    accent: Color(0xff5d5294),
    accentSoft: Color(0xff5d5294),
    divider: Color(0x141B1C24),
    sheet: Colors.white,
    shadow: Color(0x33000000),
    captionScrim: Color(0xf00f1019),
    tagAccentBackground: Color(0xffE7E5FE),
    onTagAccent: Color(0xff3B3470),
    tagNeutralBackground: Color(0xffEDEDF2),
    onTagNeutral: Color(0xff45474F),
    buttonBackground: Color(0x1a5d5294),
    buttonBorder: Color(0xff5d5294),
    buttonGlow: Color(0xff5d5294),
    onButton: Color(0xff4a4177),
    heading: Color(0xff5d5294),
    textPrimary: Color(0xff1B1C24),
    textSecondary: Color(0xff5F6368),
    icon: Color(0xff353839),
    cursor: Color(0xff5d5294),
    // accent-200, fading to nothing.
    headerGradientStart: Color(0xffE7E5FE),
    headerGradientEnd: Color(0x00E7E5FE),
    shimmerBase: Color(0xff757575),
    shimmerHighlight: Color(0xff9e9e9e),
    overlayScrim: Color(0xcc9e9e9e),
    onImage: Colors.white,
    onImageMuted: Color(0xd9ffffff),
    favourite: Colors.amberAccent,
    rating: Colors.amber,
    danger: Color(0xffD32F2F),
    card: Colors.white,
    onCard: Colors.black,
    avatarBackground: Color(0xff2a2a2a),
    snackBarBackground: Color(0xff232532),
    onSnackBar: Color(0xffe9e9ed),
    inputBorder: Color(0xffE0E0E8),
    focusRing: Color(0xff5d5294),
  );

  /// Nocturne, verbatim: `--color-bg`, `--color-surface`, `--color-text`,
  /// `--color-accent` and the ramp steps the system names for each job.
  static const dark = AppPalette(
    surface: Color(0xff161826),
    surfaceRaised: Color(0xff232532),
    surfaceMuted: Color(0xff232532),
    appBar: Color(0xff161826),
    accent: Color(0xff9184d9),
    // accent-400.
    accentSoft: Color(0xffb5abfc),
    divider: Color(0x17e9e9ed),
    sheet: Color(0xff1c1e2b),
    shadow: Color(0xcc000000),
    captionScrim: Color(0xf00f1019),
    // accent-800 / accent-100 and neutral-800 / neutral-100.
    tagAccentBackground: Color(0xff423a6a),
    onTagAccent: Color(0xfff5f4ff),
    tagNeutralBackground: Color(0xff3f424d),
    onTagNeutral: Color(0xfff3f5fe),
    // A wash, not a fill — the system's rule is that the accent carries as a
    // line and a glow, never as a flood.
    buttonBackground: Color(0x1f9184d9),
    buttonBorder: Color(0xff9184d9),
    // accent-700.
    buttonGlow: Color(0xff5d5294),
    // accent-300: the step the system reserves for text on an accent tint.
    onButton: Color(0xffd2cefd),
    heading: Color(0xffe9e9ed),
    textPrimary: Color(0xffe9e9ed),
    // neutral-500.
    textSecondary: Color(0xff9397ab),
    icon: Color(0xffe9e9ed),
    cursor: Color(0xff9184d9),
    // accent-800, fading to nothing.
    headerGradientStart: Color(0xff423a6a),
    headerGradientEnd: Color(0x00423a6a),
    shimmerBase: Color(0xff757575),
    shimmerHighlight: Color(0xff9e9e9e),
    overlayScrim: Color(0xcc9e9e9e),
    onImage: Colors.white,
    onImageMuted: Color(0xd9ffffff),
    favourite: Colors.amberAccent,
    rating: Colors.amber,
    danger: Color(0xffEF5350),
    // Deliberately kept light: the liked-movies card and the search field were
    // white in both brightnesses before the theme existed, and changing that
    // is a design decision, not a refactor.
    card: Colors.white,
    onCard: Colors.black,
    avatarBackground: Color(0xff2a2a2a),
    snackBarBackground: Color(0xff232532),
    onSnackBar: Color(0xffe9e9ed),
    // neutral-800: the hairline the system uses for a field edge.
    inputBorder: Color(0xff3f424d),
    focusRing: Color(0xff9184d9),
  );
}
