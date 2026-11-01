import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/cubit/title_list_cubit.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// A list of plain strings: this is a test about how the four list screens
/// behave, and a title entity would only add noise to it.
class _TestListCubit extends TitleListCubit<String> {
  _TestListCubit(super.readList);
}

void main() {
  late Either<Failure, List<String>> result;

  _TestListCubit build() => _TestListCubit(() async => result);

  setUp(() => result = const Right(['A']));

  blocTest<_TestListCubit, TitleListState<String>>(
    'reads the list on construction',
    build: build,
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TitleListLoaded(['A'])),
  );

  blocTest<_TestListCubit, TitleListState<String>>(
    'an empty list is a loaded state, not a failure',
    build: build,
    setUp: () => result = const Right([]),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TitleListLoaded(<String>[])),
  );

  blocTest<_TestListCubit, TitleListState<String>>(
    'a failure carries the message to the screen',
    build: build,
    setUp: () => result = const Left(AuthFailure('no access')),
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect(cubit.state, const TitleListFailure<String>('no access')),
  );

  /// Not a `blocTest`: that calls `act` before the read the constructor
  /// started has come back, so the second waiting state would be emitted while
  /// the cubit is still in the first one — and a cubit drops an emission equal
  /// to the state it is already in. What is being asserted here only means
  /// anything once the list is on screen.
  test('load puts the screen back into waiting before it reads again', () async {
    final cubit = build();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, const TitleListLoaded(['A']));

    final emitted = expectLater(
      cubit.stream,
      emitsInOrder(const [
        TitleListLoading<String>(),
        TitleListLoaded(['A'])
      ]),
    );

    await cubit.load();
    await emitted;

    await cubit.close();
  });

  group('refresh', () {
    /// What a screen calls when a title's own page has been closed. The reader
    /// is looking at the list as it happens, so a row going is the only change
    /// they should see.
    blocTest<_TestListCubit, TitleListState<String>>(
      'replaces the list without putting a spinner in front of it',
      build: build,
      act: (cubit) async {
        result = const Right([]);
        await cubit.refresh();
      },
      wait: const Duration(milliseconds: 10),
      expect: () => const [
        TitleListLoaded(['A']),
        // No TitleListLoading in between: that would read as a flicker rather
        // than as progress.
        TitleListLoaded(<String>[]),
      ],
    );

    blocTest<_TestListCubit, TitleListState<String>>(
      'leaves the list on screen when the read fails',
      build: build,
      act: (cubit) async {
        result = const Left(NetworkFailure('offline'));
        await cubit.refresh();
      },
      wait: const Duration(milliseconds: 10),
      // The list already on screen is the better answer to a failed refresh.
      verify: (cubit) => expect(cubit.state, const TitleListLoaded(['A'])),
    );
  });
}
