import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  RegisterParams({required this.email, required this.password});
}

class RegisterUseCase extends UseCase<Either<Failure, Unit>, RegisterParams> {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<Either<Failure, Unit>> call({RegisterParams? params}) async {
    return await _authRepository.register(email: params!.email, password: params.password);
  }
}
