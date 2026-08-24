import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/resource/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_recommended_movie_ids.dart';
import '../../domain/usecases/get_top_rated_movies.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase _getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;
  final GetRecommendedMovieIdsUseCase _getRecommendedMovieIdsUseCase;
  final GetMovieDetailsUseCase _getMovieDetailsUseCase;

  /// The recommendation and the rows are two independent requests against two
  /// different services, and either can land first. Holding the latest
  /// recommendation here is what lets whichever finishes second carry the
  /// other's result into the state it emits.
  RecommendedMovieState _recommended = const RecommendedMovieLoading();

  MovieBloc(
    this._getPopularMoviesUseCase,
    this._getTopRatedMoviesUseCase,
    this._getRecommendedMovieIdsUseCase,
    this._getMovieDetailsUseCase,
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

  /// Two calls: Filmio's service names the ids, TMDB tells us what the first
  /// of them is. The rest of the ids are the fallbacks the service ranked
  /// lower — the head of the tab shows one title, so only the best is fetched.
  Future<void> onGetRecommendedMovie(GetRecommendedMovie event, Emitter<MovieState> emit) async {
    final idsResult = await _getRecommendedMovieIdsUseCase.call();

    await idsResult.fold(
      (failure) async => _emitRecommended(RecommendedMovieFailure(failure.message), emit),
      (movieIds) async {
        if (movieIds.isEmpty) {
          return _emitRecommended(const RecommendedMovieEmpty(), emit);
        }

        final detailsResult = await _getMovieDetailsUseCase.call(params: movieIds.first);

        detailsResult.fold(
          (failure) => _emitRecommended(RecommendedMovieFailure(failure.message), emit),
          (movie) => _emitRecommended(RecommendedMovieLoaded(movie), emit),
        );
      },
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
  /// a service to ask. A failure is left as it is — that one is worth saying.
  RecommendedMovieState _resolve(RecommendedMovieState recommended, List<MovieEntity> topRated) {
    if (recommended is! RecommendedMovieEmpty || topRated.isEmpty) return recommended;

    return RecommendedMovieLoaded(topRated[Random().nextInt(topRated.length)]);
  }

  MovieState _success(List<MovieEntity> popularMovies, List<MovieEntity> topRatedMovies) {
    final withPoster = topRatedMovies.where((movie) => movie.posterPath != null).toList();
    if (withPoster.isEmpty) {
      return const MovieError(ServerFailure('No movies to show right now.'));
    }

    return MovieSuccess(
      popularMovies.where((movie) => movie.posterPath != null).toList(),
      withPoster,
      _resolve(_recommended, withPoster),
    );
  }
}
