import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/register.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());

  Future<bool> createAccount({required String email, required String password}) async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _registerUseCase.call(params: RegisterParams(email: email, password: password));

    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(state.copyWith(isSubmitting: false));
        return true;
      },
    );
  }
}
