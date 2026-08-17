import 'package:equatable/equatable.dart';

/// Everything that can go wrong, expressed in terms the domain and the UI can
/// both understand.
///
/// No `DioException`, `FirebaseException`, or any other package type ever
/// leaves `data/` — repositories map to one of these at the boundary. The
/// [message] is user-facing: a widget can render it without translating
/// anything first.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// The request never reached the server: no connection, DNS problem, timeout.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Check your network and try again.']);
}

/// The server answered, but not with a success.
final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Signing in, signing up, or a permission problem.
final class AuthFailure extends Failure {
  /// The provider's own code (e.g. `wrong-password`), kept for logging. The UI
  /// should read [message], not this.
  final String? code;

  const AuthFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Local storage could not be read or written.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read locally stored data.']);
}

/// Nothing more specific applies.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
