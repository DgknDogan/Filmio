import 'package:flutter/material.dart';

import '../../config/l10n/app_localizations.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';

/// Short reads for the things a widget asks the theme for, so no build method
/// repeats `Theme.of(context)`.
extension ContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Colours for the brightness currently in effect. A widget names a slot;
  /// it never asks which brightness it is in.
  AppPalette get palette => Theme.of(this).brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;

  /// Styles that carry meaning rather than a place in the type scale.
  AppTextStyles get styles => AppTextStyles(palette);

  /// Every user-facing string. `nullable-getter: false` in `l10n.yaml` is what
  /// keeps this free of a `!`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
