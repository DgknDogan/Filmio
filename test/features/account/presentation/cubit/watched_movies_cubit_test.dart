import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/watched_movies_cubit.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetWatchedMoviesUseCase getWatchedMovies;

  const title = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

  setUp(() => getWatchedMovies = MockGetWatchedMoviesUseCase());

  WatchedMoviesCubit build() => WatchedMoviesCubit(getWatchedMovies);

  blocTest<WatchedMoviesCubit, WatchedMoviesState>(
    'loads the watched list on construction',
    build: build,
    setUp: () => when(() => getWatchedMovies.call()).thenAnswer((_) async => const Right([title])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      expect(cubit.state, const WatchedMoviesLoaded([title]));
      verify(() => getWatchedMovies.call()).called(1);
    },
  );

  blocTest<WatchedMoviesCubit, WatchedMoviesState>(
    'an empty list is a loaded state, not a failure',
    build: build,
    setUp: () => when(() => getWatchedMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const WatchedMoviesLoaded(<MovieEntity>[])),
  );

  blocTest<WatchedMoviesCubit, WatchedMoviesState>(
    'a failure carries the message to the screen',
    build: build,
    setUp: () => when(() => getWatchedMovies.call()).thenAnswer((_) async => const Left(AuthFailure('no access'))),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const WatchedMoviesFailure('no access')),
  );
}
