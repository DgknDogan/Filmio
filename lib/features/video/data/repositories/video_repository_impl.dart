import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/network/api_guard.dart';
import '../../../../core/resource/failure.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_api_service.dart';
import '../models/video_api_response.dart';

class VideoRepositoryImpl extends VideoRepository {
  static const _language = "en-US";

  final VideoApiService _videoApiService;

  VideoRepositoryImpl(this._videoApiService);

  @override
  Future<Either<Failure, List<VideoEntity>>> getVideos({
    required int mediaId,
    required MediaType mediaType,
  }) {
    // The only thing the two catalogues disagree on is which endpoint to ask.
    final request = switch (mediaType) {
      MediaType.movie => () => _videoApiService.getMovieVideos(movieId: mediaId, language: _language),
      MediaType.series => () => _videoApiService.getSeriesVideos(seriesId: mediaId, language: _language),
    };

    return guardApiCall<List<VideoEntity>, VideoApiResponse>(request, _toEntities);
  }

  /// The single model → entity crossing for this feature.
  static List<VideoEntity> _toEntities(VideoApiResponse body) {
    return body.results?.map((model) => model.toEntity()).toList() ?? const [];
  }
}
