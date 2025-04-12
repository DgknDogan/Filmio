import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../../../core/resources/data_state.dart';

import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/get_popular_series.dart';
import '../../domain/usecases/get_top_rated_series.dart';

part 'series_event.dart';
part '../../states/series_state.dart';

class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final GetTopRatedSeriesUseCase _getTopRatedSeriesUseCase;
  final GetPopularSeriesUseCase _getPopularSeriesUseCase;
  SeriesBloc(this._getPopularSeriesUseCase, this._getTopRatedSeriesUseCase) : super(SeriesLoading()) {
    on<GetSeries>((event, emit) async {
      await onGetSeries(event, emit);
    });
  }

  Future<void> onGetSeries(GetSeries event, Emitter<SeriesState> emit) async {
    final popularSeriesDataState = await _getPopularSeriesUseCase.call();
    final topRatedSeriesDataState = await _getTopRatedSeriesUseCase.call();

    if (popularSeriesDataState is DataSuccess && topRatedSeriesDataState is DataSuccess) {
      final recommendedSeries = topRatedSeriesDataState.data![Random().nextInt(topRatedSeriesDataState.data!.length)];
      emit(
        SeriesSuccess(
          popularSeriesDataState.data!,
          topRatedSeriesDataState.data!,
          recommendedSeries,
        ),
      );
    }
    if (popularSeriesDataState is DataError) {
      emit(SeriesError(popularSeriesDataState.error!));
    }
    if (topRatedSeriesDataState is DataError) {
      emit(SeriesError(topRatedSeriesDataState.error!));
    }
  }
}
