import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part '../states/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState());

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final createdUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection("User").doc(createdUser.user!.uid).set(
        {
          "liked_movies": [],
        },
      );
      return true;
    } catch (e) {
      log(e.toString());
    }
    return false;
  }
}
