import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/is_profile_complete.dart';
import '../../domain/usecases/login.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final IsProfileCompleteUseCase _isProfileCompleteUseCase;

  LoginCubit(this._loginUseCase, this._isProfileCompleteUseCase) : super(const LoginState(isChecked: false));

  Future<LoginOutcome> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter your e-mail and password.'));
      return LoginOutcome.failed;
    }

    emit(state.copyWith(isSubmitting: true));

    final result = await _loginUseCase.call(
      params: LoginParams(email: email, password: password, rememberMe: state.isChecked),
    );

    if (isClosed) return LoginOutcome.failed;

    return await result.fold(
      (failure) async {
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
        return LoginOutcome.failed;
      },
      (_) async {
        final hasProfile = await _isProfileCompleteUseCase.call();
        if (!isClosed) emit(state.copyWith(isSubmitting: false));
        return hasProfile ? LoginOutcome.ready : LoginOutcome.needsProfile;
      },
    );
  }

  void changeCheckBox(bool value) {
    emit(state.copyWith(isChecked: value));
  }
}
