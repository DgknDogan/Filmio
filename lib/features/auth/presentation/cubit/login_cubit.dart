import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../../../injection_container.dart';
import '../../domain/usecase/login.dart';

part '../states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  LoginCubit(this._loginUseCase)
      : super(
          LoginState(
            isChecked: false,
            isRemembered: false,
          ),
        );

  Future<bool> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }
    final loginState = await _loginUseCase.call(params: LoginParams(email: email, password: password));
    if (state.isChecked) {
      await getIt<SharedPreferences>().setBool("is_remembered", true);
      await getIt<SharedPreferences>().setString("email", email);
      await getIt<SharedPreferences>().setString("password", password);
    }
    if (loginState is FirebaseSuccess) {
      if (loginState.data!.user != null) {
        return true;
      }
    } else if (loginState is FirebaseError) {
      return false;
    }
    return false;
  }

  void changeCheckBox(bool value) {
    emit(state.copyWith(isChecked: value));
  }

  void isAccountRemembered({
    required String? email,
    required String? password,
  }) {
    if (email != null && password != null) {
      emit(state.copyWith(isRemembered: true));
    }
  }
}
