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
  final MovieEntity recommendedMovie;

  const MovieSuccess(this.popularFilmsList, this.topFilmsList, this.recommendedMovie);

  @override
  List<Object?> get props => [popularFilmsList, topFilmsList, recommendedMovie];
}
