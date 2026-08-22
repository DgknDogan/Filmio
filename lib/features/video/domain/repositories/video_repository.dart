import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/resource/failure.dart';
import '../entities/video_entity.dart';

abstract class VideoRepository {
  /// Every video TMDB holds for a film or a series. The endpoint is not paged.
  Future<Either<Failure, List<VideoEntity>>> getVideos({
    required int mediaId,
    required MediaType mediaType,
  });
}
