import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../series/domain/entities/series_entity.dart';
import '../../../series/domain/usecases/get_watched_series.dart';

part 'watched_series_state.dart';

class WatchedSeriesCubit extends Cubit<WatchedSeriesState> {
  final GetWatchedSeriesUseCase _getWatchedSeriesUseCase;

  WatchedSeriesCubit(this._getWatchedSeriesUseCase) : super(const WatchedSeriesLoading()) {
    getWatchedSeries();
  }

  Future<void> getWatchedSeries() async {
    if (!isClosed) emit(const WatchedSeriesLoading());

    final result = await _getWatchedSeriesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) => emit(WatchedSeriesFailure(failure.message)),
      (series) => emit(WatchedSeriesLoaded(series)),
    );
  }
}
