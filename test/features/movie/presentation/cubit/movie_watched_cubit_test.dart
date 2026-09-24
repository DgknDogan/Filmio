import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/presentation/cubit/movie_watched_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockIsMovieWatchedUseCase isWatched;
  late MockAddWatchedMovieUseCase add;
  late MockRemoveWatchedMovieUseCase remove;

  const id = 7;

  setUp(() {
    isWatched = MockIsMovieWatchedUseCase();
    add = MockAddWatchedMovieUseCase();
    remove = MockRemoveWatchedMovieUseCase();
  });

  MovieWatchedCubit build({int? movieId = id}) => MovieWatchedCubit(isWatched, add, remove, movieId: movieId);

  group('on construction', () {
    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'reads whether the movie is on the list',
      build: build,
      setUp: () => when(() => isWatched.call(params: id)).thenAnswer((_) async => const Right(true)),
      wait: const Duration(milliseconds: 10),
      expect: () => const [MovieWatchedState(isWatched: true, isBusy: false)],
    );

    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'a failed read leaves the button offering to add',
      build: build,
      setUp: () => when(() => isWatched.call(params: id)).thenAnswer((_) async => const Left(AuthFailure('signed out'))),
      wait: const Duration(milliseconds: 10),
      expect: () => const [MovieWatchedState(isWatched: false, isBusy: false)],
    );

    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'a movie with no id is never looked up',
      build: () => build(movieId: null),
      verify: (cubit) {
        expect(cubit.state, const MovieWatchedState(isWatched: false, isBusy: false));
        verifyNever(() => isWatched.call(params: any(named: 'params')));
      },
    );
  });

  group('toggle', () {
    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'adds a movie that is not on the list',
      build: build,
      setUp: () {
        when(() => isWatched.call(params: id)).thenAnswer((_) async => const Right(false));
        when(() => add.call(params: id)).thenAnswer((_) async => const Right(unit));
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.toggle();
      },
      skip: 1,
      expect: () => const [
        MovieWatchedState(isWatched: false, isBusy: true),
        MovieWatchedState(isWatched: true, isBusy: false),
      ],
      verify: (_) => verifyNever(() => remove.call(params: any(named: 'params'))),
    );

    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'removes a movie that is on the list',
      build: build,
      setUp: () {
        when(() => isWatched.call(params: id)).thenAnswer((_) async => const Right(true));
        when(() => remove.call(params: id)).thenAnswer((_) async => const Right(unit));
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.toggle();
      },
      skip: 1,
      expect: () => const [
        MovieWatchedState(isWatched: true, isBusy: true),
        MovieWatchedState(isWatched: false, isBusy: false),
      ],
      verify: (_) => verifyNever(() => add.call(params: any(named: 'params'))),
    );

    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'a failed write puts the flag back as it was',
      build: build,
      setUp: () {
        when(() => isWatched.call(params: id)).thenAnswer((_) async => const Right(false));
        when(() => add.call(params: id)).thenAnswer((_) async => const Left(NetworkFailure()));
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.toggle();
      },
      skip: 1,
      expect: () => const [
        MovieWatchedState(isWatched: false, isBusy: true),
        MovieWatchedState(isWatched: false, isBusy: false),
      ],
    );

    blocTest<MovieWatchedCubit, MovieWatchedState>(
      'does nothing while the first read is still out',
      build: build,
      setUp: () =>
          when(() => isWatched.call(params: id)).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50), () => const Right(false))),
      act: (cubit) => cubit.toggle(),
      expect: () => const <MovieWatchedState>[],
      verify: (_) => verifyNever(() => add.call(params: any(named: 'params'))),
    );
  });
}
