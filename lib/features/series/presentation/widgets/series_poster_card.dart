import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../domain/entities/series_entity.dart';

/// A series' poster, and the way into the series.
///
/// Every screen that lists series — the tab, the search results, the browse
/// grid, the similar row on a details page — puts the same three lines in
/// front of [PosterCard]: the artwork path resolved, the title for the screen
/// reader, and a push to the details route. They live here once instead.
class SeriesPosterCard extends StatelessWidget {
  final SeriesEntity series;

  /// What the poster flies on. Rows overlap — a series can be both popular and
  /// top rated — so the tag is scoped by the row that draws it rather than by
  /// the series.
  final String heroTag;

  const SeriesPosterCard({super.key, required this.series, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return PosterCard(
      imageUrl: series.posterPath?.coverImage ?? '',
      title: series.name ?? '',
      heroTag: heroTag,
      onTap: () => context.router.push(SeriesDetailsRoute(series: series, heroTag: heroTag)),
    );
  }
}
