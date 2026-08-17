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

  Future<void> getLikedMovies() async {
    if (!isClosed) emit(const LikedMoviesLoading());

    final result = await _getLikedMoviesUseCase.call();
    if (isClosed) return;

    result.fold(
      (failure) => emit(LikedMoviesFailure(failure.message)),
      (movies) => emit(LikedMoviesLoaded(movies)),
    );
  }
}
