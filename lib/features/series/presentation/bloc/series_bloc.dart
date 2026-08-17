import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/get_popular_series.dart';
import '../../domain/usecases/get_top_rated_series.dart';

part 'series_event.dart';
part 'series_state.dart';

class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final GetTopRatedSeriesUseCase _getTopRatedSeriesUseCase;
  final GetPopularSeriesUseCase _getPopularSeriesUseCase;

  SeriesBloc(this._getPopularSeriesUseCase, this._getTopRatedSeriesUseCase) : super(const SeriesLoading()) {
    on<GetSeries>((event, emit) async {
      await onGetSeries(event, emit);
    });
  }

  Future<void> onGetSeries(GetSeries event, Emitter<SeriesState> emit) async {
    final popularResult = await _getPopularSeriesUseCase.call();
    final topRatedResult = await _getTopRatedSeriesUseCase.call();

    popularResult.fold(
      (failure) => emit(SeriesError(failure)),
      (popularSeries) => topRatedResult.fold(
        (failure) => emit(SeriesError(failure)),
        (topRatedSeries) => emit(_success(popularSeries, topRatedSeries)),
      ),
    );
  }

  SeriesState _success(List<SeriesEntity> popularSeries, List<SeriesEntity> topRatedSeries) {
    final withPoster = topRatedSeries.where((series) => series.posterPath != null).toList();
    if (withPoster.isEmpty) {
      return const SeriesError(ServerFailure('No series to show right now.'));
    }

    return SeriesSuccess(
      popularSeries.where((series) => series.posterPath != null).toList(),
      withPoster,
      withPoster[Random().nextInt(withPoster.length)],
    );
  }
}
