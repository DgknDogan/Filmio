part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// One keystroke. Most of these never become a request — the transformer on
/// the handler is what thins them out.
final class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// The reader asking again after a failure. Carries the query rather than
/// reading the last one back off the state, because a failure state has no
/// query in it.
final class SearchRetried extends SearchEvent {
  final String query;

  const SearchRetried(this.query);

  @override
  List<Object?> get props => [query];
}
