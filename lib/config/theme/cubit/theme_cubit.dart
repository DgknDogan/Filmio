import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/enums/device_theme.dart';
import '../../../injection_container.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(deviceTheme: DeviceTheme.system, mode: ThemeMode.system)) {
    _getTheme();
  }

  void changeTheme(DeviceTheme newTheme) async {
    final sharedPrefs = getIt<SharedPreferences>();

    await sharedPrefs.setString("theme", newTheme.label);

    _getTheme();
  }

  void _getTheme() {
    final sharedPrefs = getIt<SharedPreferences>();

    final themeLabel = sharedPrefs.getString("theme");
    if (themeLabel == null) {
      emit(state.copyWith(mode: ThemeMode.system, deviceTheme: DeviceTheme.system));
      return;
    }
    final theme = DeviceTheme.getEnumByLabel(label: themeLabel);

    switch (theme) {
      case DeviceTheme.light:
        emit(state.copyWith(mode: ThemeMode.light, deviceTheme: DeviceTheme.light));
      case DeviceTheme.dark:
        emit(state.copyWith(mode: ThemeMode.dark, deviceTheme: DeviceTheme.dark));
      case DeviceTheme.system:
        emit(state.copyWith(mode: ThemeMode.system, deviceTheme: DeviceTheme.system));
    }
  }
}
