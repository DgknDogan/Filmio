import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/dislike_series.dart';
import '../../domain/usecases/get_liked_series.dart';
import '../../domain/usecases/get_similar_series.dart';
import '../../domain/usecases/like_series.dart';

part 'series_details_state.dart';

class SeriesDetailsCubit extends Cubit<SeriesDetailsState> {
  final LikeSeriesUseCase _likeSeriesUseCase;
  final DislikeSeriesUseCase _dislikeSeriesUseCase;
  final GetLikedSeriesUseCase _getLikedSeriesUseCase;
  final GetSimilarSeriesUseCase _getSimilarSeriesUseCase;
  final SeriesEntity _series;

  SeriesDetailsCubit(
    this._likeSeriesUseCase,
    this._getLikedSeriesUseCase,
    this._series,
    this._dislikeSeriesUseCase,
    this._getSimilarSeriesUseCase,
  ) : super(
          const SeriesDetailsState(
            isSeriesLiked: false,
            similars: SimilarSeriesLoading(),
          ),
        ) {
    _init();
  }

  void _init() async {
    await _isSeriesLiked();
    await _getSimilarSeries();
  }

  Future<void> _isSeriesLiked() async {
    final result = await _getLikedSeriesUseCase.call();
    if (isClosed) return;

    result.fold(
      // A failure here is not worth a screen-level error: the page still works,
      // the heart just stays empty.
      (failure) => emit(state.copyWith(isSeriesLiked: false)),
      (likedSeries) => emit(state.copyWith(isSeriesLiked: likedSeries.contains(_series))),
    );
  }

  Future<void> _getSimilarSeries() async {
    // TMDB addresses a series by id; without one there is nothing to ask for.
    if (_series.id == null) {
      if (!isClosed) emit(state.copyWith(similars: const SimilarSeriesLoaded([])));
      return;
    }

    final result = await _getSimilarSeriesUseCase.call(params: _series.id);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(similars: SimilarSeriesFailure(failure.message))),
      // A poster is the whole of a card in that row, so one without artwork
      // would be a hole in the line rather than a title.
      (similarSeries) => emit(
        state.copyWith(
          similars: SimilarSeriesLoaded(similarSeries.where((series) => series.posterPath != null).toList()),
        ),
      ),
    );
  }

  Future<void> likeSeries({required SeriesEntity series}) async {
    final result = await _likeSeriesUseCase.call(params: series);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(isSeriesLiked: state.isSeriesLiked)),
      (_) => emit(state.copyWith(isSeriesLiked: true)),
    );
  }

  Future<void> dislikeSeries({required SeriesEntity series}) async {
    final result = await _dislikeSeriesUseCase.call(params: series);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(isSeriesLiked: state.isSeriesLiked)),
      (_) => emit(state.copyWith(isSeriesLiked: false)),
    );
  }
}
