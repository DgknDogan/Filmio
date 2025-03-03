import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/series_api_response.dart';

part 'series_api_service.g.dart';

@RestApi(baseUrl: tmdbSeriesBaseUrl)
abstract class SeriesApiService {
  factory SeriesApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SeriesApiService;

  @GET("/popular")
  Future<HttpResponse<SeriesApiResponse>> getTopRatedSeries({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/top_rated")
  Future<HttpResponse<SeriesApiResponse>> getPopularSeries({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
