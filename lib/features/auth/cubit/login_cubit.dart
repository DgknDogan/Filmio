import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part '../states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit()
      : super(
          LoginState(
            isChecked: false,
            isRemembered: false,
          ),
        );

  final _auth = FirebaseAuth.instance;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        return true;
      }
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  void changeCheckBox(bool value) {
    emit(state.copyWith(isChecked: value));
  }
}
