part of 'movie_bloc.dart';

sealed class MovieState {
  final List<MovieEntity>? popularFilmsList;
  final List<MovieEntity>? topFilmsList;
  final MovieEntity? recommendedMovie;
  final DioException? error;

  const MovieState({
    this.popularFilmsList,
    this.topFilmsList,
    this.error,
    this.recommendedMovie,
  });
}

final class MovieLoading extends MovieState {
  MovieLoading();
}

final class MovieError extends MovieState {
  const MovieError(DioException error) : super(error: error);
}

final class MovieSuccess extends MovieState {
  const MovieSuccess(
    List<MovieEntity>? popularFilmsList,
    List<MovieEntity>? topFilmsList,
    MovieEntity? recommendedMovie,
  ) : super(
          popularFilmsList: popularFilmsList,
          topFilmsList: topFilmsList,
          recommendedMovie: recommendedMovie,
        );

  MovieSuccess copyWith({
    List<MovieEntity>? popularFilmsList,
    List<MovieEntity>? topFilmsList,
    MovieEntity? recommendedMovie,
  }) {
    return MovieSuccess(
      popularFilmsList ?? super.popularFilmsList!,
      topFilmsList ?? super.topFilmsList!,
      recommendedMovie ?? super.recommendedMovie!,
    );
  }
}
