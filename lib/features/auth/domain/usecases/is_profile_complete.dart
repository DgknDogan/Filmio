import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Whether the signed-in user has already picked a display name and avatar.
///
/// Exists so presentation can branch on it without reaching for
/// `FirebaseAuth.instance.currentUser` itself.
class IsProfileCompleteUseCase extends UseCase<bool, void> {
  final AuthRepository _authRepository;

  IsProfileCompleteUseCase(this._authRepository);

  @override
  Future<bool> call({void params}) async => _authRepository.hasProfile;
}
