part of '../cubit/details_cubit.dart';

class DetailsState {
  final bool isMovieLiked;
  final bool isPageShrinked;
  final bool isOpacityAnimating;
  final List<MovieEntity> similarsList;

  DetailsState({
    required this.isMovieLiked,
    required this.isPageShrinked,
    required this.isOpacityAnimating,
    required this.similarsList,
  });

  DetailsState copyWith({
    bool? isMovieLiked,
    bool? isPageShrinked,
    bool? isOpacityAnimating,
    List<MovieEntity>? similarsList,
  }) {
    return DetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
      isPageShrinked: isPageShrinked ?? this.isPageShrinked,
      isOpacityAnimating: isOpacityAnimating ?? this.isOpacityAnimating,
      similarsList: similarsList ?? this.similarsList,
    );
  }
}
