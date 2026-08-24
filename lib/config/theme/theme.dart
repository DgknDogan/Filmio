import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Both themes come from one function, so a component cannot be styled in one
/// brightness and forgotten in the other.
ThemeData _themeOf(AppPalette palette, Brightness brightness) {
  final styles = AppTextStyles(palette);

  /// One field outline, recoloured per state. The system draws a field as a
  /// filled surface with a hairline edge, and focus recolours that edge
  /// rather than thickening it — so the box never changes size.
  OutlineInputBorder fieldBorder(Color color) => OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: color),
      );

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.surface,
    textTheme: textThemeOf(palette),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      unselectedItemColor: palette.textSecondary,
      selectedItemColor: palette.accent,
      backgroundColor: palette.surfaceRaised,
    ),
    // The primary action is an accent outline over a wash of the same colour,
    // never a solid fill. That is the system's rule, and it is what keeps the
    // accent reading as an accent instead of as a slab.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(styles.buttonLabel),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? palette.onButton.withValues(alpha: 0.45) : palette.onButton,
        ),
        // Pressed deepens the wash; disabled drops to 45% of it. Neither
        // swaps the colour for a grey.
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return palette.buttonBorder.withValues(alpha: 0.22);
          if (states.contains(WidgetState.disabled)) return palette.buttonBackground.withValues(alpha: 0.45);
          return palette.buttonBackground;
        }),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled) ? palette.buttonBorder.withValues(alpha: 0.45) : palette.buttonBorder,
          ),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.smAll)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.lg)),
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(50.h)),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    // The secondary action: the same shape as the primary with a neutral edge
    // and no wash, so the two never compete.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(styles.buttonLabel),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? palette.textPrimary.withValues(alpha: 0.45) : palette.textPrimary,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed) ? palette.textPrimary.withValues(alpha: 0.07) : null,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: palette.controlBorder)),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.smAll)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.lg)),
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(48.h)),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(styles.link),
        foregroundColor: WidgetStatePropertyAll(palette.accent),
        // minimumSize: WidgetStatePropertyAll(Size(0, 48.h)),
        // padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.smAll)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    // A field is a filled surface with a hairline edge, and its name sits
    // above it rather than inside it — so there is no floating label here.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceMuted,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      hintStyle: styles.inputLabel,
      errorStyle: styles.error,
      prefixIconConstraints: BoxConstraints(minWidth: AppSpacing.xxl),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.error)) return palette.danger;
        return palette.textSecondary;
      }),
      suffixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused) ? palette.accent : palette.textSecondary,
      ),
      border: fieldBorder(palette.controlBorder),
      enabledBorder: fieldBorder(palette.controlBorder),
      focusedBorder: fieldBorder(palette.focusRing),
      errorBorder: fieldBorder(palette.danger),
      focusedErrorBorder: fieldBorder(palette.danger),
      disabledBorder: fieldBorder(palette.inputBorder),
    ),
    // Every modal in the app is a sheet: the same ground as the details
    // sheet, the same sweep at the top, and a grabber instead of a shadow.
    // Anything that would have been a stock Material dialog goes through
    // `AppSheet` and lands here.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.sheet,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: palette.overlayScrim,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: palette.controlBorder,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: palette.snackBarBackground,
      contentTextStyle: styles.snackBar,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      insetPadding: EdgeInsets.all(AppSpacing.lg),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
      backgroundColor: palette.appBar,
      // The title sits on [appBar], not on the page, so it takes the on-image
      // colour. It used to take `heading`, which is the same indigo as the
      // bar itself in light — 2.2:1, effectively invisible.
      titleTextStyle: styles.appBarTitle,
      iconTheme: IconThemeData(color: palette.onImage),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(fontSize: 16.sp, color: palette.textPrimary),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(palette.surfaceMuted),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.mdAll)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        iconColor: palette.textPrimary,
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      // Was shrink-wrapped with a -4 density, which left a ~24pt target. The
      // padded size is what gets it to the 48pt floor.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
      side: BorderSide(color: palette.controlBorder, width: 1.5),
      // The tick is cut out of the accent in the page's own ground colour.
      checkColor: WidgetStatePropertyAll(palette.surface),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.accent : Colors.transparent,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.textPrimary),
  );
}

final lightTheme = _themeOf(AppPalette.light, Brightness.light);
final darkTheme = _themeOf(AppPalette.dark, Brightness.dark);
