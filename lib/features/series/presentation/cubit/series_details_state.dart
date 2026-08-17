part of 'series_details_cubit.dart';

/// The details screen's own flags. These are independent of each other rather
/// than phases of one thing, so this stays a record of fields — a sealed
/// hierarchy here would be the pattern applied for its own sake.
///
/// There is nothing here about how far the sheet is open: the screen is one
/// scroll, and where it has got to is the scroll's business rather than the
/// cubit's.
class SeriesDetailsState extends Equatable {
  final bool isSeriesLiked;
  final SimilarSeriesState similars;

  const SeriesDetailsState({
    required this.isSeriesLiked,
    required this.similars,
  });

  SeriesDetailsState copyWith({
    bool? isSeriesLiked,
    SimilarSeriesState? similars,
  }) {
    return SeriesDetailsState(
      isSeriesLiked: isSeriesLiked ?? this.isSeriesLiked,
      similars: similars ?? this.similars,
    );
  }

  @override
  List<Object?> get props => [isSeriesLiked, similars];
}

/// The similar-titles row, which genuinely has phases: a failure would
/// otherwise be indistinguishable from "there are none".
sealed class SimilarSeriesState extends Equatable {
  const SimilarSeriesState();

  @override
  List<Object?> get props => [];
}

final class SimilarSeriesLoading extends SimilarSeriesState {
  const SimilarSeriesLoading();
}

final class SimilarSeriesLoaded extends SimilarSeriesState {
  final List<SeriesEntity> series;

  const SimilarSeriesLoaded(this.series);

  @override
  List<Object?> get props => [series];
}

final class SimilarSeriesFailure extends SimilarSeriesState {
  final String message;

  const SimilarSeriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
