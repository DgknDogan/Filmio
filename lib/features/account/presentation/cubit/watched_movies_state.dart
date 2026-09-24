part of 'watched_movies_cubit.dart';

sealed class WatchedMoviesState extends Equatable {
  const WatchedMoviesState();

  @override
  List<Object?> get props => [];
}

final class WatchedMoviesLoading extends WatchedMoviesState {
  const WatchedMoviesLoading();
}

final class WatchedMoviesLoaded extends WatchedMoviesState {
  final List<MovieEntity> movies;

  const WatchedMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

final class WatchedMoviesFailure extends WatchedMoviesState {
  final String message;

  const WatchedMoviesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
