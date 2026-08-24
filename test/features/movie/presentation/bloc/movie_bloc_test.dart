import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetPopularMoviesUseCase getPopular;
  late MockGetTopRatedMoviesUseCase getTopRated;
  late MockGetRecommendedMovieIdsUseCase getRecommendedIds;
  late MockGetMovieDetailsUseCase getDetails;

  const withPoster = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');
  const withoutPoster = MovieEntity(id: 2, title: 'B');
  const recommended = MovieEntity(id: 11, title: 'Star Wars', posterPath: '/sw.jpg');

  /// Several, so that a fallback picked at random has somewhere to vary.
  const topRatedList = [
    withPoster,
    MovieEntity(id: 3, title: 'C', posterPath: '/c.jpg'),
    MovieEntity(id: 4, title: 'D', posterPath: '/d.jpg'),
  ];

  setUp(() {
    getPopular = MockGetPopularMoviesUseCase();
    getTopRated = MockGetTopRatedMoviesUseCase();
    getRecommendedIds = MockGetRecommendedMovieIdsUseCase();
    getDetails = MockGetMovieDetailsUseCase();

    // Every build asks for a recommendation, so the two calls behind it have a
    // default here and each test overrides only what it is about.
    when(() => getRecommendedIds.call()).thenAnswer((_) async => const Right([]));
    when(() => getDetails.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(recommended));
  });

  MovieBloc build() => MovieBloc(getPopular, getTopRated, getRecommendedIds, getDetails);

  void stub({
    required Either<Failure, List<MovieEntity>> popular,
    required Either<Failure, List<MovieEntity>> topRated,
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
    Either<Failure, List<int>> ids = const Right([11]),
    Either<Failure, MovieEntity> details = const Right(recommended),
    Duration? delay,
  }) {
    when(() => getRecommendedIds.call()).thenAnswer((_) async {
      if (delay != null) await Future<void>.delayed(delay);
      return ids;
    });
    when(() => getDetails.call(params: any(named: 'params'))).thenAnswer((_) async => details);
  }

  group('the rows', () {
    blocTest<MovieBloc, MovieState>(
      'emits success with both lists filtered to titles that have a poster',
      build: build,
      setUp: () => stub(popular: const Right([withPoster, withoutPoster]), topRated: const Right([withPoster])),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.popularFilmsList, const [withPoster]);
        expect(state.topFilmsList, const [withPoster]);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'reports a failure rather than indexing an empty list when nothing has a poster',
      build: build,
      setUp: () => stub(popular: const Right([withoutPoster]), topRated: const Right([withoutPoster])),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, isA<MovieError>()),
    );

    blocTest<MovieBloc, MovieState>(
      'a failure in either request becomes an error state',
      build: build,
      setUp: () => stub(popular: const Left(NetworkFailure('offline')), topRated: const Right([withPoster])),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, const MovieError(NetworkFailure('offline'))),
    );

    blocTest<MovieBloc, MovieState>(
      'a failure in the second request also becomes an error state',
      build: build,
      setUp: () => stub(popular: const Right([withPoster]), topRated: const Left(ServerFailure('boom', statusCode: 500))),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, const MovieError(ServerFailure('boom', statusCode: 500))),
    );
  });

  group('the recommendation', () {
    blocTest<MovieBloc, MovieState>(
      'is asked for as soon as the bloc is built, without waiting for the rows',
      build: build,
      setUp: () => stubRecommendation(),
      verify: (_) => verify(() => getRecommendedIds.call()).called(1),
    );

    blocTest<MovieBloc, MovieState>(
      'is the first id the service ranked, fetched from TMDB by id',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(ids: const Right([11, 550, 912649]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        verify(() => getDetails.call(params: 11)).called(1);
        // The lower-ranked ids are fallbacks the head of the tab has no room for.
        verifyNever(() => getDetails.call(params: 550));
        expect((bloc.state as MovieSuccess).recommended, const RecommendedMovieLoaded(recommended));
      },
    );

    blocTest<MovieBloc, MovieState>(
      'that lands before the rows is carried into the state they emit',
      build: build,
      // The rows come back slowly, so the recommendation resolves while the
      // state is still MovieLoading and has nowhere to be put yet.
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]), delay: const Duration(milliseconds: 20));
        stubRecommendation();
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect((bloc.state as MovieSuccess).recommended, const RecommendedMovieLoaded(recommended)),
    );

    blocTest<MovieBloc, MovieState>(
      'that lands after the rows folds into the state already on screen',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(delay: const Duration(milliseconds: 20));
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      expect: () => const [
        MovieSuccess([withPoster], [withPoster], RecommendedMovieLoading()),
        MovieSuccess([withPoster], [withPoster], RecommendedMovieLoaded(recommended)),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'falls back to a top-rated title when the service has nothing to suggest yet',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right(topRatedList));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        // An account that has liked nothing yet still opens on a title rather
        // than on an empty block — no id means there is nothing to fetch.
        final recommended = state.recommended as RecommendedMovieLoaded;
        expect(state.topFilmsList, contains(recommended.movie));
        verifyNever(() => getDetails.call(params: any(named: 'params')));
      },
    );

    blocTest<MovieBloc, MovieState>(
      'falls back even when the empty answer arrives before the rows do',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right(topRatedList), delay: const Duration(milliseconds: 20));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.topFilmsList, contains((state.recommended as RecommendedMovieLoaded).movie));
      },
    );

    blocTest<MovieBloc, MovieState>(
      'never falls back to a title with no poster to show',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withoutPoster, withPoster, withoutPoster]));
        stubRecommendation(ids: const Right([]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      // The head of the tab draws artwork; a posterless stand-in would open the
      // screen on a blank rectangle.
      verify: (bloc) => expect((bloc.state as MovieSuccess).recommended, const RecommendedMovieLoaded(withPoster)),
    );

    blocTest<MovieBloc, MovieState>(
      'failing leaves the rows standing',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(ids: const Left(AuthFailure('Sign in again.')));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.recommended, const RecommendedMovieFailure('Sign in again.'));
        expect(state.popularFilmsList, const [withPoster]);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'a title that cannot be fetched fails the head of the tab, not the tab',
      build: build,
      setUp: () {
        stub(popular: const Right([withPoster]), topRated: const Right([withPoster]));
        stubRecommendation(details: const Left(ServerFailure('Not found.', statusCode: 404)));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        expect(bloc.state, isA<MovieSuccess>());
        expect((bloc.state as MovieSuccess).recommended, const RecommendedMovieFailure('Not found.'));
      },
    );
  });
}
