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
  const similarWithoutPoster = MovieEntity(id: 3, title: 'C');

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
  });

  group('similar titles', () {
    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'keeps only titles with a poster',
      build: build,
      setUp: () => when(() => getSimilar.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([similar, similarWithoutPoster])),
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
    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a successful like flips the flag',
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (cubit) => cubit.likeMovie(movie: movie),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isTrue),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a failed like leaves the flag alone rather than lying to the user',
      build: build,
      setUp: () => when(() => like.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) => cubit.likeMovie(movie: movie),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isFalse),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'a successful dislike clears the flag',
      build: build,
      setUp: () => when(() => getLiked.call()).thenAnswer((_) async => const Right([movie])),
      wait: const Duration(milliseconds: 10),
      act: (cubit) => cubit.dislikeMovie(movie: movie),
      verify: (cubit) => expect(cubit.state.isMovieLiked, isFalse),
    );
  });
}
