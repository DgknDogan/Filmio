import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Answers the only question the splash screen has: can we go straight to the
/// app, or does the user have to sign in?
///
/// A session is restored when the user asked to be remembered *and* Firebase
/// still holds a signed-in user. No credential is replayed.
class RestoreSessionUseCase extends UseCase<bool, void> {
  final AuthRepository _authRepository;

  RestoreSessionUseCase(this._authRepository);

  @override
  Future<bool> call({void params}) async {
    return _authRepository.isRemembered && _authRepository.hasActiveSession;
  }
}
