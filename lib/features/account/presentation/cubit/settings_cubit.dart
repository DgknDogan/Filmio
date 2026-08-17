import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/usecases/logout.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LogoutUseCase _logoutUseCase;

  SettingsCubit(this._logoutUseCase) : super(const SettingsIdle());

  /// Signing out clears the remembered flag inside the auth repository — the
  /// cubit has no business knowing where that flag lives.
  Future<void> logout() async {
    emit(const SettingsSigningOut());
    await _logoutUseCase.call();
    if (!isClosed) emit(const SettingsSignedOut());
  }
}
