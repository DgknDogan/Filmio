import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/constants.dart';
import '../models/review_api_response.dart';

part 'review_api_service.g.dart';

/// Authentication headers come from the shared Dio in `core/network/`.
///
/// The two endpoints answer with the same body, so both are declared here and
/// the repository picks between them — no path is ever assembled by hand.
@RestApi(baseUrl: tmdbBaseUrl)
abstract class ReviewApiService {
  factory ReviewApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _ReviewApiService;

  @GET("/movie/{movie_id}/reviews")
  Future<HttpResponse<ReviewApiResponse>> getMovieReviews({
    @Path("movie_id") required int movieId,
    @Query("language") String? language,
    @Query("page") int? page,
  });

  @GET("/tv/{series_id}/reviews")
  Future<HttpResponse<ReviewApiResponse>> getSeriesReviews({
    @Path("series_id") required int seriesId,
    @Query("language") String? language,
    @Query("page") int? page,
  });
}
