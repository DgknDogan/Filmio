import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../movie/domain/entities/movie.dart';
import '../../../movie/domain/usecases/get_watched_movies.dart';

part 'watched_movies_state.dart';

class WatchedMoviesCubit extends Cubit<WatchedMoviesState> {
  final GetWatchedMoviesUseCase _getWatchedMoviesUseCase;

  WatchedMoviesCubit(this._getWatchedMoviesUseCase) : super(const WatchedMoviesLoading()) {
    getWatchedMovies();
  }

  Future<void> getWatchedMovies() async {
    if (!isClosed) emit(const WatchedMoviesLoading());

    final result = await _getWatchedMoviesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) => emit(WatchedMoviesFailure(failure.message)),
      (movies) => emit(WatchedMoviesLoaded(movies)),
    );
  }
}
