import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/presentation/cubit/movie_details_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLikeMovieUseCase like;
  late MockDislikeMovieUseCase dislike;
  late MockGetLikedMoviesUseCase getLiked;
  late MockGetSimilarMoviesUseCase getSimilar;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');
  const similar = MovieEntity(id: 2, title: 'B', posterPath: '/b.jpg');

  setUpAll(registerCommonFallbacks);

  setUp(() {
    like = MockLikeMovieUseCase();
    dislike = MockDislikeMovieUseCase();
    getLiked = MockGetLikedMoviesUseCase();
    getSimilar = MockGetSimilarMoviesUseCase();

    when(() => getLiked.call()).thenAnswer((_) async => const Right(<MovieEntity>[]));
    when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(<MovieEntity>[]));
    when(() => like.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
    when(() => dislike.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
  });

  MovieDetailsCubit build() => MovieDetailsCubit(like, getLiked, movie, dislike, getSimilar);

  group('on construction', () {
    // Both of these used to be dead: the guards read `if (!isClosed) return;`,
    // so an open cubit returned immediately and neither call ever ran.
    test('asks for the liked list and the similar titles', () async {
      final cubit = build();
      await Future<void>.delayed(Duration.zero);

      verify(() => getLiked.call()).called(1);
      verify(() => getSimilar.call(params: 1)).called(1);
      await cubit.close();
    });

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'marks the film liked when it is in the liked list',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([movie])),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'marks it liked even though the list stored it with different details',
      build: build,
      // The entry was written from a list endpoint weeks ago; this screen's
      // film came from the detail endpoint just now, so its rating and
      // popularity have moved on. Matching whole titles left the heart empty
      // on a film the reader had certainly liked.
      setUp: () => when(() => getLiked.call()).thenAnswer(
        (_) async => const Right([MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg', popularity: 41.2, voteAverage: 7.4)]),
      ),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );
  });

  group('similar titles', () {
    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'carries the row the repository answered with',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([similar])),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.similars, const SimilarMoviesLoaded([similar])),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a failure is distinguishable from an empty result',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.similars, const SimilarMoviesFailure('offline')),
    );
  });

  group('liking', () {
    /// The screen has finished reading the liked list, which is the state a
    /// reader is actually looking at when they reach for the heart.
    Future<void> settled(MovieDetailsCubit cubit, Future<void> Function() act) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await act();
    }

    blocTest<MovieDetailsCubit, MovieDetailsState>(
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
        final writing = cubit.likeMovie(movie: movie);
        expect(cubit.state.isMovieLiked, isTrue);
        await writing;
      }),
      wait: const Duration(milliseconds: 600),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a failed like puts the heart back rather than lying to the user',
      build: build,
      setUp: () => when(() => like.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      act: (cubit) => settled(cubit, () => cubit.likeMovie(movie: movie)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isFalse),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a successful dislike clears the flag',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([movie])),
      act: (cubit) => settled(cubit, () => cubit.dislikeMovie(movie: movie)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        verify(() => dislike.call(params: movie)).called(1);
        expect(cubit.state.isMovieLiked, isFalse);
      },
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a failed dislike puts the heart back too',
      build: build,
      setUp: () {
        when(() => getLiked.call()).thenAnswer((_) async => const Right([movie]));
        when(() => dislike.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      },
      act: (cubit) => settled(cubit, () => cubit.dislikeMovie(movie: movie)),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a tap that beats the liked list is not undone by it',
      build: build,
      // The list takes a moment to read; a reader who presses the heart inside
      // that moment used to watch it empty itself again when the read landed.
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return const Right(<MovieEntity>[]);
      }),
      act: (cubit) => cubit.likeMovie(movie: movie),
      wait: const Duration(milliseconds: 80),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'pressing the heart for what it already says does not reach the server',
      build: build,
      act: (cubit) => settled(cubit, () => cubit.dislikeMovie(movie: movie)),
      wait: const Duration(milliseconds: 10),
      verify: (_) => verifyNever(() => dislike.call(params: any(named: 'params'))),
    );
  });
}
