import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/liked_series_cubit.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetLikedSeriesUseCase getLikedSeries;

  const series = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');

  setUp(() => getLikedSeries = MockGetLikedSeriesUseCase());

  LikedSeriesCubit build() => LikedSeriesCubit(getLikedSeries);

  blocTest<LikedSeriesCubit, LikedSeriesState>(
    'loads the liked list on construction',
    build: build,
    setUp: () => when(() => getLikedSeries.call()).thenAnswer((_) async => const Right([series])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      expect(cubit.state, const LikedSeriesLoaded([series]));
      verify(() => getLikedSeries.call()).called(1);
    },
  );

  blocTest<LikedSeriesCubit, LikedSeriesState>(
    'an empty list is a loaded state, not a failure',
    build: build,
    setUp: () => when(() => getLikedSeries.call()).thenAnswer((_) async => const Right(<SeriesEntity>[])),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const LikedSeriesLoaded(<SeriesEntity>[])),
  );

  blocTest<LikedSeriesCubit, LikedSeriesState>(
    'a failure carries the message to the screen',
    build: build,
    setUp: () => when(() => getLikedSeries.call()).thenAnswer((_) async => const Left(AuthFailure('no access'))),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const LikedSeriesFailure('no access')),
  );
}
