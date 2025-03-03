import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../injection_container.dart';

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

  Future<bool> login({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (state.isChecked) {
        await getIt<SharedPreferences>().setBool("is_remembered", true);
        await getIt<SharedPreferences>().setString("email", email);
        await getIt<SharedPreferences>().setString("password", password);
      }
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

  void isAccountRemembered({
    required String? email,
    required String? password,
  }) {
    Future.delayed(
      1.seconds,
      () {
        if (email != null && password != null) {
          emit(state.copyWith(isRemembered: true));
        }
      },
    );
  }
}
