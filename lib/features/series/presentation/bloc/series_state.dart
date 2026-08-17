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
  final SeriesEntity recommendedSeries;

  const SeriesSuccess(this.popularSeriesList, this.topSeriesList, this.recommendedSeries);

  @override
  List<Object?> get props => [popularSeriesList, topSeriesList, recommendedSeries];
}
