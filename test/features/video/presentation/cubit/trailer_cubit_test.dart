import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/video/domain/entities/video_entity.dart';
import 'package:filmio/features/video/domain/usecases/get_trailer.dart';
import 'package:filmio/features/video/presentation/cubit/trailer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetTrailerUseCase getTrailer;

  const trailer = VideoEntity(id: 'v1', key: 'abc', site: VideoSite.youtube, size: 1080, type: VideoType.trailer);

  void stub(Either<Failure, VideoEntity?> result) {
    when(() => getTrailer.call(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  setUpAll(registerCommonFallbacks);

  setUp(() {
    getTrailer = MockGetTrailerUseCase();
    stub(const Right(trailer));
  });

  TrailerCubit build({int? mediaId = 550, MediaType mediaType = MediaType.movie}) =>
      TrailerCubit(getTrailer, mediaId: mediaId, mediaType: mediaType);

  test('asks for the trailer as soon as the cubit exists', () async {
    final cubit = build();
    await Future<void>.delayed(Duration.zero);

    verify(() => getTrailer.call(params: const GetTrailerParams(mediaId: 550, mediaType: MediaType.movie))).called(1);
    await cubit.close();
  });

  test('asks against the series catalogue for a series', () async {
    final cubit = build(mediaId: 1399, mediaType: MediaType.series);
    await Future<void>.delayed(Duration.zero);

    verify(() => getTrailer.call(params: const GetTrailerParams(mediaId: 1399, mediaType: MediaType.series))).called(1);
    await cubit.close();
  });

  blocTest<TrailerCubit, TrailerState>(
    'holds the video the use case chose',
    build: build,
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TrailerReady(trailer)),
  );

  blocTest<TrailerCubit, TrailerState>(
    'a title with no trailer is unavailable rather than failed',
    build: build,
    setUp: () => stub(const Right(null)),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TrailerUnavailable()),
  );

  blocTest<TrailerCubit, TrailerState>(
    'a failure is distinguishable from having no trailer',
    build: build,
    setUp: () => stub(const Left(NetworkFailure('offline'))),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TrailerFailure('offline')),
  );

  blocTest<TrailerCubit, TrailerState>(
    'a title with no id is unavailable rather than a request',
    build: () => build(mediaId: null),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      expect(cubit.state, const TrailerUnavailable());
      verifyNever(() => getTrailer.call(params: any(named: 'params')));
    },
  );

  blocTest<TrailerCubit, TrailerState>(
    'retrying after a failure asks again',
    build: build,
    setUp: () => stub(const Left(NetworkFailure('offline'))),
    wait: const Duration(milliseconds: 10),
    act: (cubit) async {
      stub(const Right(trailer));
      await cubit.loadTrailer();
    },
    verify: (cubit) => expect(cubit.state, const TrailerReady(trailer)),
  );
}
