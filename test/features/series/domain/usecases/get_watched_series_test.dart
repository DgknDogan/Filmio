import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/domain/usecases/get_watched_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchedSeriesRepository watched;
  late MockSeriesRepository catalogue;
  late GetWatchedSeriesUseCase useCase;

  const first = SeriesEntity(id: 1, name: 'A');
  const second = SeriesEntity(id: 2, name: 'A');

  setUp(() {
    watched = MockWatchedSeriesRepository();
    catalogue = MockSeriesRepository();
    useCase = GetWatchedSeriesUseCase(watched, catalogue);
  });

  test('looks every id up and keeps the order they were marked in', () async {
    when(() => watched.getWatchedSeriesIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getSeriesDetails(seriesId: 1)).thenAnswer((_) async => const Right(first));
    when(() => catalogue.getSeriesDetails(seriesId: 2)).thenAnswer((_) async => const Right(second));

    expect((await useCase.call()).getRight().toNullable(), [second, first]);
  });

  test('an empty list asks the catalogue for nothing', () async {
    when(() => watched.getWatchedSeriesIds()).thenAnswer((_) async => const Right([]));

    expect((await useCase.call()).getRight().toNullable(), isEmpty);
    verifyNever(() => catalogue.getSeriesDetails(seriesId: any(named: 'seriesId')));
  });

  test('a title the catalogue cannot answer for is left out', () async {
    when(() => watched.getWatchedSeriesIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getSeriesDetails(seriesId: 2)).thenAnswer((_) async => const Left(ServerFailure('Not found.')));
    when(() => catalogue.getSeriesDetails(seriesId: 1)).thenAnswer((_) async => const Right(first));

    expect((await useCase.call()).getRight().toNullable(), [first]);
  });

  test('fails with the newest title\'s reason only when none comes back', () async {
    when(() => watched.getWatchedSeriesIds()).thenAnswer((_) async => const Right([2, 1]));
    when(() => catalogue.getSeriesDetails(seriesId: 2)).thenAnswer((_) async => const Left(NetworkFailure()));
    when(() => catalogue.getSeriesDetails(seriesId: 1)).thenAnswer((_) async => const Left(ServerFailure('Not found.')));

    expect((await useCase.call()).getLeft().toNullable(), const NetworkFailure());
  });

  test('a failure reading the ids is passed on', () async {
    when(() => watched.getWatchedSeriesIds()).thenAnswer((_) async => const Left(AuthFailure('signed out')));

    expect((await useCase.call()).getLeft().toNullable(), const AuthFailure('signed out'));
  });
}
