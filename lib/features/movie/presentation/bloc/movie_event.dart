part of 'movie_bloc.dart';

sealed class MovieEvent {
  const MovieEvent();
}

class GetMovies extends MovieEvent {}

/// The title at the head of the tab, picked for the signed-in user by Filmio's
/// own service rather than by TMDB.
class GetRecommendedMovie extends MovieEvent {}
