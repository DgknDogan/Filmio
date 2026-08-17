import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';

abstract class AuthRepository {
  /// Right carries [unit]: the caller only needs to know it worked. The signed
  /// in user lives in Firebase, not in a value passed up through the layers.
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<Either<Failure, Unit>> register({required String email, required String password});

  Future<void> logout();

  /// True when Firebase still holds a signed-in user from a previous launch.
  bool get hasActiveSession;

  /// Whether the user asked to stay signed in.
  bool get isRemembered;

  /// True once the user has picked a display name and avatar.
  bool get hasProfile;

  /// Asset path of the avatar the user picked, if any.
  String? get photoUrl;

  /// The name the user gave during profile setup, and the address they signed
  /// in with. Both read from the session that is already open — the account
  /// screen prints them, nothing else.
  String? get displayName;
  String? get email;

  Future<Either<Failure, Unit>> updateDisplayName(String name);

  Future<Either<Failure, Unit>> updateProfilePhoto(String assetPath);
}
