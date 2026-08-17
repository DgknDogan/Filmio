import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/constants.dart';
import '../models/movie_api_response.dart';

part 'movie_api_service.g.dart';

/// Authentication headers come from the shared Dio in `core/network/`.
@RestApi(baseUrl: tmdbBaseUrl)
abstract class MovieApiService {
  factory MovieApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _MovieApiService;

  @GET("/movie/popular")
  Future<HttpResponse<MovieApiResponse>> getPopularMovies({
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/movie/top_rated")
  Future<HttpResponse<MovieApiResponse>> getTopRatedMovies({
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/search/movie")
  Future<HttpResponse<MovieApiResponse>> searchMoviesByTitle({
    @Query("query") required String? query,
    @Query("include_adult") bool? includeAdult,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/movie/{movie_id}/similar")
  Future<HttpResponse<MovieApiResponse>> getSimilarMovies({
    @Path("movie_id") required int movieId,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
