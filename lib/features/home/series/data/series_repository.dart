import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../utils/api_key.dart';
import '../../../../utils/constants.dart';
import '../models/series_model.dart';

class SeriesRepository {
  final _dio = Dio();

  Future<List<SeriesModel>> getPopularSeries() async {
    final List<SeriesModel> seriesList = [];
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
        popularSeriesUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      final resultList = response.data["results"] as List<dynamic>;
      for (var result in resultList) {
        final film = SeriesModel.fromJson(result);
        seriesList.add(film);
      }
      return seriesList;
    } catch (e) {
      log(e.toString());
    }
    return seriesList;
  }

  Future<List<SeriesModel>> getTopRatedSeries({required int page}) async {
    final List<SeriesModel> seriesList = [];
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
        topRatedSeriesUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      final resultList = response.data["results"] as List<dynamic>;
      for (var result in resultList) {
        final film = SeriesModel.fromJson(result);
        seriesList.add(film);
      }
      return seriesList;
    } catch (e) {
      log(e.toString());
    }
    return seriesList;
  }
}
