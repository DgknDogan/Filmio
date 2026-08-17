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

      await _firestore.userDoc(userCredential.user!.uid).set({"liked_movies": []});
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearRemembered();
    await _auth.signOut();
  }
}
