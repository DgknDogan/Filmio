part of 'series_search_bloc.dart';

sealed class SeriesSearchEvent extends Equatable {
  const SeriesSearchEvent();

  @override
  List<Object?> get props => [];
}

/// One keystroke. Most of these never become a request — the transformer on
/// the handler is what thins them out.
final class SeriesSearchQueryChanged extends SeriesSearchEvent {
  final String query;

  const SeriesSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// The reader asking again after a failure. Carries the query rather than
/// reading the last one back off the state, because a failure state has no
/// query in it.
final class SeriesSearchRetried extends SeriesSearchEvent {
  final String query;

  const SeriesSearchRetried(this.query);

  @override
  List<Object?> get props => [query];
}
