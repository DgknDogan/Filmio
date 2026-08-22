import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/browse_header.dart';
import '../../../../core/custom/discover_filter_sheet.dart';
import '../../../../core/custom/paginated_poster_grid.dart';
import '../../../../core/enums/discover_sort.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../cubit/movie_discover_cubit.dart';
import '../widgets/movie_poster_card.dart';

/// Every film in a home row, and then some: the same catalogue the row is the
/// head of, filterable and paged.
@RoutePage()
class MovieDiscoverPage extends StatelessWidget {
  /// The row's own heading, so the screen says what it is a continuation of.
  final String title;

  /// Which row it was opened from, which is the order the catalogue comes back
  /// in.
  final DiscoverSort sort;

  const MovieDiscoverPage({super.key, required this.title, required this.sort});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDiscoverCubit(getIt(), sort: sort),
      child: _DiscoverView(title: title),
    );
  }
}

class _DiscoverView extends StatelessWidget {
  final String title;

  const _DiscoverView({required this.title});

  Future<void> _openFilters(BuildContext context) async {
    final cubit = context.read<MovieDiscoverCubit>();

    final chosen = await DiscoverFilterSheet.show(context, filters: cubit.state.filters);
    // Null is the reader backing out, which is not the same as clearing.
    if (chosen != null) await cubit.applyFilters(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDiscoverCubit, MovieDiscoverState>(
        builder: (context, state) {
          return Column(
            children: [
              BrowseHeader(
                title: title,
                resultLabel: switch (state) {
                  MovieDiscoverLoaded(:final totalResults) => context.l10n.browseResultCount(totalResults),
                  _ => null,
                },
                activeFilterCount: state.filters.activeCount,
                onFilter: () => _openFilters(context),
              ),
              Expanded(
                child: switch (state) {
                  MovieDiscoverLoading() => const Center(child: CircularProgressIndicator()),
                  MovieDiscoverFailure(:final message) => AppErrorView(
                      message: message,
                      onRetry: () => context.read<MovieDiscoverCubit>().loadFirstPage(),
                    ),
                  MovieDiscoverLoaded(:final movies) when movies.isEmpty => AppErrorView(
                      message: context.l10n.browseEmpty,
                    ),
                  MovieDiscoverLoaded() => _Results(state: state),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final MovieDiscoverLoaded state;

  const _Results({required this.state});

  @override
  Widget build(BuildContext context) {
    return PaginatedPosterGrid(
      itemCount: state.movies.length,
      hasMore: state.hasMore,
      more: state.more,
      onLoadMore: () => context.read<MovieDiscoverCubit>().loadMore(),
      itemBuilder: (context, index) {
        final movie = state.movies[index];

        // A catalogue can answer with two films of the same name — a remake, a
        // re-release — so the grid position is what tells the posters apart.
        return MoviePosterCard(movie: movie, heroTag: posterHeroTag('movie-discover', index: index, id: movie.id));
      },
    );
  }
}
