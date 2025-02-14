import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../utils/api_key.dart';
import '../../../utils/constants.dart';
import '../models/film_model.dart';

final class FilmRepository {
  final _dio = Dio();

  Future<List<FilmModel>> getPopularMovies() async {
    final List<FilmModel> filmList = [];
    final headers = {
      "accept": "application/json",
      "Authorization": "Bearer $apiKey",
    };
    final queryParameters = {
      "language": "en-US",
      "page": 1,
    };
    try {
      final response = await _dio.get(
        popularMoviesUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      final resultList = response.data["results"] as List<dynamic>;
      for (var result in resultList) {
        final film = FilmModel.fromJson(result);
        filmList.add(film);
      }
      return filmList;
    } catch (e) {
      log(e.toString());
    }
    return filmList;
  }

  Future<List<FilmModel>> getTopRatedMovies({required int page}) async {
    final List<FilmModel> filmList = [];
    final headers = {
      "accept": "application/json",
      "Authorization": "Bearer $apiKey",
    };
    final queryParameters = {
      "language": "en-US",
      "page": page,
    };
    try {
      final response = await _dio.get(
        topRatedMoviesUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      final resultList = response.data["results"] as List<dynamic>;
      for (var result in resultList) {
        final film = FilmModel.fromJson(result);
        filmList.add(film);
      }
      return filmList;
    } catch (e) {
      log(e.toString());
    }
    return filmList;
  }
}
