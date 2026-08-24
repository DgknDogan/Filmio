import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/presentation/bloc/series_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetPopularSeriesUseCase getPopular;
  late MockGetTopRatedSeriesUseCase getTopRated;
  late MockGetRecommendedSeriesIdsUseCase getRecommendedIds;
  late MockGetSeriesDetailsUseCase getDetails;

  const withPoster = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');
  const withoutPoster = SeriesEntity(id: 2, name: 'B');
  const recommended = SeriesEntity(id: 66732, name: 'Stranger Things', posterPath: '/st.jpg');

  /// Several, so that a fallback picked at random has somewhere to vary.
  const topRatedList = [
    withPoster,
    SeriesEntity(id: 3, name: 'C', posterPath: '/c.jpg'),
    SeriesEntity(id: 4, name: 'D', posterPath: '/d.jpg'),
  ];

  setUp(() {
    getPopular = MockGetPopularSeriesUseCase();
    getTopRated = MockGetTopRatedSeriesUseCase();
    getRecommendedIds = MockGetRecommendedSeriesIdsUseCase();
    getDetails = MockGetSeriesDetailsUseCase();

    // Every build asks for a recommendation, so the two calls behind it have a
    // default here and each test overrides only what it is about.
    when(() => getRecommendedIds.call()).thenAnswer((_) async => const Right([]));
    when(() => getDetails.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(recommended));
  });

  SeriesBloc build() => SeriesBloc(getPopular, getTopRated, getRecommendedIds, getDetails);

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

  void stubRecommendation({
    Either<Failure, List<int>> ids = const Right([66732]),
    Either<Failure, SeriesEntity> details = const Right(recommended),
    Duration? delay,
  }) {
    when(() => getRecommendedIds.call()).thenAnswer((_) async {
      if (delay != null) await Future<void>.delayed(delay);
      return ids;
    });
    when(() => getDetails.call(params: any(named: 'params'))).thenAnswer((_) async => details);
  }

  group('the rows', () {
    blocTest<SeriesBloc, SeriesState>(
      'emits success with both lists filtered to titles that have a poster',
      build: build,
      setUp: () => stub(popular: const Right([withPoster, withoutPoster]), topRated: const Right([withPoster])),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.popularSeriesList, const [withPoster]);
        expect(state.topSeriesList, const [withPoster]);
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'reports a failure rather than indexing an empty list when nothing has a poster',
      build: build,
      setUp: () => stub(popular: const Right([withoutPoster]), topRated: const Right([withoutPoster])),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, isA<SeriesError>()),
    );

    blocTest<SeriesBloc, SeriesState>(
      'a failure in either request becomes an error state',
      build: build,
      setUp: () => stub(popular: const Left(NetworkFailure('offline')), topRated: const Right([withPoster])),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, const SeriesError(NetworkFailure('offline'))),
    );

    blocTest<SeriesBloc, SeriesState>(
      'a failure in the second request also becomes an error state',
      build: build,
      setUp: () => stub(popular: const Right([withPoster]), topRated: const Left(ServerFailure('boom', statusCode: 500))),
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect(bloc.state, const SeriesError(ServerFailure('boom', statusCode: 500))),
    );
  });

  group('the recommendation', () {
    blocTest<SeriesBloc, SeriesState>(
      'is asked for as soon as the bloc is built, without waiting for the rows',
      build: build,
      setUp: () => stubRecommendation(),
      verify: (_) => verify(() => getRecommendedIds.call()).called(1),
    );

    blocTest<SeriesBloc, SeriesState>(
      'is the first id the service ranked, fetched from TMDB by id',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(ids: const Right([66732, 1399, 82856]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        verify(() => getDetails.call(params: 66732)).called(1);
        // The lower-ranked ids are fallbacks the head of the tab has no room for.
        verifyNever(() => getDetails.call(params: 1399));
        expect((bloc.state as SeriesSuccess).recommended, const RecommendedSeriesLoaded(recommended));
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'that lands before the rows is carried into the state they emit',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]), delay: const Duration(milliseconds: 20));
        stubRecommendation();
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect((bloc.state as SeriesSuccess).recommended, const RecommendedSeriesLoaded(recommended)),
    );

    blocTest<SeriesBloc, SeriesState>(
      'that lands after the rows folds into the state already on screen',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(delay: const Duration(milliseconds: 20));
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      expect: () => const [
        SeriesSuccess([withPoster], [withPoster], RecommendedSeriesLoading()),
        SeriesSuccess([withPoster], [withPoster], RecommendedSeriesLoaded(recommended)),
      ],
    );

    blocTest<SeriesBloc, SeriesState>(
      'falls back to a top-rated series when the service has nothing to suggest yet',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right(topRatedList));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        final recommended = state.recommended as RecommendedSeriesLoaded;
        expect(state.topSeriesList, contains(recommended.series));
        verifyNever(() => getDetails.call(params: any(named: 'params')));
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'falls back even when the empty answer arrives before the rows do',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right(topRatedList), delay: const Duration(milliseconds: 20));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.topSeriesList, contains((state.recommended as RecommendedSeriesLoaded).series));
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'never falls back to a title with no poster to show',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withoutPoster, withPoster, withoutPoster]));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) => expect((bloc.state as SeriesSuccess).recommended, const RecommendedSeriesLoaded(withPoster)),
    );

    blocTest<SeriesBloc, SeriesState>(
      'failing leaves the rows standing',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(ids: const Left(AuthFailure('Sign in again.')));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        final state = bloc.state as SeriesSuccess;
        expect(state.recommended, const RecommendedSeriesFailure('Sign in again.'));
        expect(state.popularSeriesList, const [withPoster]);
      },
    );

    blocTest<SeriesBloc, SeriesState>(
      'a title that cannot be fetched fails the head of the tab, not the tab',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(details: const Left(ServerFailure('Not found.', statusCode: 404)));
      },
      act: (bloc) => bloc.add(GetSeries()),
      verify: (bloc) {
        expect(bloc.state, isA<SeriesSuccess>());
        expect((bloc.state as SeriesSuccess).recommended, const RecommendedSeriesFailure('Not found.'));
      },
    );
  });
}
