import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/add_watched_movie.dart';
import '../../domain/usecases/is_movie_watched.dart';
import '../../domain/usecases/remove_watched_movie.dart';

part 'movie_watched_state.dart';

/// Whether the movie on the details screen is on the user's watched list, and
/// the one control that changes it.
class MovieWatchedCubit extends Cubit<MovieWatchedState> {
  final IsMovieWatchedUseCase _isMovieWatchedUseCase;
  final AddWatchedMovieUseCase _addWatchedMovieUseCase;
  final RemoveWatchedMovieUseCase _removeWatchedMovieUseCase;
  final int? _movieId;

  MovieWatchedCubit(
    this._isMovieWatchedUseCase,
    this._addWatchedMovieUseCase,
    this._removeWatchedMovieUseCase, {
    required int? movieId,
  })  : _movieId = movieId,
        super(const MovieWatchedState(isWatched: false, isBusy: true)) {
    _load();
  }

  Future<void> _load() async {
    final id = _movieId;
    // Stored under its TMDB id; without one there is nothing to look up.
    if (id == null) {
      if (!isClosed) emit(const MovieWatchedState(isWatched: false, isBusy: false));
      return;
    }

    final result = await _isMovieWatchedUseCase.call(params: id);
    if (isClosed) return;

    result.fold(
      // Not worth a screen-level error: the page still works, the button just
      // offers to add.
      (failure) => emit(const MovieWatchedState(isWatched: false, isBusy: false)),
      (isWatched) => emit(MovieWatchedState(isWatched: isWatched, isBusy: false)),
    );
  }

  /// Adds the movie when it is not on the list, removes it when it is.
  Future<void> toggle() async {
    final id = _movieId;
    if (id == null || state.isBusy) return;

    final wasWatched = state.isWatched;
    emit(state.copyWith(isBusy: true));

    final result = wasWatched ? await _removeWatchedMovieUseCase.call(params: id) : await _addWatchedMovieUseCase.call(params: id);
    if (isClosed) return;

    result.fold(
      (failure) => emit(MovieWatchedState(isWatched: wasWatched, isBusy: false)),
      (_) => emit(MovieWatchedState(isWatched: !wasWatched, isBusy: false)),
    );
  }
}
