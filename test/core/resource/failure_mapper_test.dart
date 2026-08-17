import 'package:dio/dio.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/core/resource/failure_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioException(DioExceptionType type, {int? statusCode}) {
  final requestOptions = RequestOptions(path: '/movie/popular');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null ? null : Response(requestOptions: requestOptions, statusCode: statusCode),
  );
}

void main() {
  group('failureFromDio', () {
    test('maps every timeout kind to a NetworkFailure', () {
      const timeouts = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ];

      for (final type in timeouts) {
        expect(failureFromDio(_dioException(type)), isA<NetworkFailure>(), reason: '$type');
      }
    });

    test('maps a connection error to a NetworkFailure', () {
      expect(failureFromDio(_dioException(DioExceptionType.connectionError)), isA<NetworkFailure>());
    });

    test('maps a cancelled request to an UnknownFailure', () {
      expect(failureFromDio(_dioException(DioExceptionType.cancel)), isA<UnknownFailure>());
    });

    test('maps a bad response to the failure for its status code', () {
      final failure = failureFromDio(_dioException(DioExceptionType.badResponse, statusCode: 404));

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });

    test('maps a bad response with no response object to a ServerFailure with a null code', () {
      final failure = failureFromDio(_dioException(DioExceptionType.badResponse));

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, isNull);
    });
  });

  group('failureFromStatusCode', () {
    test('401 and 403 both say the token is the problem', () {
      for (final code in [401, 403]) {
        final failure = failureFromStatusCode(code);
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('API token'), reason: '$code');
      }
    });

    test('every 5xx maps to the same server-side message', () {
      for (final code in [500, 502, 503, 599]) {
        final failure = failureFromStatusCode(code);
        expect((failure as ServerFailure).statusCode, code);
        expect(failure.message, contains('server is having trouble'), reason: '$code');
      }
    });

    test('429 is called out separately from other 4xx', () {
      expect(failureFromStatusCode(429).message, isNot(failureFromStatusCode(400).message));
    });

    test('an unrecognised code still produces a ServerFailure carrying the code', () {
      final failure = failureFromStatusCode(418);

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 418);
    });
  });

  group('failureFromFirebase', () {
    test('wrong credentials do not reveal which field was wrong', () {
      for (final code in ['user-not-found', 'wrong-password', 'invalid-credential']) {
        final failure = failureFromFirebase(FirebaseAuthException(code: code));

        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Wrong e-mail or password.', reason: code);
      }
    });

    test('keeps the provider code for logging while showing a written message', () {
      final failure = failureFromFirebase(FirebaseAuthException(code: 'weak-password')) as AuthFailure;

      expect(failure.code, 'weak-password');
      expect(failure.message, contains('stronger password'));
    });

    test('falls back to the provider message for an unrecognised auth code', () {
      final failure = failureFromFirebase(FirebaseAuthException(code: 'nonsense-code', message: 'Provider text'));

      expect(failure.message, 'Provider text');
    });

    test('maps a Firestore unavailable error to a NetworkFailure, not an auth one', () {
      final failure = failureFromFirebase(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect(failure, isA<NetworkFailure>());
    });

    test('maps permission-denied to an AuthFailure', () {
      final failure = failureFromFirebase(FirebaseException(plugin: 'Firestore', code: 'permission-denied'));

      expect(failure, isA<AuthFailure>());
    });

    test('falls back to an UnknownFailure for an unrecognised Firestore code', () {
      final failure = failureFromFirebase(FirebaseException(plugin: 'Firestore', code: 'something-new'));

      expect(failure, isA<UnknownFailure>());
    });
  });
}
