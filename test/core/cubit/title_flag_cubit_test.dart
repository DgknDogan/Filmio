import 'dart:async';

import 'package:filmio/core/cubit/title_flag_cubit.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// A title is an int here: this is a test about the control, and an entity
/// would only add noise to it.
class _TestFlagCubit extends TitleFlagCubit<int> {
  _TestFlagCubit({
    required super.readList,
    required super.add,
    required super.remove,
    required super.title,
  }) : super(idOf: _identity);

  static int? _identity(int title) => title;
}

void main() {
  late Either<Failure, List<int>> stored;
  late Either<Failure, Unit> writeResult;
  late List<(int, bool)> writes;

  /// Lets a test hold the read open, so it can press the control while the
  /// list is still being fetched.
  Completer<void>? readGate;

  _TestFlagCubit build({int title = 1}) {
    return _TestFlagCubit(
      readList: () async {
        if (readGate != null) await readGate!.future;
        return stored;
      },
      add: (title) async {
        writes.add((title, true));
        return writeResult;
      },
      remove: (title) async {
        writes.add((title, false));
        return writeResult;
      },
      title: title,
    );
  }

  /// One turn of the event loop, which is all any of these awaits on.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    stored = const Right([1, 2]);
    writeResult = const Right(unit);
    writes = [];
    readGate = null;
  });

  group('when the screen opens', () {
    test('is filled for a title already in the list', () async {
      final cubit = build();
      await settle();

      expect(cubit.state, isTrue);
      await cubit.close();
    });

    test('is empty for a title that is not', () async {
      final cubit = build(title: 9);
      await settle();

      expect(cubit.state, isFalse);
      await cubit.close();
    });

    test('matches by id rather than by the whole stored title', () async {
      // The stored entry was read from a different endpoint at a different
      // time, so only the id can be relied on. Here that is all there is, and
      // the point is that a title absent from the list does not match.
      stored = const Right([2, 3]);
      final cubit = build();
      await settle();

      expect(cubit.state, isFalse);
      await cubit.close();
    });

    test('stays empty when the list cannot be read, rather than erroring', () async {
      stored = const Left(NetworkFailure('offline'));
      final cubit = build();
      await settle();

      // The page still works; the control just says nothing.
      expect(cubit.state, isFalse);
      await cubit.close();
    });
  });

  group('pressing it', () {
    test('fills at once and stays filled once the write lands', () async {
      final cubit = build(title: 9);
      await settle();

      final pressed = cubit.add();
      // Before the write has been given a chance to come back.
      expect(cubit.state, isTrue);

      await pressed;
      expect(cubit.state, isTrue);
      expect(writes, const [(9, true)]);
      await cubit.close();
    });

    test('goes back where it was when the write fails', () async {
      writeResult = const Left(NetworkFailure('offline'));
      final cubit = build(title: 9);
      await settle();

      await cubit.add();

      expect(cubit.state, isFalse);
      await cubit.close();
    });

    test('empties at once and stays empty once the write lands', () async {
      final cubit = build();
      await settle();

      final pressed = cubit.remove();
      expect(cubit.state, isFalse);

      await pressed;
      expect(cubit.state, isFalse);
      expect(writes, const [(1, false)]);
      await cubit.close();
    });

    test('goes back to filled when taking it out fails', () async {
      writeResult = const Left(NetworkFailure('offline'));
      final cubit = build();
      await settle();

      await cubit.remove();

      expect(cubit.state, isTrue);
      await cubit.close();
    });

    test('writes nothing when it is already in the state asked for', () async {
      final cubit = build();
      await settle();

      await cubit.add();

      expect(writes, isEmpty);
      await cubit.close();
    });
  });

  test('a press made while the list is still loading outranks the list', () async {
    readGate = Completer<void>();
    // The list does not have this title in it, so the read would leave the
    // control empty.
    stored = const Right([2, 3]);
    final cubit = build();

    // The reader presses before that answer arrives. The control is empty
    // while it waits, so pressing it means "add".
    await cubit.add();
    expect(cubit.state, isTrue);

    readGate!.complete();
    await settle();

    // The read came back saying "not in the list", and is ignored: the reader
    // has already said otherwise, and emptying the control under them would
    // undo a press that did reach the server.
    expect(cubit.state, isTrue);
    expect(writes, const [(1, true)]);
    await cubit.close();
  });
}
