import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../../core/enums/device_theme.dart';
import '../../../core/storage/theme_local_datasource.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeLocalDataSource _localDataSource;

  ThemeCubit(ThemeLocalDataSource localDataSource)
      : _localDataSource = localDataSource,
        super(ThemeState(deviceTheme: localDataSource.readTheme()));

  Future<void> changeTheme(DeviceTheme newTheme) async {
    await _localDataSource.writeTheme(newTheme);
    if (!isClosed) emit(ThemeState(deviceTheme: newTheme));
  }
}
