import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/constants.dart';
import '../models/video_api_response.dart';

part 'video_api_service.g.dart';

/// Authentication headers come from the shared Dio in `core/network/`.
///
/// The two endpoints answer with the same body, so both are declared here and
/// the repository picks between them — no path is ever assembled by hand.
@RestApi(baseUrl: tmdbBaseUrl)
abstract class VideoApiService {
  factory VideoApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _VideoApiService;

  @GET("/movie/{movie_id}/videos")
  Future<HttpResponse<VideoApiResponse>> getMovieVideos({
    @Path("movie_id") required int movieId,
    @Query("language") String? language,
  });

  @GET("/tv/{series_id}/videos")
  Future<HttpResponse<VideoApiResponse>> getSeriesVideos({
    @Path("series_id") required int seriesId,
    @Query("language") String? language,
  });
}
