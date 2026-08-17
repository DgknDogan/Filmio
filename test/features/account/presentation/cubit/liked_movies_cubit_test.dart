import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/liked_movies_cubit.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetLikedMoviesUseCase getLikedMovies;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

  setUp(() => getLikedMovies = MockGetLikedMoviesUseCase());

  LikedMoviesCubit build() => LikedMoviesCubit(getLikedMovies);

  blocTest<LikedMoviesCubit, LikedMoviesState>(
    'loads the liked list on construction',
    build: build,
    setUp: () => when(() => getLikedMovies.call()).thenAnswer((_) async => const Right([movie])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      expect(cubit.state, const LikedMoviesLoaded([movie]));
      verify(() => getLikedMovies.call()).called(1);
    },
  );

  blocTest<LikedMoviesCubit, LikedMoviesState>(
    'an empty list is a loaded state, not a failure',
    build: build,
    setUp: () => when(() => getLikedMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const LikedMoviesLoaded(<MovieEntity>[])),
  );

  blocTest<LikedMoviesCubit, LikedMoviesState>(
    'a failure carries the message to the screen',
    build: build,
    setUp: () => when(() => getLikedMovies.call()).thenAnswer((_) async => const Left(AuthFailure('no access'))),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const LikedMoviesFailure('no access')),
  );
}
