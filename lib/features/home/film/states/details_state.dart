part of '../cubit/details_cubit.dart';

class DetailsState {
  final bool isMovieLiked;

  DetailsState({required this.isMovieLiked});

  DetailsState copyWith({
    bool? isMovieLiked,
  }) {
    return DetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
    );
  }
}
