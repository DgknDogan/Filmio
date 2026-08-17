part of 'series_search_bloc.dart';

sealed class SeriesSearchState extends Equatable {
  const SeriesSearchState();

  @override
  List<Object?> get props => [];
}

/// Nothing typed yet.
final class SeriesSearchInitial extends SeriesSearchState {
  const SeriesSearchInitial();
}

final class SeriesSearchLoading extends SeriesSearchState {
  const SeriesSearchLoading();
}

final class SeriesSearchLoaded extends SeriesSearchState {
  final List<SeriesEntity> series;

  const SeriesSearchLoaded(this.series);

  @override
  List<Object?> get props => [series];
}

final class SeriesSearchFailure extends SeriesSearchState {
  final String message;

  const SeriesSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
