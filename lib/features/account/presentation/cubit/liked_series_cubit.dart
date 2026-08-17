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

  Future<void> getLikedSeries() async {
    if (!isClosed) emit(const LikedSeriesLoading());

    final result = await _getLikedSeriesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) => emit(LikedSeriesFailure(failure.message)),
      (series) => emit(LikedSeriesLoaded(series)),
    );
  }
}
