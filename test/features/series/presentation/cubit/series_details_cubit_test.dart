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
      'marks it liked even though the list stored it with different details',
      build: build,
      // The entry was written from a list endpoint weeks ago; this screen's
      // series came from the detail endpoint just now, so its rating and
      // popularity have moved on. Matching whole titles left the heart empty
      // on a series the reader had certainly liked.
      setUp: () => when(() => getLiked.call()).thenAnswer(
        (_) async => const Right([SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg', popularity: 41.2, voteAverage: 7.4)]),
      ),
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
      'carries the row the repository answered with',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([similar])),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.similars, const SimilarSeriesLoaded([similar])),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failure is its own state rather than an empty row',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(ServerFailure('boom'))),
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
    /// The screen has finished reading the liked list, which is the state a
    /// reader is actually looking at when they reach for the heart.
    Future<void> settled(SeriesDetailsCubit cubit, Future<void> Function() act) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await act();
    }

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'fills the heart before the write has landed',
      build: build,
      setUp: () => when(() => like.call(params: any(named: 'params'))).thenAnswer(
        (_) async {
          // A Firestore round trip. Waiting for it left the heart unmoved for
          // the best part of a second after the tap.
          await Future<void>.delayed(const Duration(milliseconds: 500));
          return const Right(unit);
        },
      ),
      act: (cubit) => settled(cubit, () async {
        final writing = cubit.likeSeries(series: series);
        expect(cubit.state.isSeriesLiked, isTrue);
        await writing;
      }),
      wait: const Duration(milliseconds: 600),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isTrue),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failed like puts the heart back rather than lying to the user',
      build: build,
      setUp: () => when(() => like.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      act: (cubit) => settled(cubit, () => cubit.likeSeries(series: series)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isFalse),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a successful dislike clears the flag',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([series])),
      act: (cubit) => settled(cubit, () => cubit.dislikeSeries(series: series)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        verify(() => dislike.call(params: series)).called(1);
        expect(cubit.state.isSeriesLiked, isFalse);
      },
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a failed dislike puts the heart back too',
      build: build,
      setUp: () {
        when(() => getLiked.call()).thenAnswer((_) async => const Right([series]));
        when(() => dislike.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      },
      act: (cubit) => settled(cubit, () => cubit.dislikeSeries(series: series)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isTrue),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'a tap that beats the liked list is not undone by it',
      build: build,
      // The list takes a moment to read; a reader who presses the heart inside
      // that moment used to watch it empty itself again when the read landed.
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return const Right(<SeriesEntity>[]);
      }),
      act: (cubit) => cubit.likeSeries(series: series),
      wait: const Duration(milliseconds: 80),
      verify: (cubit) => expect(cubit.state.isSeriesLiked, isTrue),
    );

    blocTest<SeriesDetailsCubit, SeriesDetailsState>(
      'pressing the heart for what it already says does not reach the server',
      build: build,
      act: (cubit) => settled(cubit, () => cubit.dislikeSeries(series: series)),
      wait: const Duration(milliseconds: 10),
      verify: (_) => verifyNever(() => dislike.call(params: any(named: 'params'))),
    );
  });
}
