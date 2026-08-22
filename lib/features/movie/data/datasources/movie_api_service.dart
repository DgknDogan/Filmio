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

  /// The browse-all screen. Every filter the app offers is a query parameter
  /// here; TMDB leaves out any that is not sent.
  @GET("/discover/movie")
  Future<HttpResponse<MovieApiResponse>> discoverMovies({
    @Query("sort_by") String? sortBy,
    @Query("with_genres") String? withGenres,
    @Query("vote_average.gte") double? voteAverageGte,
    @Query("vote_average.lte") double? voteAverageLte,
    @Query("vote_count.gte") int? voteCountGte,
    @Query("primary_release_date.gte") String? releaseDateGte,
    @Query("primary_release_date.lte") String? releaseDateLte,
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
