import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../cubit/liked_series_cubit.dart';
import '../widgets/series_list_row.dart';
import '../widgets/title_list_header.dart';

@RoutePage()
class LikedSeriesPage extends StatelessWidget {
  const LikedSeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LikedSeriesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<LikedSeriesCubit, LikedSeriesState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleListHeader(
                    title: context.l10n.likedSeries,
                    count: state is LikedSeriesLoaded ? state.series.length : null,
                  ),
                  Expanded(
                    child: switch (state) {
                      LikedSeriesLoading() => const Center(child: CircularProgressIndicator()),
                      LikedSeriesFailure(:final message) => AppErrorView(
                          message: message,
                          onRetry: () => context.read<LikedSeriesCubit>().getLikedSeries(),
                        ),
                      LikedSeriesLoaded(:final series) when series.isEmpty => Center(
                          child: Text(context.l10n.likedSeriesEmpty, style: context.styles.meta),
                        ),
                      LikedSeriesLoaded(:final series) => ListView.separated(
                          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                          itemCount: series.length,
                          separatorBuilder: (context, index) => AppGap.vertical(AppSpacing.md),
                          itemBuilder: (context, index) => SeriesListRow(
                            series: series[index],
                            heroTag: posterHeroTag('liked-series', index: index, id: series[index].id),
                            badge: Icons.favorite_rounded,
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
