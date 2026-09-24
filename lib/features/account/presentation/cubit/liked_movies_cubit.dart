import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../movie/domain/entities/movie.dart';
import '../../../movie/domain/usecases/get_liked_movies.dart';

part 'liked_movies_state.dart';

class LikedMoviesCubit extends Cubit<LikedMoviesState> {
  final GetLikedMoviesUseCase _getLikedMoviesUseCase;

  LikedMoviesCubit(this._getLikedMoviesUseCase) : super(const LikedMoviesLoading()) {
    getLikedMovies();
  }

  /// Reads the list from the start, with the screen showing that it is
  /// waiting.
  Future<void> getLikedMovies() {
    if (!isClosed) emit(const LikedMoviesLoading());

    return _read();
  }

  /// Reads the list again without the screen saying so.
  ///
  /// This is what the screen calls when a title's own page has been closed:
  /// the like may have been taken back while it was open, and the row has to
  /// go — but the reader is looking at the list as they arrive back on it, and
  /// replacing it with a spinner for the length of one document read reads as
  /// a flicker rather than as progress. A failure is swallowed for the same
  /// reason: the list already on screen is the better answer.
  Future<void> refresh() => _read(quietly: true);

  Future<void> _read({bool quietly = false}) async {
    final result = await _getLikedMoviesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!quietly) emit(LikedMoviesFailure(failure.message));
      },
      (movies) => emit(LikedMoviesLoaded(movies)),
    );
  }
}
