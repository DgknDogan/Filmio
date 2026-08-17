import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'failure.dart';

/// The one place a package exception becomes a [Failure].
///
/// Repositories call these; nothing above `data/` needs to know these types
/// exist.

/// Maps a Dio exception to the failure the user should be told about.
Failure failureFromDio(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout =>
      const NetworkFailure('The server took too long to respond. Try again.'),
    DioExceptionType.connectionError => const NetworkFailure(),
    DioExceptionType.badCertificate => const NetworkFailure('Could not establish a secure connection.'),
    DioExceptionType.cancel => const UnknownFailure('The request was cancelled.'),
    DioExceptionType.badResponse => failureFromStatusCode(exception.response?.statusCode),
    DioExceptionType.unknown => const UnknownFailure(),
  };
}

/// Maps an HTTP status code to a failure. Exposed separately because a
/// repository can reach a non-200 response without Dio throwing.
Failure failureFromStatusCode(int? statusCode) {
  return switch (statusCode) {
    401 || 403 => ServerFailure('Not authorised to read this. Check the API token.', statusCode: statusCode),
    404 => ServerFailure('Not found.', statusCode: statusCode),
    429 => ServerFailure('Too many requests. Wait a moment and try again.', statusCode: statusCode),
    final int code when code >= 500 =>
      ServerFailure('The server is having trouble. Try again later.', statusCode: code),
    _ => ServerFailure('The request failed.', statusCode: statusCode),
  };
}

/// Maps any Firebase exception — Auth, Firestore, or Storage — to a failure.
Failure failureFromFirebase(FirebaseException exception) {
  if (exception is FirebaseAuthException) {
    return _failureFromFirebaseAuth(exception);
  }

  return switch (exception.code) {
    'permission-denied' => AuthFailure('You do not have access to this.', code: exception.code),
    'unavailable' => const NetworkFailure('Could not reach the server. Check your connection.'),
    'not-found' || 'user-document-not-found' => const ServerFailure('That record no longer exists.'),
    _ => UnknownFailure(exception.message ?? 'Something went wrong. Please try again.'),
  };
}

Failure _failureFromFirebaseAuth(FirebaseAuthException exception) {
  final message = switch (exception.code) {
    'invalid-email' => 'That e-mail address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Wrong e-mail or password.',
    'email-already-in-use' => 'An account with that e-mail already exists.',
    'weak-password' => 'Pick a stronger password — at least six characters.',
    'operation-not-allowed' => 'Signing in this way is not enabled.',
    'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
    'network-request-failed' => 'No internet connection. Check your network and try again.',
    _ => exception.message ?? 'Could not sign you in. Please try again.',
  };

  return AuthFailure(message, code: exception.code);
}
