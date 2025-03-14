import 'package:bloc/bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../../../core/resources/firebase_state.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/dislike_movie.dart';
import '../../domain/usecases/get_liked_movies.dart';
import '../../domain/usecases/get_similar_movies.dart';
import '../../domain/usecases/like_movie.dart';

part '../states/details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  final LikeMovieUseCase _likeMovieUseCase;
  final DislikeMovieUseCase _dislikeMovieUseCase;
  final GetLikedMoviesUseCase _getLikedMoviesUseCase;
  final GetSimilarMoviesUseCase _getSimilarMoviesUseCase;
  final MovieEntity _movie;
  DetailsCubit(
    this._likeMovieUseCase,
    this._getLikedMoviesUseCase,
    this._movie,
    this._dislikeMovieUseCase,
    this._getSimilarMoviesUseCase,
  ) : super(
          DetailsState(
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
    final getLikedMoviesState = await _getLikedMoviesUseCase.call();
    if (getLikedMoviesState is FirebaseSuccess && getLikedMoviesState.data != null && getLikedMoviesState.data!.contains(_movie)) {
      emit(state.copyWith(isMovieLiked: true));
    }
    if (getLikedMoviesState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: false));
    }
  }

  Future<void> _getSimilarMovies() async {
    final similarMoviesState = await _getSimilarMoviesUseCase.call(params: _movie.id!);
    if (similarMoviesState is DataSuccess && similarMoviesState.data != null) {
      emit(state.copyWith(
          similarsList: similarMoviesState.data!
              .sublist(0, 5)
              .where(
                (element) => element.posterPath != null,
              )
              .toList()));
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
