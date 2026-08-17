import 'package:flutter/material.dart' show Icon, Icons, ThemeMode;

enum DeviceTheme {
  light(icon: Icon(Icons.sunny)),
  dark(icon: Icon(Icons.dark_mode)),
  system(icon: Icon(Icons.phone_android_outlined));

  final Icon icon;

  const DeviceTheme({required this.icon});

  ThemeMode get themeMode => switch (this) {
        DeviceTheme.light => ThemeMode.light,
        DeviceTheme.dark => ThemeMode.dark,
        DeviceTheme.system => ThemeMode.system,
      };
}
