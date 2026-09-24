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

  group('refresh', () {
    /// What the screen calls when a title's own page has been closed. The
    /// reader is looking at the list as it happens, so a row going is the only
    /// change they should see.
    blocTest<LikedMoviesCubit, LikedMoviesState>(
      'replaces the list without putting a spinner in front of it',
      build: build,
      setUp: () => when(() => getLikedMovies.call()).thenAnswer((_) async => const Right([movie])),
      act: (cubit) async {
        when(() => getLikedMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[]));
        await cubit.refresh();
      },
      wait: const Duration(milliseconds: 10),
      expect: () => const [
        LikedMoviesLoaded([movie]),
        // No LikedMoviesLoading in between: that would read as a flicker rather
        // than as progress.
        LikedMoviesLoaded(<MovieEntity>[]),
      ],
    );

    blocTest<LikedMoviesCubit, LikedMoviesState>(
      'leaves the list on screen when the read fails',
      build: build,
      setUp: () => when(() => getLikedMovies.call()).thenAnswer((_) async => const Right([movie])),
      act: (cubit) async {
        when(() => getLikedMovies.call()).thenAnswer((_) async => const Left(NetworkFailure('offline')));
        await cubit.refresh();
      },
      wait: const Duration(milliseconds: 10),
      // The list already on screen is the better answer to a failed refresh.
      verify: (cubit) => expect(cubit.state, const LikedMoviesLoaded([movie])),
    );
  });
}
