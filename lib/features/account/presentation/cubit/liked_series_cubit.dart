import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../series/domain/entities/series_entity.dart';
import '../../../series/domain/usecases/get_liked_series.dart';

part 'liked_series_state.dart';

class LikedSeriesCubit extends Cubit<LikedSeriesState> {
  final GetLikedSeriesUseCase _getLikedSeriesUseCase;

  LikedSeriesCubit(this._getLikedSeriesUseCase) : super(const LikedSeriesLoading()) {
    getLikedSeries();
  }

  /// Reads the list from the start, with the screen showing that it is
  /// waiting.
  Future<void> getLikedSeries() {
    if (!isClosed) emit(const LikedSeriesLoading());

    return _read();
  }

  /// Reads the list again without the screen saying so.
  ///
  /// This is what the screen calls when a title's own page has been closed:
  /// the like may have been taken back while it was open, and the row has to
  /// go — but the reader is looking at the list as they arrive back on it, and
  /// replacing it with a spinner for the length of one document read reads as
  /// a flicker rather than as progress. A failure is swallowed for the same
  /// reason: the list already on screen is the better answer.
  Future<void> refresh() => _read(quietly: true);

  Future<void> _read({bool quietly = false}) async {
    final result = await _getLikedSeriesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!quietly) emit(LikedSeriesFailure(failure.message));
      },
      (series) => emit(LikedSeriesLoaded(series)),
    );
  }
}
