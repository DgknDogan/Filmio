import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._localDataSource, this._auth, this._firestore);

  @override
  bool get hasActiveSession => _auth.currentUser != null;

  @override
  bool get isGuest => _localDataSource.isGuest;

  @override
  Future<void> continueAsGuest() async {
    // Firebase keeps a signed-in user across launches on its own, whether or
    // not the reader asked to be remembered. Without this, somebody who signed
    // in once and then chose to look around as a guest would still be carrying
    // that account underneath: the recommendation service would answer for it,
    // and anything that slipped past the guest checks in the UI would write to
    // it. A guest has no user at all, and that has to be true of Firebase too.
    await _auth.signOut();
    await _localDataSource.clearRemembered();
    await _localDataSource.setGuest(true);
  }

  @override
  Future<void> endGuestSession() => _localDataSource.clearGuest();

  @override
  bool get isRemembered => _localDataSource.isRemembered;

  @override
  bool get hasProfile => _auth.currentUser?.displayName != null;

  @override
  String? get photoUrl => _auth.currentUser?.photoURL;

  @override
  String? get displayName => _auth.currentUser?.displayName;

  @override
  String? get email => _auth.currentUser?.email;

  @override
  Future<Either<Failure, Unit>> updateDisplayName(String name) async {
    try {
      await _auth.currentUser!.updateDisplayName(name);
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfilePhoto(String assetPath) async {
    try {
      await _auth.currentUser!.updatePhotoURL(assetPath);
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        return const Left(AuthFailure('Could not sign you in. Please try again.'));
      }

      await _localDataSource.clearGuest();
      await _localDataSource.setRemembered(rememberMe);
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        return const Left(AuthFailure('Could not create the account. Please try again.'));
      }

      await _localDataSource.clearGuest();
      await _firestore.userDoc(userCredential.user!.uid).set({"liked_movies": []});
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return const Left(AuthFailure('You are not signed in.'));
    }

    try {
      // Proves it is really them, and refreshes the sign-in Firebase requires
      // to be recent before it will delete the account.
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );

      // The document goes first. Once the account is gone the security rules
      // no longer admit its owner, and the data would outlive the account it
      // belongs to — which is the opposite of what deletion promises.
      await _firestore.userDoc(user.uid).delete();
      await user.delete();
      await _localDataSource.clearRemembered();

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearRemembered();
    await _localDataSource.clearGuest();
    await _auth.signOut();
  }
}
