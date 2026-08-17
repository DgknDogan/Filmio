import 'package:dio/dio.dart';
import 'package:filmio/core/network/api_guard.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

/// Every repository method against the TMDB API funnels through
/// [guardApiCall], so its three branches are the error handling for the whole
/// data layer.
void main() {
  final requestOptions = RequestOptions(path: '/movie/popular');

  HttpResponse<String> responseWith(int statusCode) => HttpResponse(
        'body',
        Response(requestOptions: requestOptions, statusCode: statusCode, data: 'body'),
      );

  test('a 200 returns Right with the mapped body', () async {
    final result = await guardApiCall<int, String>(() async => responseWith(200), (body) => body.length);

    expect(result.getRight().toNullable(), 4);
  });

  test('a non-200 returns Left carrying the status code', () async {
    final result = await guardApiCall<int, String>(() async => responseWith(503), (body) => body.length);

    final failure = result.getLeft().toNullable();
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 503);
  });

  test('map never runs for a non-200', () async {
    var mapCalls = 0;

    await guardApiCall<int, String>(() async => responseWith(404), (body) {
      mapCalls++;
      return body.length;
    });

    expect(mapCalls, 0);
  });

  test('a thrown DioException becomes the matching Failure', () async {
    final result = await guardApiCall<int, String>(
      () async => throw DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError),
      (body) => body.length,
    );

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });

  test('a timeout is reported as a network problem, not a server one', () async {
    final result = await guardApiCall<int, String>(
      () async => throw DioException(requestOptions: requestOptions, type: DioExceptionType.receiveTimeout),
      (body) => body.length,
    );

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });
}
