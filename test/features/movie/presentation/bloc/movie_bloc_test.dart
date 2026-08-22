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

  const withPoster = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');
  const withoutPoster = MovieEntity(id: 2, title: 'B');

  setUp(() {
    getPopular = MockGetPopularMoviesUseCase();
    getTopRated = MockGetTopRatedMoviesUseCase();
  });

  MovieBloc build() => MovieBloc(getPopular, getTopRated);

  void stub({required Either<Failure, List<MovieEntity>> popular, required Either<Failure, List<MovieEntity>> topRated}) {
    when(() => getPopular.call()).thenAnswer((_) async => popular);
    when(() => getTopRated.call()).thenAnswer((_) async => topRated);
  }

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
    'never recommends a title without a poster',
    build: build,
    // The recommendation used to be picked from the unfiltered list, so a
    // posterless pick crashed the home screen on `posterPath!`.
    setUp: () => stub(
      popular: const Right([withPoster]),
      topRated: const Right([withoutPoster, withPoster, withoutPoster]),
    ),
    act: (bloc) => bloc.add(GetMovies()),
    verify: (bloc) => expect((bloc.state as MovieSuccess).recommendedMovie, withPoster),
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
    expect: () => const [MovieError(NetworkFailure('offline'))],
  );

  blocTest<MovieBloc, MovieState>(
    'a failure in the second request also becomes an error state',
    build: build,
    setUp: () => stub(popular: const Right([withPoster]), topRated: const Left(ServerFailure('boom', statusCode: 500))),
    act: (bloc) => bloc.add(GetMovies()),
    expect: () => const [MovieError(ServerFailure('boom', statusCode: 500))],
  );
}
