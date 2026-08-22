import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/video/domain/entities/video_entity.dart';
import 'package:filmio/features/video/domain/usecases/get_trailer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// The one place in this feature with a decision in it: which of a title's
/// videos gets played.
void main() {
  late MockVideoRepository repository;
  late GetTrailerUseCase useCase;

  VideoEntity video({
    String key = 'k',
    VideoSite site = VideoSite.youtube,
    int? size,
    VideoType type = VideoType.trailer,
    bool? official,
    String? publishedAt,
  }) =>
      VideoEntity(
        id: '$key-$size',
        key: key,
        site: site,
        size: size,
        type: type,
        official: official,
        publishedAt: publishedAt,
      );

  void stub(List<VideoEntity> videos) {
    when(() => repository.getVideos(mediaId: any(named: 'mediaId'), mediaType: any(named: 'mediaType'))).thenAnswer((_) async => Right(videos));
  }

  Future<VideoEntity?> pick() async {
    final result = await useCase.call(
      params: const GetTrailerParams(mediaId: 550, mediaType: MediaType.movie),
    );
    return result.getRight().toNullable();
  }

  setUpAll(registerCommonFallbacks);

  setUp(() {
    repository = MockVideoRepository();
    useCase = GetTrailerUseCase(repository);
  });

  test('forwards the title and the catalogue to the repository', () async {
    stub([video()]);

    await useCase.call(params: const GetTrailerParams(mediaId: 1399, mediaType: MediaType.series));

    verify(() => repository.getVideos(mediaId: 1399, mediaType: MediaType.series)).called(1);
  });

  group('resolution', () {
    test('plays the largest of several videos', () async {
      stub([video(key: 'a', size: 720), video(key: 'b', size: 1080), video(key: 'c', size: 360)]);

      expect((await pick())?.key, 'b');
    });

    test('a single video is played whatever its size', () async {
      stub([video(key: 'only', size: 360)]);

      expect((await pick())?.key, 'only');
    });

    test('a video with no size given cannot outrank one that has it', () async {
      stub([video(key: 'sized', size: 360), video(key: 'unsized')]);

      expect((await pick())?.key, 'sized');
    });
  });

  group('host', () {
    test('a Vimeo video is as playable as a YouTube one', () async {
      stub([video(key: '12345', site: VideoSite.vimeo, size: 1080)]);

      final trailer = await pick();
      expect(trailer?.key, '12345');
      expect(trailer?.site, VideoSite.vimeo);
    });

    test('a host the app cannot open is skipped even when it is the largest', () async {
      stub([video(key: 'elsewhere', site: VideoSite.unknown, size: 2160), video(key: 'youtube', size: 720)]);

      expect((await pick())?.key, 'youtube');
    });

    test('a video with no key is skipped', () async {
      stub([video(key: '', size: 2160), video(key: 'playable', size: 480)]);

      expect((await pick())?.key, 'playable');
    });

    test('nothing playable is not a failure — it is simply no trailer', () async {
      stub([video(key: 'x', site: VideoSite.unknown, size: 1080)]);

      final result = await useCase.call(params: const GetTrailerParams(mediaId: 550, mediaType: MediaType.movie));

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable(), isNull);
    });

    test('a title with no videos at all yields nothing', () async {
      stub(const []);

      expect(await pick(), isNull);
    });
  });

  group('kind', () {
    test('a trailer wins over a bigger clip of another kind', () async {
      stub([video(key: 'featurette', size: 1080, type: VideoType.other), video(key: 'trailer', size: 480)]);

      expect((await pick())?.key, 'trailer');
    });

    test('a teaser stands in when there is no trailer', () async {
      stub([video(key: 'clip', size: 1080, type: VideoType.other), video(key: 'teaser', size: 480, type: VideoType.teaser)]);

      expect((await pick())?.key, 'teaser');
    });

    test('anything playable is better than nothing when there is neither', () async {
      stub([video(key: 'featurette', size: 720, type: VideoType.other)]);

      expect((await pick())?.key, 'featurette');
    });
  });

  group('ties', () {
    test('the official upload wins at equal size', () async {
      stub([
        video(key: 'reupload', size: 1080, official: false),
        video(key: 'studio', size: 1080, official: true),
      ]);

      expect((await pick())?.key, 'studio');
    });

    test('the newest wins at equal size and standing', () async {
      stub([
        video(key: 'old', size: 1080, official: true, publishedAt: '2014-10-02T19:20:22.000Z'),
        video(key: 'new', size: 1080, official: true, publishedAt: '2016-03-05T02:03:14.000Z'),
      ]);

      expect((await pick())?.key, 'new');
    });
  });

  test('a failure is passed through rather than swallowed into "no trailer"', () async {
    when(() => repository.getVideos(mediaId: any(named: 'mediaId'), mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const Left(NetworkFailure('offline')));

    final result = await useCase.call(params: const GetTrailerParams(mediaId: 550, mediaType: MediaType.movie));

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });
}
