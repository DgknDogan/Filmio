import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/presentation/cubit/series_watched_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockIsSeriesWatchedUseCase isWatched;
  late MockAddWatchedSeriesUseCase add;
  late MockRemoveWatchedSeriesUseCase remove;

  const id = 7;

  setUp(() {
    isWatched = MockIsSeriesWatchedUseCase();
    add = MockAddWatchedSeriesUseCase();
    remove = MockRemoveWatchedSeriesUseCase();
  });

  SeriesWatchedCubit build({int? seriesId = id}) => SeriesWatchedCubit(isWatched, add, remove, seriesId: seriesId);

  group('on construction', () {
    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'reads whether the series is on the list',
      build: build,
      setUp: () => when(() => isWatched.call(params: id)).thenAnswer((_) async => const Right(true)),
      wait: const Duration(milliseconds: 10),
      expect: () => const [SeriesWatchedState(isWatched: true, isBusy: false)],
    );

    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'a failed read leaves the button offering to add',
      build: build,
      setUp: () => when(() => isWatched.call(params: id)).thenAnswer((_) async => const Left(AuthFailure('signed out'))),
      wait: const Duration(milliseconds: 10),
      expect: () => const [SeriesWatchedState(isWatched: false, isBusy: false)],
    );

    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'a series with no id is never looked up',
      build: () => build(seriesId: null),
      verify: (cubit) {
        expect(cubit.state, const SeriesWatchedState(isWatched: false, isBusy: false));
        verifyNever(() => isWatched.call(params: any(named: 'params')));
      },
    );
  });

  group('toggle', () {
    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'adds a series that is not on the list',
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
        SeriesWatchedState(isWatched: false, isBusy: true),
        SeriesWatchedState(isWatched: true, isBusy: false),
      ],
      verify: (_) => verifyNever(() => remove.call(params: any(named: 'params'))),
    );

    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'removes a series that is on the list',
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
        SeriesWatchedState(isWatched: true, isBusy: true),
        SeriesWatchedState(isWatched: false, isBusy: false),
      ],
      verify: (_) => verifyNever(() => add.call(params: any(named: 'params'))),
    );

    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
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
        SeriesWatchedState(isWatched: false, isBusy: true),
        SeriesWatchedState(isWatched: false, isBusy: false),
      ],
    );

    blocTest<SeriesWatchedCubit, SeriesWatchedState>(
      'does nothing while the first read is still out',
      build: build,
      setUp: () =>
          when(() => isWatched.call(params: id)).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50), () => const Right(false))),
      act: (cubit) => cubit.toggle(),
      expect: () => const <SeriesWatchedState>[],
      verify: (_) => verifyNever(() => add.call(params: any(named: 'params'))),
    );
  });
}
