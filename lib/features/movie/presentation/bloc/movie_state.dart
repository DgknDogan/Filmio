part of 'movie_bloc.dart';

sealed class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

final class MovieLoading extends MovieState {
  const MovieLoading();
}

final class MovieError extends MovieState {
  final Failure failure;

  const MovieError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class MovieSuccess extends MovieState {
  final List<MovieEntity> popularFilmsList;
  final List<MovieEntity> topFilmsList;

  /// The recommendation arrives from a different service, over two requests,
  /// and the rows must not wait for it — so it is a state of its own inside
  /// this one rather than a title the page cannot open without.
  final RecommendedMovieState recommended;

  const MovieSuccess(this.popularFilmsList, this.topFilmsList, this.recommended);

  MovieSuccess copyWith({RecommendedMovieState? recommended}) {
    return MovieSuccess(popularFilmsList, topFilmsList, recommended ?? this.recommended);
  }

  @override
  List<Object?> get props => [popularFilmsList, topFilmsList, recommended];
}

/// Where the title at the head of the films tab has got to.
sealed class RecommendedMovieState extends Equatable {
  const RecommendedMovieState();

  @override
  List<Object?> get props => [];
}

final class RecommendedMovieLoading extends RecommendedMovieState {
  const RecommendedMovieLoading();
}

final class RecommendedMovieLoaded extends RecommendedMovieState {
  final MovieEntity movie;

  const RecommendedMovieLoaded(this.movie);

  @override
  List<Object?> get props => [movie];
}

/// The service answered but had nothing to suggest, and there was no top-rated
/// title to stand in for it either. Not a failure: there is nothing to retry.
final class RecommendedMovieEmpty extends RecommendedMovieState {
  const RecommendedMovieEmpty();
}

final class RecommendedMovieFailure extends RecommendedMovieState {
  final String message;

  const RecommendedMovieFailure(this.message);

  @override
  List<Object?> get props => [message];
}
