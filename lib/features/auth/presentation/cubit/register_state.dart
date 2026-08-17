part of 'register_cubit.dart';

class RegisterState extends Equatable {
  final bool isSubmitting;

  /// Set when the last attempt failed; null otherwise.
  final String? errorMessage;

  const RegisterState({this.isSubmitting = false, this.errorMessage});

  RegisterState copyWith({bool? isSubmitting, String? errorMessage}) {
    return RegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, errorMessage];
}
