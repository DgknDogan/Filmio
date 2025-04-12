import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';

import '../../../../core/resources/data_state.dart';
import '../../../../core/utils/api_key.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repository/series_repository.dart';
import '../data_sources/remote/series_api_service.dart';

class SeriesRepositoryImpl extends SeriesRepository {
  final SeriesApiService _seriesApiService;

  SeriesRepositoryImpl(this._seriesApiService);
  @override
  Future<DataState<List<SeriesEntity>>> getPopularSeries() async {
    try {
      return await Isolate.run(
        () async {
          final httpResponse = await _seriesApiService.getPopularSeries(
            accept: "application/json",
            apiKey: "Bearer $apiKey",
            language: "en-US",
            page: 1,
          );
          if (httpResponse.response.statusCode == HttpStatus.ok) {
            return DataSuccess(data: httpResponse.data.results!);
          } else {
            return DataError(
              error: DioException(
                requestOptions: httpResponse.response.requestOptions,
                error: httpResponse.response.statusMessage,
                type: DioExceptionType.badResponse,
                response: httpResponse.response,
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      return DataError(error: e);
    }
  }

  @override
  Future<DataState<List<SeriesEntity>>> getTopRatedSeries() async {
    try {
      return await Isolate.run(
        () async {
          final httpResponse = await _seriesApiService.getTopRatedSeries(
            accept: "application/json",
            apiKey: "Bearer $apiKey",
            language: "en-US",
            page: 1,
          );
          if (httpResponse.response.statusCode == HttpStatus.ok) {
            return DataSuccess(data: httpResponse.data.results!);
          } else {
            return DataError(
              error: DioException(
                requestOptions: httpResponse.response.requestOptions,
                error: httpResponse.response.statusMessage,
                type: DioExceptionType.badResponse,
                response: httpResponse.response,
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      return DataError(error: e);
    }
  }
}
