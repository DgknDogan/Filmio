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

  /// Wipes the account and everything stored against it.
  ///
  /// Firebase refuses to delete a user whose sign-in is more than a few
  /// minutes old, so the caller passes the password again and the
  /// implementation re-authenticates before it deletes anything. Doing it this
  /// way also means the person at the keyboard has proved they are the account
  /// holder — deletion is not undoable.
  Future<Either<Failure, Unit>> deleteAccount({required String password});

  /// True when Firebase still holds a signed-in user from a previous launch.
  bool get hasActiveSession;

  /// Whether the app is being used without an account.
  ///
  /// A guest is not an anonymous Firebase user — there is no account, no
  /// document, and nothing written anywhere but this device. It buys the
  /// catalogue, and nothing that needs somewhere to save to.
  bool get isGuest;

  /// Starts looking around without an account.
  Future<void> continueAsGuest();

  /// Ends a guest session, on the way to the sign-in screen.
  Future<void> endGuestSession();

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
