import 'package:bloc/bloc.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/dislike_movie.dart';
import '../../domain/usecases/get_liked_movies.dart';
import '../../domain/usecases/like_movie.dart';

part '../states/details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  final LikeMovieUseCase _likeMovieUseCase;
  final DislikeMovieUseCase _dislikeMovieUseCase;
  final GetLikedMoviesUseCase _getLikedMoviesUseCase;
  final MovieEntity _movie;
  DetailsCubit(
    this._likeMovieUseCase,
    this._getLikedMoviesUseCase,
    this._movie,
    this._dislikeMovieUseCase,
  ) : super(
          DetailsState(isMovieLiked: false),
        ) {
    init();
  }

  void init() async {
    await isMovieLiked();
  }

  Future<void> isMovieLiked() async {
    final getLikedMoviesState = await _getLikedMoviesUseCase.call();
    if (getLikedMoviesState is FirebaseSuccess && getLikedMoviesState.data != null && getLikedMoviesState.data!.contains(_movie)) {
      emit(state.copyWith(isMovieLiked: true));
    }
    if (getLikedMoviesState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: false));
    }
  }

  void likeMovie({required MovieEntity movie}) async {
    final likeMovieState = await _likeMovieUseCase.call(params: movie);
    if (likeMovieState is FirebaseSuccess && likeMovieState.data!) {
      emit(state.copyWith(isMovieLiked: true));
    }
    if (likeMovieState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: state.isMovieLiked));
    }
  }

  void dislikeMovie({required MovieEntity movie}) async {
    final likeMovieState = await _dislikeMovieUseCase.call(params: movie);
    if (likeMovieState is FirebaseSuccess && likeMovieState.data!) {
      emit(state.copyWith(isMovieLiked: false));
    }
    if (likeMovieState is FirebaseError) {
      emit(state.copyWith(isMovieLiked: state.isMovieLiked));
    }
  }
}
