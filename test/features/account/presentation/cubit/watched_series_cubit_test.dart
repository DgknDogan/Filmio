import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/watched_series_cubit.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetWatchedSeriesUseCase getWatchedSeries;

  const title = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');

  setUp(() => getWatchedSeries = MockGetWatchedSeriesUseCase());

  WatchedSeriesCubit build() => WatchedSeriesCubit(getWatchedSeries);

  blocTest<WatchedSeriesCubit, WatchedSeriesState>(
    'loads the watched list on construction',
    build: build,
    setUp: () => when(() => getWatchedSeries.call()).thenAnswer((_) async => const Right([title])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      expect(cubit.state, const WatchedSeriesLoaded([title]));
      verify(() => getWatchedSeries.call()).called(1);
    },
  );

  blocTest<WatchedSeriesCubit, WatchedSeriesState>(
    'an empty list is a loaded state, not a failure',
    build: build,
    setUp: () => when(() => getWatchedSeries.call()).thenAnswer((_) async => const Right(<SeriesEntity>[])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const WatchedSeriesLoaded(<SeriesEntity>[])),
  );

  blocTest<WatchedSeriesCubit, WatchedSeriesState>(
    'a failure carries the message to the screen',
    build: build,
    setUp: () => when(() => getWatchedSeries.call()).thenAnswer((_) async => const Left(AuthFailure('no access'))),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const WatchedSeriesFailure('no access')),
  );
}
