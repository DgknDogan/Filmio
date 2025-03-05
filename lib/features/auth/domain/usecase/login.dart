import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase extends UseCase<FirebaseState<UserCredential>, LoginParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);
  @override
  Future<FirebaseState<UserCredential>> call({params}) async {
    return await _authRepository.login(email: params!.email, password: params.password);
  }
}
