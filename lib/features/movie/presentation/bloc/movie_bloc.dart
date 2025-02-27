import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase _getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;
  MovieBloc(this._getPopularMoviesUseCase, this._getTopRatedMoviesUseCase) : super(MovieLoading()) {
    on<MovieEvent>((event, emit) async {
      await getMovies(event as GetMovies, emit);
    });
  }

  Future<void> getMovies(GetMovies event, Emitter<MovieState> emit) async {
    final popularMoviesDataState = await _getPopularMoviesUseCase.call();
    final topRatedMoviesDataState = await _getTopRatedMoviesUseCase.call();

    if (popularMoviesDataState is DataSuccess && topRatedMoviesDataState is DataSuccess) {
      final recommendedMovie = topRatedMoviesDataState.data![Random().nextInt(topRatedMoviesDataState.data!.length)];

      emit(
        MovieSuccess(
          popularMoviesDataState.data!,
          topRatedMoviesDataState.data!,
          recommendedMovie,
        ),
      );
    }
    if (popularMoviesDataState is DataError) {
      emit(MovieError(popularMoviesDataState.error!));
    }
    if (topRatedMoviesDataState is DataError) {
      emit(MovieError(topRatedMoviesDataState.error!));
    }
  }
}
