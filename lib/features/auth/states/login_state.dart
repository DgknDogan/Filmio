part of '../cubit/login_cubit.dart';

class LoginState {
  final bool isChecked;

  LoginState({required this.isChecked});

  LoginState copyWith({bool? isChecked}) {
    return LoginState(isChecked: isChecked ?? this.isChecked);
  }
}
