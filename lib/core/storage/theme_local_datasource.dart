import 'package:shared_preferences/shared_preferences.dart';

import '../enums/device_theme.dart';

/// The only place the chosen theme is read from or written to disk.
///
/// The stored value is [DeviceTheme.name] — a stable identifier — rather than
/// [DeviceTheme.label], which is display text and will be translated.
class ThemeLocalDataSource {
  static const _themeKey = 'theme';

  /// What earlier builds wrote: the display label, before it became
  /// translatable. Kept so an existing install still reads correctly.
  static const _legacyLabels = {'Light': DeviceTheme.light, 'Dark': DeviceTheme.dark, 'System': DeviceTheme.system};

  final SharedPreferences _preferences;

  const ThemeLocalDataSource(this._preferences);

  /// Falls back to [DeviceTheme.system] for a missing or unrecognised value,
  /// so a bad write can never leave the app unable to pick a theme.
  DeviceTheme readTheme() {
    final stored = _preferences.getString(_themeKey);
    if (stored == null) return DeviceTheme.system;

    return DeviceTheme.values.firstWhere(
      (theme) => theme.name == stored,
      // Reading a legacy label migrates it: the next write stores `name`.
      orElse: () => _legacyLabels[stored] ?? DeviceTheme.system,
    );
  }

  Future<void> writeTheme(DeviceTheme theme) => _preferences.setString(_themeKey, theme.name);
}
