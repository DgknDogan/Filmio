part of 'login_cubit.dart';

/// Where a login attempt leaves the user.
enum LoginOutcome {
  /// Credentials rejected, or the request failed. [LoginState.errorMessage]
  /// says why.
  failed,

  /// Signed in, but there is no display name or avatar yet.
  needsProfile,

  /// Signed in and ready for the app.
  ready,
}

class LoginState extends Equatable {
  /// Whether the "Remember Me" checkbox is ticked.
  final bool isChecked;

  final bool isSubmitting;

  /// Set when the last attempt failed; null otherwise.
  final String? errorMessage;

  const LoginState({
    required this.isChecked,
    this.isSubmitting = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isChecked,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return LoginState(
      isChecked: isChecked ?? this.isChecked,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isChecked, isSubmitting, errorMessage];
}
