import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../resource/failure.dart';

/// Whether one title is in one of the account's lists, and the control that
/// puts it in or takes it out.
///
/// Subclassed rather than used directly so a screen showing both a heart and a
/// bookmark can provide one of each: `TitleFlagCubit<MovieEntity>` would name
/// both.
abstract class TitleFlagCubit<T> extends Cubit<bool> {
  final Future<Either<Failure, List<T>>> Function() _readList;
  final Future<Either<Failure, Unit>> Function(T title) _add;
  final Future<Either<Failure, Unit>> Function(T title) _remove;
  final T _title;
  final int? Function(T title) _idOf;

  /// Whether the control has been pressed on this screen. What the reader
  /// chose outranks what the list said when the screen opened.
  bool _readerHasChosen = false;

  TitleFlagCubit({
    required Future<Either<Failure, List<T>>> Function() readList,
    required Future<Either<Failure, Unit>> Function(T title) add,
    required Future<Either<Failure, Unit>> Function(T title) remove,
    required T title,
    required int? Function(T title) idOf,
  })  : _readList = readList,
        _add = add,
        _remove = remove,
        _title = title,
        _idOf = idOf,
        super(false) {
    _readFlag();
  }

  Future<void> _readFlag() async {
    final result = await _readList();
    // The list takes a moment to read, and a reader who pressed the control
    // inside that moment has already said what they want. Their answer stands.
    if (isClosed || _readerHasChosen) return;

    result.fold(
      // A failure here is not worth a screen-level error: the page still
      // works, the control just stays empty.
      (failure) => emit(false),
      // By id, not by whole title: the entry the list stored was read from a
      // different endpoint at a different time, so its rating and popularity
      // have moved on even though it is the same title.
      (titles) => emit(titles.any((stored) => _idOf(stored) == _idOf(_title))),
    );
  }

  Future<void> add() => _set(true);

  Future<void> remove() => _set(false);

  /// Fills or empties the control at once, then writes it.
  ///
  /// The write is a Firestore round trip, and waiting for it leaves the
  /// control unmoved for the best part of a second after the tap — long enough
  /// for a reader to conclude the button is broken and press it again. The tap
  /// is also the only thing that can be wrong here: the reader knows what they
  /// meant, and the only question is whether it reached the server. So the
  /// control answers immediately and goes back to where it was if it did not.
  Future<void> _set(bool isIncluded) async {
    final was = state;
    if (was == isIncluded) return;

    _readerHasChosen = true;
    emit(isIncluded);

    final result = isIncluded ? await _add(_title) : await _remove(_title);
    if (isClosed) return;

    result.fold((failure) => emit(was), (_) {});
  }
}
