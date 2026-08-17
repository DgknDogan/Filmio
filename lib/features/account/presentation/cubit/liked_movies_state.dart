part of 'liked_movies_cubit.dart';

sealed class LikedMoviesState extends Equatable {
  const LikedMoviesState();

  @override
  List<Object?> get props => [];
}

final class LikedMoviesLoading extends LikedMoviesState {
  const LikedMoviesLoading();
}

final class LikedMoviesLoaded extends LikedMoviesState {
  final List<MovieEntity> movies;

  const LikedMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

final class LikedMoviesFailure extends LikedMoviesState {
  final String message;

  const LikedMoviesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
