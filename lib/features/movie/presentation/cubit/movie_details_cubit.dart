import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/dislike_movie.dart';
import '../../domain/usecases/get_liked_movies.dart';
import '../../domain/usecases/get_similar_movies.dart';
import '../../domain/usecases/like_movie.dart';

part 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final LikeMovieUseCase _likeMovieUseCase;
  final DislikeMovieUseCase _dislikeMovieUseCase;
  final GetLikedMoviesUseCase _getLikedMoviesUseCase;
  final GetSimilarMoviesUseCase _getSimilarMoviesUseCase;
  final MovieEntity _movie;

  /// Whether the heart has been pressed on this screen. What the reader chose
  /// outranks what the liked list said when the screen opened.
  bool _readerHasChosen = false;

  MovieDetailsCubit(
    this._likeMovieUseCase,
    this._getLikedMoviesUseCase,
    this._movie,
    this._dislikeMovieUseCase,
    this._getSimilarMoviesUseCase,
  ) : super(
          const MovieDetailsState(
            isMovieLiked: false,
            similars: SimilarMoviesLoading(),
          ),
        ) {
    _init();
  }

  void _init() async {
    await _isMovieLiked();
    await _getSimilarMovies();
  }

  Future<void> _isMovieLiked() async {
    final result = await _getLikedMoviesUseCase.call();
    // The list takes a moment to read, and a reader who pressed the heart
    // inside that moment has already said what they want. Their answer stands.
    if (isClosed || _readerHasChosen) return;

    result.fold(
      // A failure here is not worth a screen-level error: the page still works,
      // the heart just stays empty.
      (failure) => emit(state.copyWith(isMovieLiked: false)),
      // By id, not by whole title: the entry the list stored was read from a
      // different endpoint at a different time, so its rating and popularity
      // have moved on even though it is the same film.
      (likedMovies) => emit(state.copyWith(isMovieLiked: likedMovies.any((liked) => liked.id == _movie.id))),
    );
  }

  Future<void> _getSimilarMovies() async {
    final result = await _getSimilarMoviesUseCase.call(params: _movie.id!);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(similars: SimilarMoviesFailure(failure.message))),
      (similarMovies) => emit(
        state.copyWith(similars: SimilarMoviesLoaded(similarMovies)),
      ),
    );
  }

  Future<void> likeMovie({required MovieEntity movie}) => _setLiked(true, movie);

  Future<void> dislikeMovie({required MovieEntity movie}) => _setLiked(false, movie);

  /// Fills or empties the heart at once, then writes it.
  ///
  /// The write is a Firestore round trip, and waiting for it left the heart
  /// unmoved for the best part of a second after the tap — long enough for a
  /// reader to conclude the button is broken and press it again. The tap is
  /// also the only thing that can be wrong here: the reader knows what they
  /// meant, and the only question is whether it reached the server. So the
  /// heart answers immediately and goes back to where it was if it did not.
  Future<void> _setLiked(bool isLiked, MovieEntity movie) async {
    final wasLiked = state.isMovieLiked;
    if (wasLiked == isLiked) return;

    _readerHasChosen = true;
    emit(state.copyWith(isMovieLiked: isLiked));

    final result = isLiked ? await _likeMovieUseCase.call(params: movie) : await _dislikeMovieUseCase.call(params: movie);
    if (isClosed) return;

    result.fold((failure) => emit(state.copyWith(isMovieLiked: wasLiked)), (_) {});
  }
}
