import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, void> {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);
  @override
  Future<void> call({void params}) {
    return _authRepository.logout();
  }
}
