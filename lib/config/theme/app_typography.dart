import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The only file allowed to build a `TextStyle` from scratch, and the only one
/// allowed to name a font.
///
/// Every style goes through [_font], so the family is one line: the design
/// system asks for Inter as both `--font-heading` and `--font-body`, and
/// swapping it later means editing that helper and nothing else.
TextStyle _font({
  required double fontSize,
  required Color color,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

TextTheme textThemeOf(AppPalette palette) {
  return TextTheme(
    headlineLarge: _font(fontSize: 24.sp, color: palette.heading, fontWeight: FontWeight.w500),
    headlineMedium: _font(fontSize: 20.sp, color: palette.heading, fontWeight: FontWeight.w500),
    headlineSmall: _font(fontSize: 18.sp, color: palette.heading),
    titleLarge: _font(fontSize: 20.sp, color: palette.textPrimary, fontWeight: FontWeight.w500),
    titleMedium: _font(fontSize: 18.sp, color: palette.textPrimary),
    titleSmall: _font(fontSize: 16.sp, color: palette.textPrimary),
    bodyMedium: _font(fontSize: 15.sp, color: palette.textPrimary),
    bodySmall: _font(fontSize: 13.sp, color: palette.textSecondary, height: 1.4),
    labelLarge: _font(fontSize: 16.sp, color: palette.textPrimary, fontWeight: FontWeight.w600),
  );
}

/// Styles that carry meaning rather than a place in the scale — the ones a
/// widget would otherwise reach for `copyWith` to build.
class AppTextStyles {
  final AppPalette _palette;

  const AppTextStyles(this._palette);

  /// FILMIO, letter-spaced under the mark at the top of an auth screen. The
  /// tracking is the word mark — at this size it is what makes five letters
  /// read as a brand rather than as a heading.
  TextStyle get authBrand => _font(
        fontSize: 20.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: 20.sp * 0.34,
      );

  /// The headline that opens an auth screen — "Welcome back". Medium weight,
  /// not bold: in this system hierarchy is size and space, and a heading is
  /// never taken past 500.
  TextStyle get authTitle => _font(
        fontSize: 27.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 27.sp * -0.025,
        height: 1.15,
      );

  /// The line under it that says what the screen is for.
  TextStyle get authSubtitle => _font(fontSize: 13.sp, color: _palette.textSecondary, height: 1.4);

  /// The prompt that ends an auth screen — "New here?".
  TextStyle get footerPrompt => _font(fontSize: 12.5.sp, color: _palette.textSecondary);

  /// The tappable half of it.
  TextStyle get link => _font(fontSize: 12.5.sp, color: _palette.accent, fontWeight: FontWeight.w500);

  /// The label above a form field: small, tracked out and upper-case, so it
  /// reads as the field's name without competing with its value.
  TextStyle get fieldLabel => _font(
        fontSize: 10.sp,
        color: _palette.textSecondary,
        letterSpacing: 10.sp * 0.14,
      );

  /// The placeholder inside an empty field.
  TextStyle get inputLabel => _font(fontSize: 14.sp, color: _palette.textSecondary);

  /// The text a user types into a field.
  TextStyle get inputText => _font(fontSize: 14.sp, color: _palette.textPrimary);

  /// The label on the primary action.
  TextStyle get buttonLabel => _font(
        fontSize: 14.5.sp,
        color: _palette.onButton,
        fontWeight: FontWeight.w500,
        letterSpacing: 14.5.sp * 0.02,
      );

  /// The word mark where it is a label rather than the subject — over the
  /// featured artwork at the top of a tab.
  TextStyle get brandSmall => _font(
        fontSize: 13.sp,
        color: _palette.onImage,
        fontWeight: FontWeight.w600,
        letterSpacing: 13.sp * 0.3,
      );

  /// The heading of a row of posters — "Popular this week".
  TextStyle get sectionTitle => _font(
        fontSize: 15.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 15.sp * -0.01,
      );

  /// The link at the end of that heading — "ALL".
  TextStyle get sectionAction => _font(
        fontSize: 11.sp,
        color: _palette.accent,
        letterSpacing: 11.sp * 0.1,
      );

  /// The line that introduces a block: "RECOMMENDED FOR YOU", "SYNOPSIS".
  /// [kicker] is the accented one over artwork, [sectionLabel] the quiet one
  /// over a page.
  TextStyle get kicker => _font(
        fontSize: 10.sp,
        color: _palette.accentSoft,
        letterSpacing: 10.sp * 0.16,
      );
  TextStyle get sectionLabel => _font(
        fontSize: 10.sp,
        color: _palette.textSecondary,
        letterSpacing: 10.sp * 0.16,
      );

  /// The title of a film over its own artwork.
  TextStyle get featureTitle => _font(
        fontSize: 32.sp,
        color: _palette.onImage,
        fontWeight: FontWeight.w500,
        letterSpacing: 32.sp * -0.03,
        height: 1.05,
      );

  /// The title of a film on the sheet that carries its details.
  TextStyle get detailTitle => _font(
        fontSize: 26.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 26.sp * -0.03,
        height: 1.08,
      );

  /// A screen's own name — "Liked movies", "Settings".
  TextStyle get screenTitle => _font(
        fontSize: 20.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 20.sp * -0.02,
      );

  /// Year, runtime, certificate — the quiet line under a title.
  TextStyle get meta => _font(fontSize: 11.5.sp, color: _palette.textSecondary);

  /// The same line where it sits on artwork.
  TextStyle get metaOnImage => _font(fontSize: 12.sp, color: _palette.onImageMuted);

  /// A rating, next to its star.
  TextStyle get ratingLarge => _font(
        fontSize: 19.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 19.sp * -0.02,
      );
  TextStyle get ratingSmall => _font(fontSize: 13.sp, color: _palette.textPrimary, fontWeight: FontWeight.w500);

  /// The label inside a genre chip.
  TextStyle get tag => _font(fontSize: 11.sp, color: _palette.onTagNeutral);

  /// The title and the meta line printed over a poster thumbnail.
  TextStyle get posterTitle => _font(
        fontSize: 10.sp,
        color: _palette.onImage,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );
  TextStyle get posterMeta => _font(
        fontSize: 8.sp,
        color: _palette.onImageMuted,
        letterSpacing: 8.sp * 0.08,
      );

  /// The title of a film in a list row.
  TextStyle get rowTitle => _font(
        fontSize: 15.sp,
        color: _palette.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 15.sp * -0.01,
        height: 1.2,
      );

  /// A label under a tab bar icon.
  TextStyle get navLabel => _font(fontSize: 10.sp, color: _palette.textSecondary, letterSpacing: 10.sp * 0.06);

  /// Running text: a synopsis, a description.
  TextStyle get paragraph => _font(fontSize: 13.sp, color: _palette.textSecondary, height: 1.62);

  /// Text drawn on top of poster art, where the palette's own text colours
  /// would disappear.
  TextStyle get onImage => _font(fontSize: 15.sp, color: _palette.onImage);

  /// Text inside the light card used by the liked-movies list.
  TextStyle get onCard => _font(fontSize: 15.sp, color: _palette.onCard);

  /// A validation message under a field.
  TextStyle get error => _font(fontSize: 13.sp, color: _palette.danger);

  /// The title in the app bar, which is drawn on [AppPalette.appBar] rather
  /// than on the page.
  TextStyle get appBarTitle => _font(fontSize: 24.sp, color: _palette.onImage, fontWeight: FontWeight.w600);

  /// The message inside a floating snack bar, which has its own background.
  TextStyle get snackBar => _font(fontSize: 15.sp, color: _palette.onSnackBar);
}
