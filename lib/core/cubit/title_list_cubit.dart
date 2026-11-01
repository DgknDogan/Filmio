import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../resource/failure.dart';

part 'title_list_state.dart';

/// One screen showing a list of titles an account keeps.
///
/// Every one of those screens does the same three things — read the list when
/// it opens, read it again quietly when the reader comes back from a title's
/// own page, and say so when the read fails — so they are all this cubit with
/// a different read passed in. There were two copies of this before the
/// watchlist, and the watchlist would have made four.
///
/// Subclassed rather than used directly so each screen still has a type of its
/// own to provide and look up: `TitleListCubit<MovieEntity>` would name both
/// the liked films and the films to watch, and a `BlocProvider` cannot tell
/// those apart.
abstract class TitleListCubit<T> extends Cubit<TitleListState<T>> {
  final Future<Either<Failure, List<T>>> Function() _readList;

  TitleListCubit(this._readList) : super(TitleListLoading<T>()) {
    load();
  }

  /// Reads the list from the start, with the screen showing that it is
  /// waiting.
  Future<void> load() {
    if (!isClosed) emit(TitleListLoading<T>());

    return _read();
  }

  /// Reads the list again without the screen saying so.
  ///
  /// This is what the screen calls when a title's own page has been closed:
  /// the title may have been taken out of the list while it was open, and the
  /// row has to go — but the reader is looking at the list as they arrive back
  /// on it, and replacing it with a spinner for the length of one document
  /// read reads as a flicker rather than as progress. A failure is swallowed
  /// for the same reason: the list already on screen is the better answer.
  Future<void> refresh() => _read(quietly: true);

  Future<void> _read({bool quietly = false}) async {
    final result = await _readList();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!quietly) emit(TitleListFailure<T>(failure.message));
      },
      (titles) => emit(TitleListLoaded<T>(titles)),
    );
  }
}
