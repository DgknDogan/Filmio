import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../cubit/watched_series_cubit.dart';
import '../widgets/series_list_row.dart';
import '../widgets/title_list_header.dart';

@RoutePage()
class WatchedSeriesPage extends StatelessWidget {
  const WatchedSeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => WatchedSeriesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<WatchedSeriesCubit, WatchedSeriesState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleListHeader(
                    title: context.l10n.watchedSeries,
                    count: state is WatchedSeriesLoaded ? state.series.length : null,
                  ),
                  Expanded(
                    child: switch (state) {
                      WatchedSeriesLoading() => const Center(child: CircularProgressIndicator()),
                      WatchedSeriesFailure(:final message) => AppErrorView(
                          message: message,
                          onRetry: () => context.read<WatchedSeriesCubit>().getWatchedSeries(),
                        ),
                      WatchedSeriesLoaded(:final series) when series.isEmpty => Center(
                          child: Text(context.l10n.watchedSeriesEmpty, style: context.styles.meta),
                        ),
                      WatchedSeriesLoaded(:final series) => ListView.separated(
                          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                          itemCount: series.length,
                          separatorBuilder: (context, index) => AppGap.vertical(AppSpacing.md),
                          itemBuilder: (context, index) => SeriesListRow(
                            series: series[index],
                            heroTag: posterHeroTag('watched-series', index: index, id: series[index].id),
                            badge: Icons.check_circle_rounded,
                          ),
                        ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
