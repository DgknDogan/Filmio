part of 'watched_series_cubit.dart';

sealed class WatchedSeriesState extends Equatable {
  const WatchedSeriesState();

  @override
  List<Object?> get props => [];
}

final class WatchedSeriesLoading extends WatchedSeriesState {
  const WatchedSeriesLoading();
}

final class WatchedSeriesLoaded extends WatchedSeriesState {
  final List<SeriesEntity> series;

  const WatchedSeriesLoaded(this.series);

  @override
  List<Object?> get props => [series];
}

final class WatchedSeriesFailure extends WatchedSeriesState {
  final String message;

  const WatchedSeriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
