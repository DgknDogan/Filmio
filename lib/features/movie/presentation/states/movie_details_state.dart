part of '../cubit/movie_details_cubit.dart';

class MovieDetailsState {
  final bool isMovieLiked;
  final bool isPageShrinked;
  final bool isOpacityAnimating;
  final List<MovieEntity> similarsList;

  MovieDetailsState({
    required this.isMovieLiked,
    required this.isPageShrinked,
    required this.isOpacityAnimating,
    required this.similarsList,
  });

  MovieDetailsState copyWith({
    bool? isMovieLiked,
    bool? isPageShrinked,
    bool? isOpacityAnimating,
    List<MovieEntity>? similarsList,
  }) {
    return MovieDetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
      isPageShrinked: isPageShrinked ?? this.isPageShrinked,
      isOpacityAnimating: isOpacityAnimating ?? this.isOpacityAnimating,
      similarsList: similarsList ?? this.similarsList,
    );
  }
}
