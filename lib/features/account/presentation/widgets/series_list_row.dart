import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../series/domain/entities/series_entity.dart';
import 'title_list_row.dart';

/// A series in an account list; opens its details on tap.
class SeriesListRow extends StatelessWidget {
  final SeriesEntity series;
  final String heroTag;
  final IconData badge;

  const SeriesListRow({super.key, required this.series, required this.heroTag, required this.badge});

  @override
  Widget build(BuildContext context) {
    return TitleListRow(
      posterUrl: series.posterPath?.coverImage ?? '',
      title: series.name ?? '',
      year: series.firstAirDate?.year,
      rating: series.voteAverage,
      genreIds: series.genreIds,
      isSeries: true,
      heroTag: heroTag,
      badge: badge,
      onTap: () => context.router.push(SeriesDetailsRoute(series: series, heroTag: heroTag)),
    );
  }
}
