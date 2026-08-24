part of 'series_bloc.dart';

sealed class SeriesState extends Equatable {
  const SeriesState();

  @override
  List<Object?> get props => [];
}

final class SeriesLoading extends SeriesState {
  const SeriesLoading();
}

final class SeriesError extends SeriesState {
  final Failure failure;

  const SeriesError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class SeriesSuccess extends SeriesState {
  final List<SeriesEntity> popularSeriesList;
  final List<SeriesEntity> topSeriesList;

  /// The recommendation arrives from a different service, over two requests,
  /// and the rows must not wait for it — so it is a state of its own inside
  /// this one rather than a series the page cannot open without.
  final RecommendedSeriesState recommended;

  const SeriesSuccess(this.popularSeriesList, this.topSeriesList, this.recommended);

  SeriesSuccess copyWith({RecommendedSeriesState? recommended}) {
    return SeriesSuccess(popularSeriesList, topSeriesList, recommended ?? this.recommended);
  }

  @override
  List<Object?> get props => [popularSeriesList, topSeriesList, recommended];
}

/// Where the series at the head of the series tab has got to.
sealed class RecommendedSeriesState extends Equatable {
  const RecommendedSeriesState();

  @override
  List<Object?> get props => [];
}

final class RecommendedSeriesLoading extends RecommendedSeriesState {
  const RecommendedSeriesLoading();
}

final class RecommendedSeriesLoaded extends RecommendedSeriesState {
  final SeriesEntity series;

  const RecommendedSeriesLoaded(this.series);

  @override
  List<Object?> get props => [series];
}

/// The service answered but had nothing to suggest, and there was no top-rated
/// series to stand in for it either. Not a failure: there is nothing to retry.
final class RecommendedSeriesEmpty extends RecommendedSeriesState {
  const RecommendedSeriesEmpty();
}

final class RecommendedSeriesFailure extends RecommendedSeriesState {
  final String message;

  const RecommendedSeriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
