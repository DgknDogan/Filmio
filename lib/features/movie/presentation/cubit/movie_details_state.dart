part of 'movie_details_cubit.dart';

/// The details screen's own flags. These are independent of each other rather
/// than phases of one thing, so this stays a record of fields — a sealed
/// hierarchy here would be the pattern applied for its own sake.
///
/// There is nothing here about how far the sheet is open: the screen is one
/// scroll, and where it has got to is the scroll's business rather than the
/// cubit's.
class MovieDetailsState extends Equatable {
  final bool isMovieLiked;
  final SimilarMoviesState similars;

  const MovieDetailsState({
    required this.isMovieLiked,
    required this.similars,
  });

  MovieDetailsState copyWith({
    bool? isMovieLiked,
    SimilarMoviesState? similars,
  }) {
    return MovieDetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
      similars: similars ?? this.similars,
    );
  }

  @override
  List<Object?> get props => [isMovieLiked, similars];
}

/// The similar-titles row, which genuinely has phases: a failure used to be
/// indistinguishable from "there are none".
sealed class SimilarMoviesState extends Equatable {
  const SimilarMoviesState();

  @override
  List<Object?> get props => [];
}

final class SimilarMoviesLoading extends SimilarMoviesState {
  const SimilarMoviesLoading();
}

final class SimilarMoviesLoaded extends SimilarMoviesState {
  final List<MovieEntity> movies;

  const SimilarMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

final class SimilarMoviesFailure extends SimilarMoviesState {
  final String message;

  const SimilarMoviesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
