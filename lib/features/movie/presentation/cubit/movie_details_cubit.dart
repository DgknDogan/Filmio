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
    if (isClosed) return;

    result.fold(
      // A failure here is not worth a screen-level error: the page still works,
      // the heart just stays empty.
      (failure) => emit(state.copyWith(isMovieLiked: false)),
      (likedMovies) => emit(state.copyWith(isMovieLiked: likedMovies.contains(_movie))),
    );
  }

  Future<void> _getSimilarMovies() async {
    final result = await _getSimilarMoviesUseCase.call(params: _movie.id!);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(similars: SimilarMoviesFailure(failure.message))),
      (similarMovies) => emit(
        state.copyWith(similars: SimilarMoviesLoaded(similarMovies.where((movie) => movie.posterPath != null).toList())),
      ),
    );
  }

  Future<void> likeMovie({required MovieEntity movie}) async {
    final result = await _likeMovieUseCase.call(params: movie);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(isMovieLiked: state.isMovieLiked)),
      (_) => emit(state.copyWith(isMovieLiked: true)),
    );
  }

  Future<void> dislikeMovie({required MovieEntity movie}) async {
    final result = await _dislikeMovieUseCase.call(params: movie);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(isMovieLiked: state.isMovieLiked)),
      (_) => emit(state.copyWith(isMovieLiked: false)),
    );
  }
}
