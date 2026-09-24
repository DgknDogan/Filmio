import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_recommended_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase _getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;
  final GetRecommendedMoviesUseCase _getRecommendedMoviesUseCase;

  /// The recommendation and the rows are two independent requests against two
  /// different services, and either can land first. Holding the latest
  /// recommendation here is what lets whichever finishes second carry the
  /// other's result into the state it emits.
  RecommendedMovieState _recommended = const RecommendedMovieLoading();

  MovieBloc(
    this._getPopularMoviesUseCase,
    this._getTopRatedMoviesUseCase,
    this._getRecommendedMoviesUseCase,
  ) : super(const MovieLoading()) {
    on<GetMovies>((event, emit) async {
      await onGetMovies(event, emit);
    });

    on<GetRecommendedMovie>((event, emit) async {
      await onGetRecommendedMovie(event, emit);
    });

    add(GetRecommendedMovie());
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

  /// The block at the head of the tab. Which titles those are — and whether
  /// they came from the service or from what it last answered — is the
  /// repository's business; all this has to know is the three ways it can end.
  Future<void> onGetRecommendedMovie(GetRecommendedMovie event, Emitter<MovieState> emit) async {
    final result = await _getRecommendedMoviesUseCase.call();

    result.fold(
      (failure) => _emitRecommended(RecommendedMovieFailure(failure.message), emit),
      (movies) => _emitRecommended(
        movies.isEmpty ? const RecommendedMovieEmpty() : RecommendedMovieLoaded(movies),
        emit,
      ),
    );
  }

  /// Keeps the recommendation for the state that has not been built yet, and
  /// folds it into the one already on screen if the rows got there first.
  void _emitRecommended(RecommendedMovieState recommended, Emitter<MovieState> emit) {
    _recommended = recommended;

    final current = state;
    if (current is MovieSuccess) {
      emit(current.copyWith(recommended: _resolve(recommended, current.topFilmsList)));
    }
  }

  /// The recommendation to show over [topRated].
  ///
  /// The service having nothing to suggest is not a reason for the tab to open
  /// on an empty block: an account that has liked too little yet gets a
  /// top-rated title, which is what the head of the tab held before there was
  /// a service to ask. Only the one: a stand-in is not a list of suggestions
  /// to step through. A failure is left as it is — that one is worth saying.
  RecommendedMovieState _resolve(RecommendedMovieState recommended, List<MovieEntity> topRated) {
    if (recommended is! RecommendedMovieEmpty || topRated.isEmpty) return recommended;

    return RecommendedMovieLoaded([topRated[Random().nextInt(topRated.length)]]);
  }

  MovieState _success(List<MovieEntity> popularMovies, List<MovieEntity> topRatedMovies) {
    // The repository has already dropped anything the app cannot draw, so an
    // empty list here means the catalogue answered with nothing usable at all.
    if (topRatedMovies.isEmpty) {
      return const MovieError(ServerFailure('No movies to show right now.'));
    }

    return MovieSuccess(popularMovies, topRatedMovies, _resolve(_recommended, topRatedMovies));
  }
}
