part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final DeviceTheme deviceTheme;

  const ThemeState({required this.deviceTheme});

  /// Derived, not stored — a state where [mode] and [deviceTheme] disagree
  /// cannot be constructed.
  ThemeMode get mode => deviceTheme.themeMode;

  @override
  List<Object?> get props => [deviceTheme];
}
