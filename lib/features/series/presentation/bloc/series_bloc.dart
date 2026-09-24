import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/get_popular_series.dart';
import '../../domain/usecases/get_recommended_series.dart';
import '../../domain/usecases/get_top_rated_series.dart';

part 'series_event.dart';
part 'series_state.dart';

class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final GetTopRatedSeriesUseCase _getTopRatedSeriesUseCase;
  final GetPopularSeriesUseCase _getPopularSeriesUseCase;
  final GetRecommendedSeriesUseCase _getRecommendedSeriesUseCase;

  /// The recommendation and the rows are two independent requests against two
  /// different services, and either can land first. Holding the latest
  /// recommendation here is what lets whichever finishes second carry the
  /// other's result into the state it emits.
  RecommendedSeriesState _recommended = const RecommendedSeriesLoading();

  SeriesBloc(
    this._getPopularSeriesUseCase,
    this._getTopRatedSeriesUseCase,
    this._getRecommendedSeriesUseCase,
  ) : super(const SeriesLoading()) {
    on<GetSeries>((event, emit) async {
      await onGetSeries(event, emit);
    });

    on<GetRecommendedSeries>((event, emit) async {
      await onGetRecommendedSeries(event, emit);
    });

    add(GetRecommendedSeries());
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

  /// The block at the head of the tab. Which titles those are — and whether
  /// they came from the service or from what it last answered — is the
  /// repository's business; all this has to know is the three ways it can end.
  Future<void> onGetRecommendedSeries(GetRecommendedSeries event, Emitter<SeriesState> emit) async {
    final result = await _getRecommendedSeriesUseCase.call();

    result.fold(
      (failure) => _emitRecommended(RecommendedSeriesFailure(failure.message), emit),
      (series) => _emitRecommended(
        series.isEmpty ? const RecommendedSeriesEmpty() : RecommendedSeriesLoaded(series),
        emit,
      ),
    );
  }

  /// Keeps the recommendation for the state that has not been built yet, and
  /// folds it into the one already on screen if the rows got there first.
  void _emitRecommended(RecommendedSeriesState recommended, Emitter<SeriesState> emit) {
    _recommended = recommended;

    final current = state;
    if (current is SeriesSuccess) {
      emit(current.copyWith(recommended: _resolve(recommended, current.topSeriesList)));
    }
  }

  /// The recommendation to show over [topRated].
  ///
  /// The service having nothing to suggest is not a reason for the tab to open
  /// on an empty block: an account that has liked too little yet gets a
  /// top-rated series, which is what the head of the tab held before there was
  /// a service to ask. Only the one: a stand-in is not a list of suggestions
  /// to step through. A failure is left as it is — that one is worth saying.
  RecommendedSeriesState _resolve(RecommendedSeriesState recommended, List<SeriesEntity> topRated) {
    if (recommended is! RecommendedSeriesEmpty || topRated.isEmpty) return recommended;

    return RecommendedSeriesLoaded([topRated[Random().nextInt(topRated.length)]]);
  }

  SeriesState _success(List<SeriesEntity> popularSeries, List<SeriesEntity> topRatedSeries) {
    // The repository has already dropped anything the app cannot draw, so an
    // empty list here means the catalogue answered with nothing usable at all.
    if (topRatedSeries.isEmpty) {
      return const SeriesError(ServerFailure('No series to show right now.'));
    }

    return SeriesSuccess(popularSeries, topRatedSeries, _resolve(_recommended, topRatedSeries));
  }
}
