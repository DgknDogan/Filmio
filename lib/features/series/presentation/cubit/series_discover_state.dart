part of 'series_discover_cubit.dart';

/// The browse screen has phases — nothing yet, a reason there is nothing, the
/// grid — but the filters outlive all three: the sheet has to open on what is
/// in force even while the first page of a new filter is still loading, so
/// every state carries them.
sealed class SeriesDiscoverState extends Equatable {
  final DiscoverFilters filters;

  const SeriesDiscoverState(this.filters);

  @override
  List<Object?> get props => [filters];
}

final class SeriesDiscoverLoading extends SeriesDiscoverState {
  const SeriesDiscoverLoading(super.filters);
}

final class SeriesDiscoverFailure extends SeriesDiscoverState {
  final String message;

  const SeriesDiscoverFailure(this.message, super.filters);

  @override
  List<Object?> get props => [message, filters];
}

final class SeriesDiscoverLoaded extends SeriesDiscoverState {
  final List<SeriesEntity> series;

  /// The last page fetched, one-based.
  final int page;

  final int totalPages;

  /// Across every page — what the count above the grid should say, rather than
  /// how many have been loaded so far.
  final int totalResults;

  /// What the foot of the grid is doing.
  final LoadMoreState more;

  const SeriesDiscoverLoaded({
    required this.series,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required DiscoverFilters filters,
    this.more = const LoadMoreIdle(),
  }) : super(filters);

  bool get hasMore => page < totalPages;

  SeriesDiscoverLoaded copyWith({
    List<SeriesEntity>? series,
    int? page,
    int? totalPages,
    int? totalResults,
    DiscoverFilters? filters,
    LoadMoreState? more,
  }) {
    return SeriesDiscoverLoaded(
      series: series ?? this.series,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      filters: filters ?? this.filters,
      more: more ?? this.more,
    );
  }

  @override
  List<Object?> get props => [series, page, totalPages, totalResults, filters, more];
}
