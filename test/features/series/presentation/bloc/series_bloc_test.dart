import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/presentation/bloc/series_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// What the bloc is left holding now that the recommendation is one question
/// the repository answers: which of its three endings reaches the screen, the
/// stand-in when there is nothing to suggest, and the fact that the rows and
/// the recommendation can land in either order.
///
/// Turning ids into titles, dropping the ones TMDB cannot answer for, and
/// reading a cache instead of asking at all are the repository's, and are
/// tested there.
void main() {
  late MockGetPopularSeriesUseCase getPopular;
  late MockGetTopRatedSeriesUseCase getTopRated;
  late MockGetRecommendedSeriesUseCase getRecommended;

  const show = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg', overview: 'A.');
  const recommended = SeriesEntity(id: 11, name: 'Stranger Things', posterPath: '/sw.jpg', overview: 'Star Wars.');
  const secondPick = SeriesEntity(id: 1399, name: 'Game of Thrones', posterPath: '/got.jpg', overview: 'Game of Thrones.');

  /// Several, so that a fallback picked at random has somewhere to vary.
  const topRatedList = [
    show,
    SeriesEntity(id: 3, name: 'C', posterPath: '/c.jpg', overview: 'C.'),
    SeriesEntity(id: 4, name: 'D', posterPath: '/d.jpg', overview: 'D.'),
  ];

  setUp(() {
    getPopular = MockGetPopularSeriesUseCase();
    getTopRated = MockGetTopRatedSeriesUseCase();
    getRecommended = MockGetRecommendedSeriesUseCase();

    // Every build asks for a recommendation, so it has a default here and each
    // test overrides only what it is about.
    when(() => getRecommended.call()).thenAnswer((_) async => const Right([]));
  });

  SeriesBloc build() => SeriesBloc(getPopular, getTopRated, getRecommended);

  void stub({
    required Either<Failure, List<SeriesEntity>> popular,
    required Either<Failure, List<SeriesEntity>> topRated,
    Duration? delay,
  }) {
    Future<T> answer<T>(T value) async {
      if (delay != null) await Future<void>.delayed(delay);
      return value;
    }

    when(() => getPopular.call()).thenAnswer((_) => answer(popular));
    when(() => getTopRated.call()).thenAnswer((_) => answer(topRated));
  }

  void stubRecommendation(Either<Failure, List<SeriesEntity>> result, {Duration? delay}) {
    when(() => getRecommended.call()).thenAnswer((_) async {
      if (delay != null) await Future<void>.delayed(delay);
      return result;
    });
  }

  group('the rows', () {
    blocTest<SeriesBloc, SeriesState>(
      'emits success with both lists as the repository handed them over',
      build: build,
      setUp: () => stub(popular: const Right([show]), topRated: const Right(topRatedList)),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.popularSeriesList, const [show]);
        expect(state.topSeriesList, topRatedList);
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'reports a failure rather than indexing an empty list when nothing came back',
      build: build,
      setUp: () => stub(popular: const Right([]), topRated: const Right([])),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, isA<SeriesError>()),
    );

    blocTest<SeriesBloc, SeriesState>(
      'a failure in either request becomes an error state',
      build: build,
      setUp: () => stub(popular: const Left(NetworkFailure('offline')), topRated: const Right([show])),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, const SeriesError(NetworkFailure('offline'))),
    );

    blocTest<SeriesBloc, SeriesState>(
      'a failure in the second request also becomes an error state',
      build: build,
      setUp: () => stub(popular: const Right([show]), topRated: const Left(ServerFailure('boom', statusCode: 500))),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, const SeriesError(ServerFailure('boom', statusCode: 500))),
    );
  });

  group('the recommendation', () {
    blocTest<SeriesBloc, SeriesState>(
      'is asked for as soon as the bloc is built, without waiting for the rows',
      build: build,
      verify: (_) => verify(() => getRecommended.call()).called(1),
    );

    blocTest<SeriesBloc, SeriesState>(
      'is every title the repository answered with, in its order',
      build: build,
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right([show]));
        stubRecommendation(const Right([recommended, secondPick]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(
        (bloc.state as SeriesSuccess).recommended,
        const RecommendedSeriesLoaded([recommended, secondPick]),
      ),
    );

    blocTest<SeriesBloc, SeriesState>(
      'that lands before the rows is carried into the state they emit',
      build: build,
      // The rows come back slowly, so the recommendation resolves while the
      // state is still SeriesLoading and has nowhere to be put yet.
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right([show]), delay: const Duration(milliseconds: 20));
        stubRecommendation(const Right([recommended]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect((bloc.state as SeriesSuccess).recommended, const RecommendedSeriesLoaded([recommended])),
    );

    blocTest<SeriesBloc, SeriesState>(
      'that lands after the rows folds into the state already on screen',
      build: build,
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right([show]));
        stubRecommendation(const Right([recommended]), delay: const Duration(milliseconds: 20));
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      expect: () => const [
        SeriesSuccess([show], [show], RecommendedSeriesLoading()),
        SeriesSuccess([show], [show], RecommendedSeriesLoaded([recommended])),
      ],
    );

    blocTest<SeriesBloc, SeriesState>(
      'falls back to one top-rated title when the service has nothing to suggest yet',
      build: build,
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right(topRatedList));
        stubRecommendation(const Right([]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        // An account that has liked nothing yet still opens on a title rather
        // than on an empty block. Only one: a stand-in is not a list of
        // suggestions to step through.
        final recommended = state.recommended as RecommendedSeriesLoaded;
        expect(recommended.series, hasLength(1));
        expect(state.topSeriesList, contains(recommended.series.single));
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'falls back even when the empty answer arrives before the rows do',
      build: build,
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right(topRatedList), delay: const Duration(milliseconds: 20));
        stubRecommendation(const Right([]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.topSeriesList, contains((state.recommended as RecommendedSeriesLoaded).series.single));
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'failing leaves the rows standing',
      build: build,
      setUp: () {
        stub(popular: const Right([show]), topRated: const Right([show]));
        stubRecommendation(const Left(AuthFailure('Sign in again.')));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.recommended, const RecommendedSeriesFailure('Sign in again.'));
        expect(state.popularSeriesList, const [show]);
      },
    );
  });
}
