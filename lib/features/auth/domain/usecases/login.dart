import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  final bool rememberMe;

  LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class LoginUseCase extends UseCase<Either<Failure, Unit>, LoginParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Either<Failure, Unit>> call({LoginParams? params}) async {
    return await _authRepository.login(
      email: params!.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}
