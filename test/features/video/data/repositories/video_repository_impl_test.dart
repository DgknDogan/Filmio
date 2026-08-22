import 'package:dio/dio.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/video/data/models/video_api_response.dart';
import 'package:filmio/features/video/data/models/video_model.dart';
import 'package:filmio/features/video/data/repositories/video_repository_impl.dart';
import 'package:filmio/features/video/domain/entities/video_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockVideoApiService api;
  late VideoRepositoryImpl repository;

  final requestOptions = RequestOptions(path: '/movie/550/videos');

  HttpResponse<VideoApiResponse> responseWith(VideoApiResponse body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  const trailer = VideoModel(id: 'v1', key: 'abc', site: 'YouTube', size: 1080, type: 'Trailer', official: true);

  void stubMovie(HttpResponse<VideoApiResponse> response) {
    when(() => api.getMovieVideos(movieId: any(named: 'movieId'), language: any(named: 'language')))
        .thenAnswer((_) async => response);
  }

  void stubSeries(HttpResponse<VideoApiResponse> response) {
    when(() => api.getSeriesVideos(seriesId: any(named: 'seriesId'), language: any(named: 'language')))
        .thenAnswer((_) async => response);
  }

  setUp(() {
    api = MockVideoApiService();
    repository = VideoRepositoryImpl(api);
  });

  group('endpoint', () {
    test('a film is asked for on the movie endpoint', () async {
      stubMovie(responseWith(VideoApiResponse(id: 550, results: const [trailer])));

      await repository.getVideos(mediaId: 550, mediaType: MediaType.movie);

      verify(() => api.getMovieVideos(movieId: 550, language: 'en-US')).called(1);
      verifyNever(() => api.getSeriesVideos(seriesId: any(named: 'seriesId'), language: any(named: 'language')));
    });

    test('a series is asked for on the tv endpoint', () async {
      stubSeries(responseWith(VideoApiResponse(id: 1399, results: const [trailer])));

      await repository.getVideos(mediaId: 1399, mediaType: MediaType.series);

      verify(() => api.getSeriesVideos(seriesId: 1399, language: 'en-US')).called(1);
      verifyNever(() => api.getMovieVideos(movieId: any(named: 'movieId'), language: any(named: 'language')));
    });
  });

  group('getVideos', () {
    test('maps the response models to entities', () async {
      stubMovie(responseWith(VideoApiResponse(id: 550, results: const [trailer])));

      final videos = (await repository.getVideos(mediaId: 550, mediaType: MediaType.movie)).getRight().toNullable()!;

      expect(videos.single.key, 'abc');
      expect(videos.single.site, VideoSite.youtube);
      expect(videos.single.type, VideoType.trailer);
      // The boundary hands back entities, never models.
      expect(videos.single, isNot(isA<VideoModel>()));
    });

    test('a null results array becomes an empty list, not a crash', () async {
      stubMovie(responseWith(VideoApiResponse(id: 550)));

      final videos = (await repository.getVideos(mediaId: 550, mediaType: MediaType.movie)).getRight().toNullable();

      expect(videos, isEmpty);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubMovie(responseWith(VideoApiResponse(id: 550, results: const []), statusCode: 404));

      final failure = (await repository.getVideos(mediaId: 550, mediaType: MediaType.movie)).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getMovieVideos(movieId: any(named: 'movieId'), language: any(named: 'language')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      final result = await repository.getVideos(mediaId: 550, mediaType: MediaType.movie);

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });
}
