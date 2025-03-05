import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  RegisterParams({required this.email, required this.password});
}

class RegisterUseCase extends UseCase<FirebaseState<UserCredential>, RegisterParams> {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);
  @override
  Future<FirebaseState<UserCredential>> call({params}) async {
    return await _authRepository.register(email: params!.email, password: params.password);
  }
}
