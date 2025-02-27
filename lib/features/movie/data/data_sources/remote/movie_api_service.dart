import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/movie_api_response.dart';

part 'movie_api_service.g.dart';

@RestApi(baseUrl: tmdbMovieBaseUrl)
abstract class MovieApiService {
  factory MovieApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _MovieApiService;

  @GET("/popular")
  Future<HttpResponse<MovieApiResponse>> getPopularMovies({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/top_rated")
  Future<HttpResponse<MovieApiResponse>> getTopRatedMovies({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
