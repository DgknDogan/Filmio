import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/cubit/load_more_state.dart';
import '../../../../core/enums/discover_sort.dart';
import '../../../../core/models/discover_filters.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/usecases/discover_series.dart';

part 'series_discover_state.dart';

/// The browse-all screen behind a home row.
///
/// It owns two things the row does not: the filters the reader narrowed the
/// catalogue with, and the paging. Changing a filter starts the list again
/// from the first page — the pages already read describe a different question.
class SeriesDiscoverCubit extends Cubit<SeriesDiscoverState> {
  static const _firstPage = 1;

  final DiscoverSeriesUseCase _discoverSeriesUseCase;

  /// Which row the screen was opened from. Not a filter: the reader cannot
  /// change it here, and clearing the filters does not clear it.
  final DiscoverSort _sort;

  SeriesDiscoverCubit(this._discoverSeriesUseCase, {DiscoverSort sort = DiscoverSort.popularity})
      : _sort = sort,
        super(const SeriesDiscoverLoading(DiscoverFilters.none)) {
    loadFirstPage();
  }

  /// Also what the retry after a failed first page calls.
  Future<void> loadFirstPage() async {
    final filters = state.filters;
    if (state is! SeriesDiscoverLoading) emit(SeriesDiscoverLoading(filters));

    final result = await _discoverSeriesUseCase.call(
      params: DiscoverSeriesParams(filters: filters, sort: _sort, page: _firstPage),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(SeriesDiscoverFailure(failure.message, filters)),
      (page) => emit(
        SeriesDiscoverLoaded(
          series: page.items,
          page: page.page,
          totalPages: page.totalPages,
          totalResults: page.totalResults,
          filters: filters,
        ),
      ),
    );
  }

  /// A different question, so the answer starts again rather than being added
  /// to. Applying the filters already in force changes nothing.
  Future<void> applyFilters(DiscoverFilters filters) async {
    if (filters == state.filters) return;

    emit(SeriesDiscoverLoading(filters));
    await loadFirstPage();
  }

  /// The next page, appended. Does nothing when the list is complete or a page
  /// is already in flight — the grid asks on every frame it is near the end,
  /// and only the first of those asks should reach the API.
  Future<void> loadMore() async {
    final current = state;
    if (current is! SeriesDiscoverLoaded) return;
    if (!current.hasMore || current.more is LoadMoreInProgress) return;

    emit(current.copyWith(more: const LoadMoreInProgress()));

    final nextPage = current.page + 1;
    final result = await _discoverSeriesUseCase.call(
      params: DiscoverSeriesParams(filters: current.filters, sort: _sort, page: nextPage),
    );
    if (isClosed) return;

    // The filters may have changed while the page was in the air, in which
    // case what came back answers a question nobody is asking any more.
    if (state.filters != current.filters) return;

    result.fold(
      (failure) => emit(current.copyWith(more: LoadMoreFailure(failure.message))),
      (page) => emit(
        SeriesDiscoverLoaded(
          series: [...current.series, ...page.items],
          page: page.page,
          totalPages: page.totalPages,
          totalResults: page.totalResults,
          filters: current.filters,
        ),
      ),
    );
  }
}
