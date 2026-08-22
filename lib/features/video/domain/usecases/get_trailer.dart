import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/media_type.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

class GetTrailerParams extends Equatable {
  final int mediaId;
  final MediaType mediaType;

  const GetTrailerParams({required this.mediaId, required this.mediaType});

  @override
  List<Object?> get props => [mediaId, mediaType];
}

/// The one video to play for a title, out of everything TMDB holds for it.
///
/// A title can have a dozen videos — trailers, teasers, clips, featurettes,
/// some on hosts this app cannot open — and the screen shows one. Which one
/// that is, is a decision rather than a fetch, which is why it lives in a use
/// case and not in the cubit or the widget.
///
/// `Right(null)` means the title has nothing playable, which is not a failure:
/// plenty of titles simply have no trailer.
class GetTrailerUseCase extends UseCase<Either<Failure, VideoEntity?>, GetTrailerParams> {
  final VideoRepository _videoRepository;

  GetTrailerUseCase(this._videoRepository);

  @override
  Future<Either<Failure, VideoEntity?>> call({GetTrailerParams? params}) async {
    final result = await _videoRepository.getVideos(
      mediaId: params!.mediaId,
      mediaType: params.mediaType,
    );

    return result.map(_pickTrailer);
  }

  /// The rule, in order:
  ///
  /// 1. Only videos the app can actually play — a host it supports, and a key
  ///    to give the player.
  /// 2. A trailer if there is one, a teaser if there is not, and anything else
  ///    only as a last resort. Otherwise the biggest video would often be a
  ///    twenty-minute featurette.
  /// 3. Within that, the largest [VideoEntity.size] — the highest resolution
  ///    TMDB lists.
  /// 4. Ties go to the official upload, and then to the most recent, so the
  ///    same title always resolves to the same video.
  static VideoEntity? _pickTrailer(List<VideoEntity> videos) {
    final playable = videos.where((video) => video.isPlayable).toList();
    if (playable.isEmpty) return null;

    final candidates = _preferredGroup(playable)..sort(_bestFirst);

    return candidates.first;
  }

  static List<VideoEntity> _preferredGroup(List<VideoEntity> videos) {
    for (final type in [VideoType.trailer, VideoType.teaser]) {
      final group = videos.where((video) => video.type == type).toList();
      if (group.isNotEmpty) return group;
    }

    return videos;
  }

  static int _bestFirst(VideoEntity a, VideoEntity b) {
    // A video TMDB gives no size for cannot win against one it does.
    final bySize = (b.size ?? 0).compareTo(a.size ?? 0);
    if (bySize != 0) return bySize;

    final byOfficial = _officialFirst(b).compareTo(_officialFirst(a));
    if (byOfficial != 0) return byOfficial;

    return (b.publishedAt ?? '').compareTo(a.publishedAt ?? '');
  }

  static int _officialFirst(VideoEntity video) => (video.official ?? false) ? 1 : 0;
}
