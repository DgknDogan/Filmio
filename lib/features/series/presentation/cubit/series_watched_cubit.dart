import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/add_watched_series.dart';
import '../../domain/usecases/is_series_watched.dart';
import '../../domain/usecases/remove_watched_series.dart';

part 'series_watched_state.dart';

/// Whether the series on the details screen is on the user's watched list, and
/// the one control that changes it.
class SeriesWatchedCubit extends Cubit<SeriesWatchedState> {
  final IsSeriesWatchedUseCase _isSeriesWatchedUseCase;
  final AddWatchedSeriesUseCase _addWatchedSeriesUseCase;
  final RemoveWatchedSeriesUseCase _removeWatchedSeriesUseCase;
  final int? _seriesId;

  SeriesWatchedCubit(
    this._isSeriesWatchedUseCase,
    this._addWatchedSeriesUseCase,
    this._removeWatchedSeriesUseCase, {
    required int? seriesId,
  })  : _seriesId = seriesId,
        super(const SeriesWatchedState(isWatched: false, isBusy: true)) {
    _load();
  }

  Future<void> _load() async {
    final id = _seriesId;
    // Stored under its TMDB id; without one there is nothing to look up.
    if (id == null) {
      if (!isClosed) emit(const SeriesWatchedState(isWatched: false, isBusy: false));
      return;
    }

    final result = await _isSeriesWatchedUseCase.call(params: id);
    if (isClosed) return;

    result.fold(
      // Not worth a screen-level error: the page still works, the button just
      // offers to add.
      (failure) => emit(const SeriesWatchedState(isWatched: false, isBusy: false)),
      (isWatched) => emit(SeriesWatchedState(isWatched: isWatched, isBusy: false)),
    );
  }

  /// Adds the series when it is not on the list, removes it when it is.
  Future<void> toggle() async {
    final id = _seriesId;
    if (id == null || state.isBusy) return;

    final wasWatched = state.isWatched;
    emit(state.copyWith(isBusy: true));

    final result = wasWatched ? await _removeWatchedSeriesUseCase.call(params: id) : await _addWatchedSeriesUseCase.call(params: id);
    if (isClosed) return;

    result.fold(
      (failure) => emit(SeriesWatchedState(isWatched: wasWatched, isBusy: false)),
      (_) => emit(SeriesWatchedState(isWatched: !wasWatched, isBusy: false)),
    );
  }
}
