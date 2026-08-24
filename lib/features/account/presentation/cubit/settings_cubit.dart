import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/usecases/delete_account.dart';
import '../../../auth/domain/usecases/logout.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LogoutUseCase _logoutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  SettingsCubit(this._logoutUseCase, this._deleteAccountUseCase) : super(const SettingsIdle());

  /// Signing out clears the remembered flag inside the auth repository — the
  /// cubit has no business knowing where that flag lives.
  Future<void> logout() async {
    emit(const SettingsSigningOut());
    await _logoutUseCase.call();
    if (!isClosed) emit(const SettingsSignedOut());
  }

  /// Deletes the account for good. The password comes back from the
  /// confirmation dialog because Firebase will not delete a user on a stale
  /// sign-in; the repository re-authenticates with it first.
  ///
  /// A failure returns to [SettingsIdle] after it is announced, so the screen
  /// is usable again — the account is still there, and the user may well want
  /// to try the password once more.
  Future<void> deleteAccount(String password) async {
    emit(const SettingsDeletingAccount());

    final result = await _deleteAccountUseCase.call(params: password);
    if (isClosed) return;

    result.fold(
      (failure) => emit(SettingsDeleteFailed(failure.message)),
      (_) => emit(const SettingsAccountDeleted()),
    );
  }
}
