import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Answers the only question the splash screen has: can we go straight to the
/// app, or does the user have to sign in?
///
/// A session is restored when the user asked to be remembered *and* Firebase
/// still holds a signed-in user. No credential is replayed.
///
/// A guest session restores on its own: there is no account to verify, and
/// sending somebody back to the sign-in screen they deliberately walked past
/// would be a strange thing to do on every launch.
class RestoreSessionUseCase extends UseCase<bool, void> {
  final AuthRepository _authRepository;

  RestoreSessionUseCase(this._authRepository);

  @override
  Future<bool> call({void params}) async {
    if (_authRepository.isGuest) return true;

    return _authRepository.isRemembered && _authRepository.hasActiveSession;
  }
}
