import 'package:filmio/features/video/data/models/video_api_response.dart';
import 'package:filmio/features/video/data/models/video_model.dart';
import 'package:filmio/features/video/domain/entities/video_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  VideoApiResponse response() => VideoApiResponse.fromJson(fixtureJson('videos.json'));

  group('fromJson', () {
    test('reads every key TMDB sends', () {
      final video = response().results!.first;

      expect(video.id, '639d5326be6d88007f170f44');
      expect(video.name, 'Fight Club (1999) Trailer - Starring Brad Pitt, Edward Norton, Helena Bonham Carter');
      expect(video.key, 'O-b2VfmmbyA');
      expect(video.site, 'YouTube');
      expect(video.size, 720);
      expect(video.type, 'Trailer');
      expect(video.official, isFalse);
      expect(video.publishedAt, '2016-03-05T02:03:14.000Z');
      expect(video.iso6391, 'en');
      expect(video.iso31661, 'US');
    });

    test('a video with almost every field missing parses instead of throwing', () {
      final video = VideoModel.fromJson(const {'key': 'abc'});

      expect(video.key, 'abc');
      expect(video.site, isNull);
      expect(video.size, isNull);
    });

    test('an empty results array is a list, not a null', () {
      final body = VideoApiResponse.fromJson(const {'id': 1, 'results': <Map<String, dynamic>>[]});

      expect(body.results, isEmpty);
    });
  });

  group('toEntity', () {
    test('carries every field across the boundary', () {
      final entity = response().results!.last.toEntity();

      expect(entity.id, '5c9294240e0a267cd516835f');
      expect(entity.name, '#TBT Trailer');
      expect(entity.key, 'BdJKm16Co6M');
      expect(entity.size, 1080);
      expect(entity.official, isTrue);
      expect(entity.publishedAt, '2014-10-02T19:20:22.000Z');
      expect(entity.languageCode, 'en');
      expect(entity.regionCode, 'US');
    });

    // The two free-text fields become the enums the domain reasons about, so
    // nothing above data/ compares strings to decide which player to open.
    group('site', () {
      test('YouTube and Vimeo are recognised whatever their casing', () {
        expect(const VideoModel(site: 'YouTube').toEntity().site, VideoSite.youtube);
        expect(const VideoModel(site: 'youtube').toEntity().site, VideoSite.youtube);
        expect(const VideoModel(site: 'Vimeo').toEntity().site, VideoSite.vimeo);
        expect(const VideoModel(site: 'VIMEO').toEntity().site, VideoSite.vimeo);
      });

      test('a host the app cannot play is unknown rather than a crash', () {
        expect(const VideoModel(site: 'Dailymotion').toEntity().site, VideoSite.unknown);
        expect(const VideoModel().toEntity().site, VideoSite.unknown);
      });
    });

    group('type', () {
      test('trailers and teasers are told apart', () {
        expect(const VideoModel(type: 'Trailer').toEntity().type, VideoType.trailer);
        expect(const VideoModel(type: 'Teaser').toEntity().type, VideoType.teaser);
      });

      test('everything else collapses into one kind', () {
        expect(const VideoModel(type: 'Featurette').toEntity().type, VideoType.other);
        expect(const VideoModel(type: 'Behind the Scenes').toEntity().type, VideoType.other);
        expect(const VideoModel().toEntity().type, VideoType.other);
      });
    });
  });

  group('isPlayable', () {
    test('needs a YouTube video and a key', () {
      expect(const VideoEntity(site: VideoSite.youtube, key: 'abc').isPlayable, isTrue);
      // Recognised, but nothing the app offers to open.
      expect(const VideoEntity(site: VideoSite.vimeo, key: '12345').isPlayable, isFalse);
      expect(const VideoEntity(site: VideoSite.unknown, key: 'abc').isPlayable, isFalse);
      expect(const VideoEntity(site: VideoSite.youtube).isPlayable, isFalse);
      expect(const VideoEntity(site: VideoSite.youtube, key: '').isPlayable, isFalse);
    });
  });
}
