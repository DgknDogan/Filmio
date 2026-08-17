import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/presentation/cubit/series_details_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLikeSeriesUseCase like;
  late MockDislikeSeriesUseCase dislike;
  late MockGetLikedSeriesUseCase getLiked;
  late MockGetSimilarSeriesUseCase getSimilar;

  const series = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');
  const similar = SeriesEntity(id: 2, name: 'B', posterPath: '/b.jpg');
  const similarWithoutPoster = SeriesEntity(id: 3, name: 'C');

  setUpAll(registerCommonFallbacks);

  setUp(() {
    like = MockLikeSeriesUseCase();
    dislike = MockDislikeSeriesUseCase();
    getLiked = MockGetLikedSeriesUseCase();
    getSimilar = MockGetSimilarSeriesUseCase();

    when(() => getLiked.call()).thenAnswer((_) async => const Right(<SeriesEntity>[]));
    when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(<SeriesEntity>[]));
    when(() => like.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
    when(() => dislike.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
  });

  SeriesDetailsCubit build() => SeriesDetailsCubit(like, getLiked, series, dislike, getSimilar);

  group('on construction', () {
    test('asks for the liked list and the similar titles', () async {
      final cubit = build();
      await Future<void>.delayed(Duration.zero);

      verify(() => getLiked.call()).called(1);
      verify(() => getSimilar.call(params: 1)).called(1);
      await cubit.close();
    });

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'marks the series liked when it is in the liked list',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([series])),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isTrue),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failed liked list leaves the heart empty rather than failing the screen',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Left(AuthFailure('no access'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isFalse),
    );
  });

  group('similar titles', () {
    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'keeps only titles with a poster',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params')))
          .thenAnswer((_) async => const Right([similar, similarWithoutPoster])),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect((cubit.state.similars as SimilarSeriesLoaded).series, const [similar]),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failure is its own state rather than an empty row',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params')))
          .thenAnswer((_) async => const Left(ServerFailure('boom'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.similars, const SimilarSeriesFailure('boom')),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a series with no id is not requested — TMDB has nothing to look up',
      build: () => SeriesDetailsCubit(like, getLiked, const SeriesEntity(name: 'No id'), dislike, getSimilar),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        verifyNever(() => getSimilar.call(params: any(named: 'params')));
        expect(cubit.state.similars, const SimilarSeriesLoaded(<SeriesEntity>[]));
      },
    );
  });

  group('liking', () {
    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a successful like fills the heart',
      build: build,
      act: (cubit) => cubit.likeSeries(series: series),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        verify(() => like.call(params: series)).called(1);
        expect(cubit.state.isSeriesLiked, isTrue);
      },
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failed like leaves the heart as it was',
      build: build,
      setUp: () => when(() => like.call(params: any(named: 'params')))
          .thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      act: (cubit) => cubit.likeSeries(series: series),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isFalse),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a successful dislike empties it again',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([series])),
      act: (cubit) => cubit.dislikeSeries(series: series),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        verify(() => dislike.call(params: series)).called(1);
        expect(cubit.state.isSeriesLiked, isFalse);
      },
    );
  });
}
