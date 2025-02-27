part of 'movie_bloc.dart';

sealed class MovieEvent {
  const MovieEvent();
}

class GetMovies extends MovieEvent {}
