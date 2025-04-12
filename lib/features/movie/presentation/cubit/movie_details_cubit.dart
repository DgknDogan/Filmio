import 'package:bloc/bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../../../core/resources/firebase_state.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/dislike_movie.dart';
import '../../domain/usecases/get_liked_movies.dart';
import '../../domain/usecases/get_similar_movies.dart';
import '../../domain/usecases/like_movie.dart';

part '../states/movie_details_state.dart';

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
          MovieDetailsState(
            isMovieLiked: false,
            isPageShrinked: true,
            isOpacityAnimating: false,
            similarsList: [],
          ),
        ) {
    _init();
  }

  void _init() async {
    await _isMovieLiked();
    await _getSimilarMovies();
  }

  Future<void> _isMovieLiked() async {
    if (!isClosed) {
      return;
    }
    final getLikedMoviesState = await _getLikedMoviesUseCase.call();
    if (getLikedMoviesState is FirebaseSuccess && getLikedMoviesState.data != null && getLikedMoviesState.data!.contains(_movie)) {
      emit(state.copyWith(isMovieLiked: true));
    }
    if (getLikedMoviesState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: false));
    }
  }

  Future<void> _getSimilarMovies() async {
    if (!isClosed) {
      return;
    }
    final similarMoviesState = await _getSimilarMoviesUseCase.call(params: _movie.id!);
    if (similarMoviesState is DataSuccess && similarMoviesState.data != null) {
      emit(state.copyWith(similarsList: similarMoviesState.data!));
    }
  }

  Future<void> likeMovie({required MovieEntity movie}) async {
    final likeMovieState = await _likeMovieUseCase.call(params: movie);
    if (likeMovieState is FirebaseSuccess && likeMovieState.data!) {
      emit(state.copyWith(isMovieLiked: true));
    }
    if (likeMovieState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: state.isMovieLiked));
    }
  }

  Future<void> dislikeMovie({required MovieEntity movie}) async {
    final likeMovieState = await _dislikeMovieUseCase.call(params: movie);
    if (likeMovieState is FirebaseSuccess && likeMovieState.data!) {
      emit(state.copyWith(isMovieLiked: false));
    }
    if (likeMovieState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: state.isMovieLiked));
    }
  }

  void changePageView() {
    emit(state.copyWith(isPageShrinked: !state.isPageShrinked, isOpacityAnimating: true));
  }

  void finishAnimation() {
    emit(state.copyWith(isOpacityAnimating: false));
  }
}
