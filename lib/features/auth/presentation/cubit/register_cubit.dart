import 'package:bloc/bloc.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../domain/usecase/register.dart';

part '../states/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;
  RegisterCubit(this._registerUseCase) : super(RegisterState());

  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    final registerState = await _registerUseCase.call(params: RegisterParams(email: email, password: password));

    if (registerState is FirebaseSuccess) {
      if (registerState.data!.user != null) {
        return true;
      }
    } else if (registerState is FirebaseError) {
      return false;
    }
    return false;
  }
}
