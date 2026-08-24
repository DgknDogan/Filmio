import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/constants.dart';
import '../models/series_api_response.dart';
import '../models/series_detail_model.dart';
import '../models/series_recommendation_response.dart';

part 'series_api_service.g.dart';

/// Authentication headers come from the shared Dio in `core/network/`.
@RestApi(baseUrl: tmdbBaseUrl)
abstract class SeriesApiService {
  factory SeriesApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SeriesApiService;

  @GET("/tv/top_rated")
  Future<HttpResponse<SeriesApiResponse>> getTopRatedSeries({
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/tv/popular")
  Future<HttpResponse<SeriesApiResponse>> getPopularSeries({
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/search/tv")
  Future<HttpResponse<SeriesApiResponse>> searchMoviesByTitle({
    @Query("query") required String? query,
    @Query("include_adult") bool? includeAdult,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  /// The browse-all screen. Television keeps its own names for the same
  /// filters — a first-air date rather than a release date.
  @GET("/discover/tv")
  Future<HttpResponse<SeriesApiResponse>> discoverSeries({
    @Query("sort_by") String? sortBy,
    @Query("with_genres") String? withGenres,
    @Query("vote_average.gte") double? voteAverageGte,
    @Query("vote_average.lte") double? voteAverageLte,
    @Query("vote_count.gte") int? voteCountGte,
    @Query("first_air_date.gte") String? firstAirDateGte,
    @Query("first_air_date.lte") String? firstAirDateLte,
    @Query("include_adult") bool? includeAdult,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  /// One series in full. The list endpoints above answer with a trimmed entry;
  /// this is where a series reached by id alone — a recommendation — comes from.
  @GET("/tv/{series_id}")
  Future<HttpResponse<SeriesDetailModel>> getSeriesDetails({
    @Path("series_id") required int seriesId,
    @Query("language") String? language,
  });

  /// Filmio's own recommendation service, not TMDB.
  ///
  /// The absolute URL takes it off this class's base URL, and the explicit
  /// header takes it off the shared Dio's TMDB credentials: a per-request
  /// header replaces the one on `BaseOptions`, so the user's Firebase ID token
  /// travels here and the TMDB token does not.
  @GET("$recommendationBaseUrl/recommendations/series")
  Future<HttpResponse<SeriesRecommendationResponse>> getRecommendations({
    @Header("Authorization") required String authorization,
    @Query("limit") int? limit,
  });

  @GET("/tv/{series_id}/similar")
  Future<HttpResponse<SeriesApiResponse>> getSimilarSeries({
    @Path("series_id") required int seriesId,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
