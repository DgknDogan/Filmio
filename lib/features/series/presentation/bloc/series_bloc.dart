import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/get_popular_series.dart';
import '../../domain/usecases/get_recommended_series_ids.dart';
import '../../domain/usecases/get_series_details.dart';
import '../../domain/usecases/get_top_rated_series.dart';

part 'series_event.dart';
part 'series_state.dart';

class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final GetTopRatedSeriesUseCase _getTopRatedSeriesUseCase;
  final GetPopularSeriesUseCase _getPopularSeriesUseCase;
  final GetRecommendedSeriesIdsUseCase _getRecommendedSeriesIdsUseCase;
  final GetSeriesDetailsUseCase _getSeriesDetailsUseCase;

  /// The recommendation and the rows are two independent requests against two
  /// different services, and either can land first. Holding the latest
  /// recommendation here is what lets whichever finishes second carry the
  /// other's result into the state it emits.
  RecommendedSeriesState _recommended = const RecommendedSeriesLoading();

  SeriesBloc(
    this._getPopularSeriesUseCase,
    this._getTopRatedSeriesUseCase,
    this._getRecommendedSeriesIdsUseCase,
    this._getSeriesDetailsUseCase,
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

  /// Two calls: Filmio's service names the ids, TMDB tells us what the first
  /// of them is. The rest of the ids are the fallbacks the service ranked
  /// lower — the head of the tab shows one series, so only the best is
  /// fetched.
  Future<void> onGetRecommendedSeries(GetRecommendedSeries event, Emitter<SeriesState> emit) async {
    final idsResult = await _getRecommendedSeriesIdsUseCase.call();

    await idsResult.fold(
      (failure) async => _emitRecommended(RecommendedSeriesFailure(failure.message), emit),
      (seriesIds) async {
        if (seriesIds.isEmpty) {
          return _emitRecommended(const RecommendedSeriesEmpty(), emit);
        }

        final detailsResult = await _getSeriesDetailsUseCase.call(params: seriesIds.first);

        detailsResult.fold(
          (failure) => _emitRecommended(RecommendedSeriesFailure(failure.message), emit),
          (series) => _emitRecommended(RecommendedSeriesLoaded(series), emit),
        );
      },
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
  /// a service to ask. A failure is left as it is — that one is worth saying.
  RecommendedSeriesState _resolve(RecommendedSeriesState recommended, List<SeriesEntity> topRated) {
    if (recommended is! RecommendedSeriesEmpty || topRated.isEmpty) return recommended;

    return RecommendedSeriesLoaded(topRated[Random().nextInt(topRated.length)]);
  }

  SeriesState _success(List<SeriesEntity> popularSeries, List<SeriesEntity> topRatedSeries) {
    final withPoster = topRatedSeries.where((series) => series.posterPath != null).toList();
    if (withPoster.isEmpty) {
      return const SeriesError(ServerFailure('No series to show right now.'));
    }

    return SeriesSuccess(
      popularSeries.where((series) => series.posterPath != null).toList(),
      withPoster,
      _resolve(_recommended, withPoster),
    );
  }
}
