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

  /// Whether the heart has been pressed on this screen. What the reader chose
  /// outranks what the liked list said when the screen opened.
  bool _readerHasChosen = false;

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
    // The list takes a moment to read, and a reader who pressed the heart
    // inside that moment has already said what they want. Their answer stands.
    if (isClosed || _readerHasChosen) return;

    result.fold(
      // A failure here is not worth a screen-level error: the page still works,
      // the heart just stays empty.
      (failure) => emit(state.copyWith(isSeriesLiked: false)),
      // By id, not by whole title: the entry the list stored was read from a
      // different endpoint at a different time, so its rating and popularity
      // have moved on even though it is the same series.
      (likedSeries) => emit(state.copyWith(isSeriesLiked: likedSeries.any((liked) => liked.id == _series.id))),
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
          similars: SimilarSeriesLoaded(similarSeries),
        ),
      ),
    );
  }

  Future<void> likeSeries({required SeriesEntity series}) => _setLiked(true, series);

  Future<void> dislikeSeries({required SeriesEntity series}) => _setLiked(false, series);

  /// Fills or empties the heart at once, then writes it.
  ///
  /// The write is a Firestore round trip, and waiting for it left the heart
  /// unmoved for the best part of a second after the tap — long enough for a
  /// reader to conclude the button is broken and press it again. The tap is
  /// also the only thing that can be wrong here: the reader knows what they
  /// meant, and the only question is whether it reached the server. So the
  /// heart answers immediately and goes back to where it was if it did not.
  Future<void> _setLiked(bool isLiked, SeriesEntity series) async {
    final wasLiked = state.isSeriesLiked;
    if (wasLiked == isLiked) return;

    _readerHasChosen = true;
    emit(state.copyWith(isSeriesLiked: isLiked));

    final result = isLiked ? await _likeSeriesUseCase.call(params: series) : await _dislikeSeriesUseCase.call(params: series);
    if (isClosed) return;

    result.fold((failure) => emit(state.copyWith(isSeriesLiked: wasLiked)), (_) {});
  }
}
