// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../presentation/cubit/series_details_cubit.dart';

class SeriesDetailsState {
  final bool isMovieLiked;
  final bool isPageShrinked;
  final bool isOpacityAnimating;

  SeriesDetailsState({
    required this.isMovieLiked,
    required this.isPageShrinked,
    required this.isOpacityAnimating,
  });

  SeriesDetailsState copyWith({
    bool? isMovieLiked,
    bool? isPageShrinked,
    bool? isOpacityAnimating,
  }) {
    return SeriesDetailsState(
      isMovieLiked: isMovieLiked ?? this.isMovieLiked,
      isPageShrinked: isPageShrinked ?? this.isPageShrinked,
      isOpacityAnimating: isOpacityAnimating ?? this.isOpacityAnimating,
    );
  }
}
