part of '../cubit/login_cubit.dart';

class LoginState {
  final bool isChecked;
  final bool isRemembered;

  LoginState({
    required this.isChecked,
    required this.isRemembered,
  });

  LoginState copyWith({
    bool? isChecked,
    bool? isRemembered,
  }) {
    return LoginState(
      isChecked: isChecked ?? this.isChecked,
      isRemembered: isRemembered ?? this.isRemembered,
    );
  }
}
