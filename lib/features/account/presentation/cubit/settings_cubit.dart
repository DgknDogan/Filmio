import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../injection_container.dart';
import '../../../auth/domain/usecase/logout.dart';

part '../states/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LogoutUseCase _logoutUseCase;
  SettingsCubit(this._logoutUseCase)
      : super(
          SettingsState(),
        );

  Future<void> logout() async {
    await getIt<SharedPreferences>().remove("is_remembered");
    await getIt<SharedPreferences>().remove("email");
    await getIt<SharedPreferences>().remove("password");
    await _logoutUseCase.call();
  }
}
