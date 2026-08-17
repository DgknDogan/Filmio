import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase _getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;

  MovieBloc(this._getPopularMoviesUseCase, this._getTopRatedMoviesUseCase) : super(const MovieLoading()) {
    on<GetMovies>((event, emit) async {
      await onGetMovies(event, emit);
    });
  }

  Future<void> onGetMovies(GetMovies event, Emitter<MovieState> emit) async {
    final popularResult = await _getPopularMoviesUseCase.call();
    final topRatedResult = await _getTopRatedMoviesUseCase.call();

    popularResult.fold(
      (failure) => emit(MovieError(failure)),
      (popularMovies) => topRatedResult.fold(
        (failure) => emit(MovieError(failure)),
        (topRatedMovies) => emit(_success(popularMovies, topRatedMovies)),
      ),
    );
  }

  MovieState _success(List<MovieEntity> popularMovies, List<MovieEntity> topRatedMovies) {
    final withPoster = topRatedMovies.where((movie) => movie.posterPath != null).toList();
    if (withPoster.isEmpty) {
      return const MovieError(ServerFailure('No movies to show right now.'));
    }

    return MovieSuccess(
      popularMovies.where((movie) => movie.posterPath != null).toList(),
      withPoster,
      withPoster[Random().nextInt(withPoster.length)],
    );
  }
}
