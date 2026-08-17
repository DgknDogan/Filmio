import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/browse_view.dart';
import '../../../../core/custom/featured_hero.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/genre_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../domain/entities/series_entity.dart';
import '../bloc/series_bloc.dart';

/// The featured title's poster can also appear in a row further down, so its
/// tag is the banner's own rather than the title's.
const _featuredHeroTag = 'series_featured_poster';

/// The search control and the search screen's field are the same object at two
/// widths, so they share a tag and the one becomes the other.
const _searchHeroTag = 'series_searchbar';

@RoutePage()
class SeriesHomePage extends StatelessWidget {
  const SeriesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<SeriesBloc>(),
      child: Scaffold(
        body: BlocBuilder<SeriesBloc, SeriesState>(
          builder: (context, state) {
            return switch (state) {
              SeriesSuccess() => _Content(state: state),
              SeriesLoading() => const Center(child: CircularProgressIndicator()),
              SeriesError() => AppErrorView(message: state.failure.message),
            };
          },
        ),
      ),
    );
  }
}

/// What the series tab puts into [BrowseView]: a recommendation at the head of
/// the page, then the rows. The same shape the films tab has — the two are one
/// screen with different titles in it.
class _Content extends StatelessWidget {
  final SeriesSuccess state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final hint = context.l10n.seriesSearchHint;

    return BrowseView(
      searchHeroTag: _searchHeroTag,
      searchHint: hint,
      onSearch: () => context.router.push(
        SeriesSearchRoute(heroTag: _searchHeroTag, hintText: hint),
      ),
      featuredBuilder: (context, stretch) => _Hero(series: state.recommendedSeries, stretch: stretch),
      rows: [
        BrowseRow(
          title: context.l10n.seriesPopular,
          storageKey: const PageStorageKey('popular_series'),
          posters: _posters(state.popularSeriesList, 'series-popular'),
        ),
        BrowseRow(
          title: context.l10n.seriesTop,
          storageKey: const PageStorageKey('top_series'),
          posters: _posters(state.topSeriesList, 'series-top'),
        ),
      ],
    );
  }

  /// The two rows overlap — a series can be both popular and top rated — so
  /// each row scopes its own tags rather than naming the series.
  List<Widget> _posters(List<SeriesEntity> series, String scope) => [
        for (final (index, entry) in series.indexed)
          _SeriesPoster(series: entry, tag: posterHeroTag(scope, index: index, id: entry.id)),
      ];
}

class _Hero extends StatelessWidget {
  final SeriesEntity series;
  final double stretch;

  const _Hero({required this.series, required this.stretch});

  @override
  Widget build(BuildContext context) {
    return FeaturedHero(
      imageUrl: series.backdropPath?.coverImage ?? series.posterPath?.coverImage ?? '',
      posterUrl: series.posterPath?.coverImage ?? '',
      kicker: context.l10n.recommendedForYou,
      title: series.name ?? '',
      rating: series.voteAverage,
      metaParts: [series.genreIds.firstSeriesGenre],
      heroTag: _featuredHeroTag,
      actionLabel: context.l10n.detailsAction,
      stretch: stretch,
      onAction: () => context.router.push(
        SeriesDetailsRoute(series: series, heroTag: _featuredHeroTag),
      ),
    );
  }
}

class _SeriesPoster extends StatelessWidget {
  final SeriesEntity series;
  final String tag;

  const _SeriesPoster({required this.series, required this.tag});

  @override
  Widget build(BuildContext context) {
    final meta = [series.firstAirDate?.year, series.voteAverage?.toStringAsFixed(1)].nonNulls.join(' · ');

    return PosterCard(
      imageUrl: series.posterPath?.coverImage ?? '',
      title: series.name ?? '',
      meta: meta,
      heroTag: tag,
      onTap: () => context.router.push(SeriesDetailsRoute(series: series, heroTag: tag)),
    );
  }
}
