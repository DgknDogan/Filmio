import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/domain/usecases/get_watched_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchedMoviesRepository watched;
  late MockMovieRepository catalogue;
  late GetWatchedMoviesUseCase useCase;

  const first = MovieEntity(id: 1, title: 'A');
  const second = MovieEntity(id: 2, title: 'A');

  setUp(() {
    watched = MockWatchedMoviesRepository();
    catalogue = MockMovieRepository();
    useCase = GetWatchedMoviesUseCase(watched, catalogue);
  });

  test('looks every id up and keeps the order they were marked in', () async {
    when(() => watched.getWatchedMovieIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getMovieDetails(movieId: 1)).thenAnswer((_) async => const Right(first));
    when(() => catalogue.getMovieDetails(movieId: 2)).thenAnswer((_) async => const Right(second));

    expect((await useCase.call()).getRight().toNullable(), [second, first]);
  });

  test('an empty list asks the catalogue for nothing', () async {
    when(() => watched.getWatchedMovieIds()).thenAnswer((_) async => const Right([]));

    expect((await useCase.call()).getRight().toNullable(), isEmpty);
    verifyNever(() => catalogue.getMovieDetails(movieId: any(named: 'movieId')));
  });

  test('a title the catalogue cannot answer for is left out', () async {
    when(() => watched.getWatchedMovieIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getMovieDetails(movieId: 2)).thenAnswer((_) async => const Left(ServerFailure('Not found.')));
    when(() => catalogue.getMovieDetails(movieId: 1)).thenAnswer((_) async => const Right(first));

    expect((await useCase.call()).getRight().toNullable(), [first]);
  });

  test('fails with the newest title\'s reason only when none comes back', () async {
    when(() => watched.getWatchedMovieIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getMovieDetails(movieId: 2)).thenAnswer((_) async => const Left(NetworkFailure()));
    when(() => catalogue.getMovieDetails(movieId: 1)).thenAnswer((_) async => const Left(ServerFailure('Not found.')));

    expect((await useCase.call()).getLeft().toNullable(), const NetworkFailure());
  });

  test('a failure reading the ids is passed on', () async {
    when(() => watched.getWatchedMovieIds()).thenAnswer((_) async => const Left(AuthFailure('signed out')));

    expect((await useCase.call()).getLeft().toNullable(), const AuthFailure('signed out'));
  });
}
