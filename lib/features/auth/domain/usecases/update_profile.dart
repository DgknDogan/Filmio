import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateDisplayNameUseCase extends UseCase<Either<Failure, Unit>, String> {
  final AuthRepository _authRepository;

  UpdateDisplayNameUseCase(this._authRepository);

  @override
  Future<Either<Failure, Unit>> call({String? params}) {
    return _authRepository.updateDisplayName(params!);
  }
}

class UpdateProfilePhotoUseCase extends UseCase<Either<Failure, Unit>, String> {
  final AuthRepository _authRepository;

  UpdateProfilePhotoUseCase(this._authRepository);

  @override
  Future<Either<Failure, Unit>> call({String? params}) {
    return _authRepository.updateProfilePhoto(params!);
  }
}

/// Who is signed in, as the account screen prints it.
typedef Profile = ({String? name, String? email, String? photoUrl});

/// Everything the account header shows, in one read.
class GetProfileUseCase extends UseCase<Profile, void> {
  final AuthRepository _authRepository;

  GetProfileUseCase(this._authRepository);

  @override
  Future<Profile> call({void params}) async => (
        name: _authRepository.displayName,
        email: _authRepository.email,
        photoUrl: _authRepository.photoUrl,
      );
}

/// The avatar the account screen shows. Returns null before one is picked.
class GetProfilePhotoUseCase extends UseCase<String?, void> {
  final AuthRepository _authRepository;

  GetProfilePhotoUseCase(this._authRepository);

  @override
  Future<String?> call({void params}) async => _authRepository.photoUrl;
}
