import 'dart:io';

import 'package:dio/dio.dart';
import 'package:filmio/core/resources/data_state.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';

import '../../../../core/utils/api_key.dart';
import '../../domain/repository/movie_repository.dart';
import '../data_sources/remote/movie_api_service.dart';

class MovieRepositoryImpl extends MovieRepository {
  final MovieApiService _movieApiService;

  MovieRepositoryImpl(this._movieApiService);

  @override
  Future<DataState<List<MovieEntity>>> getPopularMovies() async {
    try {
      final httpResponse = await _movieApiService.getPopularMovies(
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
    } on DioException catch (e) {
      return DataError(error: e);
    }
  }

  @override
  Future<DataState<List<MovieEntity>>> getTopRatedMovies() async {
    try {
      final httpResponse = await _movieApiService.getTopRatedMovies(
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
    } on DioException catch (e) {
      return DataError(error: e);
    }
  }

  @override
  Future<DataState<List<MovieEntity>>> searchMoviesByTitle({required String query}) async {
    try {
      final httpResponse = await _movieApiService.searchMoviesByTitle(
        accept: "application/json",
        apiKey: "Bearer $apiKey",
        query: query,
        language: "en-US",
        includeAdult: false,
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
    } on DioException catch (e) {
      return DataError(error: e);
    }
  }
}
