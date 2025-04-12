part of 'theme_cubit.dart';

class ThemeState {
  final ThemeMode? mode;
  final DeviceTheme deviceTheme;
  const ThemeState({
    this.mode,
    required this.deviceTheme,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    DeviceTheme? deviceTheme,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      deviceTheme: deviceTheme ?? this.deviceTheme,
    );
  }
}
