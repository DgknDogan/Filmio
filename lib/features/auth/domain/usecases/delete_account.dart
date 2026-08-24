import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Deletes the signed-in account. Takes the password because the repository
/// has to re-authenticate before Firebase will allow it.
class DeleteAccountUseCase extends UseCase<Either<Failure, Unit>, String> {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  @override
  Future<Either<Failure, Unit>> call({String? params}) {
    return _authRepository.deleteAccount(password: params!);
  }
}
