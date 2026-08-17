part of 'liked_series_cubit.dart';

sealed class LikedSeriesState extends Equatable {
  const LikedSeriesState();

  @override
  List<Object?> get props => [];
}

final class LikedSeriesLoading extends LikedSeriesState {
  const LikedSeriesLoading();
}

final class LikedSeriesLoaded extends LikedSeriesState {
  final List<SeriesEntity> series;

  const LikedSeriesLoaded(this.series);

  @override
  List<Object?> get props => [series];
}

final class LikedSeriesFailure extends LikedSeriesState {
  final String message;

  const LikedSeriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
