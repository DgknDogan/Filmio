part of 'movie_discover_cubit.dart';

/// The browse screen has phases — nothing yet, a reason there is nothing, the
/// grid — but the filters outlive all three: the sheet has to open on what is
/// in force even while the first page of a new filter is still loading, so
/// every state carries them.
sealed class MovieDiscoverState extends Equatable {
  final DiscoverFilters filters;

  const MovieDiscoverState(this.filters);

  @override
  List<Object?> get props => [filters];
}

final class MovieDiscoverLoading extends MovieDiscoverState {
  const MovieDiscoverLoading(super.filters);
}

final class MovieDiscoverFailure extends MovieDiscoverState {
  final String message;

  const MovieDiscoverFailure(this.message, super.filters);

  @override
  List<Object?> get props => [message, filters];
}

final class MovieDiscoverLoaded extends MovieDiscoverState {
  final List<MovieEntity> movies;

  /// The last page fetched, one-based.
  final int page;

  final int totalPages;

  /// Across every page — what the count above the grid should say, rather than
  /// how many have been loaded so far.
  final int totalResults;

  /// What the foot of the grid is doing.
  final LoadMoreState more;

  const MovieDiscoverLoaded({
    required this.movies,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required DiscoverFilters filters,
    this.more = const LoadMoreIdle(),
  }) : super(filters);

  bool get hasMore => page < totalPages;

  MovieDiscoverLoaded copyWith({
    List<MovieEntity>? movies,
    int? page,
    int? totalPages,
    int? totalResults,
    DiscoverFilters? filters,
    LoadMoreState? more,
  }) {
    return MovieDiscoverLoaded(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      filters: filters ?? this.filters,
      more: more ?? this.more,
    );
  }

  @override
  List<Object?> get props => [movies, page, totalPages, totalResults, filters, more];
}
