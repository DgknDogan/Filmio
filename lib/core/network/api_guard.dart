import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../resource/failure.dart';
import '../resource/failure_mapper.dart';

/// Runs a Retrofit call and turns everything that can go wrong into a [Failure].
///
/// Every repository method against an HTTP service has the same three
/// outcomes — a 200 to map, a non-200 to report, or a thrown [DioException] —
/// so they live here once instead of in each method.
///
/// [map] only runs for a 200, which is why it can assume a usable body.
Future<Either<Failure, T>> guardApiCall<T, B>(
  Future<HttpResponse<B>> Function() request,
  T Function(B body) map,
) async {
  try {
    final httpResponse = await request();

    if (httpResponse.response.statusCode != HttpStatus.ok) {
      return Left(failureFromStatusCode(httpResponse.response.statusCode));
    }

    return Right(map(httpResponse.data));
  } on DioException catch (e) {
    return Left(failureFromDio(e));
  }
}
