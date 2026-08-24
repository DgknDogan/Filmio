import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Starts looking around without an account.
class ContinueAsGuestUseCase extends UseCase<void, void> {
  final AuthRepository _authRepository;

  ContinueAsGuestUseCase(this._authRepository);

  @override
  Future<void> call({void params}) => _authRepository.continueAsGuest();
}

/// Ends a guest session — what "create an account" does before it hands over
/// to the sign-in screen.
class EndGuestSessionUseCase extends UseCase<void, void> {
  final AuthRepository _authRepository;

  EndGuestSessionUseCase(this._authRepository);

  @override
  Future<void> call({void params}) => _authRepository.endGuestSession();
}

/// Whether the app is being used without an account.
class IsGuestUseCase extends UseCase<bool, void> {
  final AuthRepository _authRepository;

  IsGuestUseCase(this._authRepository);

  @override
  Future<bool> call({void params}) async => _authRepository.isGuest;
}
