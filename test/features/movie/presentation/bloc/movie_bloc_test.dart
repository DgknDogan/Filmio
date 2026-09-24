import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/presentation/bloc/movie_bloc.dart';
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
  late MockGetPopularMoviesUseCase getPopular;
  late MockGetTopRatedMoviesUseCase getTopRated;
  late MockGetRecommendedMoviesUseCase getRecommended;

  const film = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg', overview: 'A.');
  const recommended = MovieEntity(id: 11, title: 'Star Wars', posterPath: '/sw.jpg', overview: 'Star Wars.');
  const secondPick = MovieEntity(id: 550, title: 'Fight Club', posterPath: '/fc.jpg', overview: 'Fight Club.');

  /// Several, so that a fallback picked at random has somewhere to vary.
  const topRatedList = [
    film,
    MovieEntity(id: 3, title: 'C', posterPath: '/c.jpg', overview: 'C.'),
    MovieEntity(id: 4, title: 'D', posterPath: '/d.jpg', overview: 'D.'),
  ];

  setUp(() {
    getPopular = MockGetPopularMoviesUseCase();
    getTopRated = MockGetTopRatedMoviesUseCase();
    getRecommended = MockGetRecommendedMoviesUseCase();

    // Every build asks for a recommendation, so it has a default here and each
    // test overrides only what it is about.
    when(() => getRecommended.call()).thenAnswer((_) async => const Right([]));
  });

  MovieBloc build() => MovieBloc(getPopular, getTopRated, getRecommended);

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

  void stubRecommendation(Either<Failure, List<MovieEntity>> result, {Duration? delay}) {
    when(() => getRecommended.call()).thenAnswer((_) async {
      if (delay != null) await Future<void>.delayed(delay);
      return result;
    });
  }

  group('the rows', () {
    blocTest<MovieBloc, MovieState>(
      'emits success with both lists as the repository handed them over',
      build: build,
      setUp: () => stub(popular: const Right([film]), topRated: const Right(topRatedList)),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.popularFilmsList, const [film]);
        expect(state.topFilmsList, topRatedList);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'reports a failure rather than indexing an empty list when nothing came back',
      build: build,
      setUp: () => stub(popular: const Right([]), topRated: const Right([])),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, isA<MovieError>()),
    );

    blocTest<MovieBloc, MovieState>(
      'a failure in either request becomes an error state',
      build: build,
      setUp: () => stub(popular: const Left(NetworkFailure('offline')), topRated: const Right([film])),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, const MovieError(NetworkFailure('offline'))),
    );

    blocTest<MovieBloc, MovieState>(
      'a failure in the second request also becomes an error state',
      build: build,
      setUp: () => stub(popular: const Right([film]), topRated: const Left(ServerFailure('boom', statusCode: 500))),
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(bloc.state, const MovieError(ServerFailure('boom', statusCode: 500))),
    );
  });

  group('the recommendation', () {
    blocTest<MovieBloc, MovieState>(
      'is asked for as soon as the bloc is built, without waiting for the rows',
      build: build,
      verify: (_) => verify(() => getRecommended.call()).called(1),
    );

    blocTest<MovieBloc, MovieState>(
      'is every title the repository answered with, in its order',
      build: build,
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right([film]));
        stubRecommendation(const Right([recommended, secondPick]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) => expect(
        (bloc.state as MovieSuccess).recommended,
        const RecommendedMovieLoaded([recommended, secondPick]),
      ),
    );

    blocTest<MovieBloc, MovieState>(
      'that lands before the rows is carried into the state they emit',
      build: build,
      // The rows come back slowly, so the recommendation resolves while the
      // state is still MovieLoading and has nowhere to be put yet.
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right([film]), delay: const Duration(milliseconds: 20));
        stubRecommendation(const Right([recommended]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect((bloc.state as MovieSuccess).recommended, const RecommendedMovieLoaded([recommended])),
    );

    blocTest<MovieBloc, MovieState>(
      'that lands after the rows folds into the state already on screen',
      build: build,
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right([film]));
        stubRecommendation(const Right([recommended]), delay: const Duration(milliseconds: 20));
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      expect: () => const [
        MovieSuccess([film], [film], RecommendedMovieLoading()),
        MovieSuccess([film], [film], RecommendedMovieLoaded([recommended])),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'falls back to one top-rated title when the service has nothing to suggest yet',
      build: build,
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right(topRatedList));
        stubRecommendation(const Right([]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        // An account that has liked nothing yet still opens on a title rather
        // than on an empty block. Only one: a stand-in is not a list of
        // suggestions to step through.
        final recommended = state.recommended as RecommendedMovieLoaded;
        expect(recommended.movies, hasLength(1));
        expect(state.topFilmsList, contains(recommended.movies.single));
      },
    );

    blocTest<MovieBloc, MovieState>(
      'falls back even when the empty answer arrives before the rows do',
      build: build,
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right(topRatedList), delay: const Duration(milliseconds: 20));
        stubRecommendation(const Right([]));
      },
      act: (bloc) => bloc.add(GetMovies()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.topFilmsList, contains((state.recommended as RecommendedMovieLoaded).movies.single));
      },
    );

    blocTest<MovieBloc, MovieState>(
      'failing leaves the rows standing',
      build: build,
      setUp: () {
        stub(popular: const Right([film]), topRated: const Right([film]));
        stubRecommendation(const Left(AuthFailure('Sign in again.')));
      },
      act: (bloc) => bloc.add(GetMovies()),
      verify: (bloc) {
        final state = bloc.state as MovieSuccess;
        expect(state.recommended, const RecommendedMovieFailure('Sign in again.'));
        expect(state.popularFilmsList, const [film]);
      },
    );
  });
}
