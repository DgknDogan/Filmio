import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../core/constants/constants.dart';
import '../../models/movie_api_response.dart';

part 'movie_api_service.g.dart';

@RestApi(baseUrl: tmdbMovieBaseUrl)
abstract class MovieApiService {
  factory MovieApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _MovieApiService;

  @GET("/movie/popular")
  Future<HttpResponse<MovieApiResponse>> getPopularMovies({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/movie/top_rated")
  Future<HttpResponse<MovieApiResponse>> getTopRatedMovies({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/search/movie")
  Future<HttpResponse<MovieApiResponse>> searchMoviesByTitle({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Query("query") required String? query,
    @Query("include_adult") bool? includeAdult,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/movie/{movie_id}/similar")
  Future<HttpResponse<MovieApiResponse>> getSimilarMovies({
    @Header("accept") String? accept,
    @Header("Authorization") String? apiKey,
    @Path("movie_id") required int movieId,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
