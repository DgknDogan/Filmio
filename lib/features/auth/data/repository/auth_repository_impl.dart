import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/resources/firebase_state.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final _auth = FirebaseAuth.instance;
  @override
  Future<FirebaseState<UserCredential>> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return FirebaseSuccess(data: userCredential);
    } on FirebaseAuthException catch (e) {
      return FirebaseError(error: e);
    }
  }

  @override
  Future<FirebaseState<UserCredential>> register({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseFirestore.instance.getUserDocRef().set(
        {
          "liked_movies": [],
        },
      );
      return FirebaseSuccess(data: userCredential);
    } on FirebaseAuthException catch (e) {
      return FirebaseError(error: e);
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
