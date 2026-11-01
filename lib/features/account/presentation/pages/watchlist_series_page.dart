import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/cubit/title_list_cubit.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../../../series/domain/entities/series_entity.dart';
import '../cubit/watchlist_series_cubit.dart';
import '../widgets/title_list_view.dart';

@RoutePage()
class WatchlistSeriesPage extends StatelessWidget {
  const WatchlistSeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => WatchlistSeriesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<WatchlistSeriesCubit, TitleListState<SeriesEntity>>(
            builder: (context, state) {
              return TitleListView<SeriesEntity>(
                title: context.l10n.watchlistSeries,
                emptyMessage: context.l10n.watchlistSeriesEmpty,
                state: state,
                idOf: (series) => series.id,
                onRetry: () => context.read<WatchlistSeriesCubit>().load(),
                rowBuilder: (context, series, index) {
                  final tag = posterHeroTag('watchlist-series', index: index, id: series.id);

                  return TitleListRow(
                    imageUrl: series.posterPath?.coverImage ?? '',
                    title: series.name ?? '',
                    year: series.firstAirDate?.year,
                    voteAverage: series.voteAverage,
                    genreIds: series.genreIds,
                    isSeries: true,
                    mark: Icons.bookmark_rounded,
                    heroTag: tag,
                    onTap: () async {
                      final cubit = context.read<WatchlistSeriesCubit>();
                      await context.router.push(SeriesDetailsRoute(series: series, heroTag: tag));
                      await cubit.refresh();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
