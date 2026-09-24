import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/custom/genre_tags.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../../../series/domain/entities/series_entity.dart';
import '../widgets/collapsing_list.dart';
import '../cubit/liked_series_cubit.dart';

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
                  _Header(count: state is LikedSeriesLoaded ? state.series.length : null),
                  Expanded(
                    child: switch (state) {
                      LikedSeriesLoading() => const Center(child: CircularProgressIndicator()),
                      LikedSeriesFailure(:final message) => AppErrorView(
                          message: message,
                          onRetry: () => context.read<LikedSeriesCubit>().getLikedSeries(),
                        ),
                      // The empty message belongs to the list rather than
                      // standing beside it, so taking back the last like folds
                      // the row away and leaves the message behind it.
                      LikedSeriesLoaded(:final series) => CollapsingList<SeriesEntity>(
                          items: series,
                          idOf: (item) => item.id,
                          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                          emptyBuilder: (context) => Center(
                            child: Text(context.l10n.likedSeriesEmpty, style: context.styles.meta),
                          ),
                          itemBuilder: (context, item, index) => _LikedSeriesRow(
                            series: item,
                            tag: posterHeroTag('liked-series', index: index, id: item.id),
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

/// The back arrow, the screen's name, and how many titles are under it.
class _Header extends StatelessWidget {
  final int? count;

  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xxl, AppSpacing.lg),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            label: context.l10n.backAction,
            isFilled: false,
            onPressed: () => context.router.maybePop(),
          ),
          AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.likedSeries, style: context.styles.screenTitle),
                if (count != null) ...[
                  AppGap.vertical(AppSpacing.xs / 2),
                  // The count reads "3 titles" either way, so the films and the
                  // series share it rather than each having their own.
                  Text(context.l10n.likedMoviesCount(count!).toUpperCase(), style: context.styles.sectionAction),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One liked title: its poster, what it is, and the heart that says why it is
/// in this list.
class _LikedSeriesRow extends StatelessWidget {
  final SeriesEntity series;
  final String tag;

  const _LikedSeriesRow({required this.series, required this.tag});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      // The series' own screen is where the like can be taken back, so the
      // list reads itself again once that screen is closed — otherwise the row
      // stays until the reader leaves and comes back.
      onTap: () async {
        final cubit = context.read<LikedSeriesCubit>();
        await context.router.push(SeriesDetailsRoute(series: series, heroTag: tag));
        await cubit.refresh();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: AppDecorations(palette).panel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62.w,
              child: PosterCard(
                imageUrl: series.posterPath?.coverImage ?? '',
                title: series.name ?? '',
                heroTag: tag,
              ),
            ),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          series.name ?? '',
                          style: context.styles.rowTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppGap.horizontal(AppSpacing.md),
                      if (series.voteAverage != null) ...[
                        Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
                        AppGap.horizontal(AppSpacing.xs),
                        Text(series.voteAverage!.toStringAsFixed(1), style: context.styles.ratingSmall),
                      ],
                    ],
                  ),
                  AppGap.vertical(AppSpacing.sm),
                  if (series.firstAirDate?.year case final year?) Text(year, style: context.styles.meta),
                  AppGap.vertical(AppSpacing.sm),
                  GenreTags(genreIds: series.genreIds, isSeries: true, limit: 2),
                ],
              ),
            ),
            AppGap.horizontal(AppSpacing.md),
            Icon(Icons.favorite_rounded, size: AppSpacing.xl, color: palette.accentSoft),
          ],
        ),
      ),
    );
  }
}
