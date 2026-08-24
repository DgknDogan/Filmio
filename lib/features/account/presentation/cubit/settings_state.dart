part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsIdle extends SettingsState {
  const SettingsIdle();
}

final class SettingsSigningOut extends SettingsState {
  const SettingsSigningOut();
}

final class SettingsSignedOut extends SettingsState {
  const SettingsSignedOut();
}

final class SettingsDeletingAccount extends SettingsState {
  const SettingsDeletingAccount();
}

/// The account and everything stored against it are gone. The screen leaves
/// for the login page on this state; there is nothing signed in to show.
final class SettingsAccountDeleted extends SettingsState {
  const SettingsAccountDeleted();
}

final class SettingsDeleteFailed extends SettingsState {
  final String message;

  const SettingsDeleteFailed(this.message);

  @override
  List<Object?> get props => [message];
}
