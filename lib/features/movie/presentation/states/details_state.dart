part of '../cubit/details_cubit.dart';

class DetailsState {
  final bool isMovieLiked;
  final bool isPageShrinked;
  final bool isOpacityAnimating;
  final bool isPageShrinking;

  DetailsState({
    required this.isMovieLiked,
    required this.isPageShrinked,
    required this.isOpacityAnimating,
    required this.isPageShrinking,
  });

  DetailsState copyWith({
    bool? isMovieLiked,
    bool? isPageShrinked,
    bool? isOpacityAnimating,
    bool? isPageShrinking,
  }) {
    return DetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
      isPageShrinked: isPageShrinked ?? this.isPageShrinked,
      isOpacityAnimating: isOpacityAnimating ?? this.isOpacityAnimating,
      isPageShrinking: isPageShrinking ?? this.isPageShrinking,
    );
  }
}
