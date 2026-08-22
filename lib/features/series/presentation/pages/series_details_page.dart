import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/custom/details_scaffold.dart';
import '../../../../core/custom/section_header.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/enums/media_type.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../../../review/presentation/cubit/reviews_cubit.dart';
import '../../../review/presentation/widgets/reviews_section.dart';
import '../../../video/presentation/cubit/trailer_cubit.dart';
import '../../../video/presentation/widgets/trailer_section.dart';
import '../../domain/entities/series_entity.dart';
import '../cubit/series_details_cubit.dart';
import '../widgets/series_poster_card.dart';

@RoutePage()
class SeriesDetailsPage extends StatelessWidget {
  final SeriesEntity series;
  final String heroTag;

  const SeriesDetailsPage({super.key, required this.series, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    // Both cubits are stood up here rather than inside the widgets that read
    // them: the reviews block is one of several things hung off the details
    // sheet, and the page is what knows which series it is showing.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SeriesDetailsCubit(
            getIt(),
            getIt(),
            series,
            getIt(),
            getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => ReviewsCubit(getIt(), mediaId: series.id, mediaType: MediaType.series),
        ),
        BlocProvider(
          create: (context) => TrailerCubit(getIt(), mediaId: series.id, mediaType: MediaType.series),
        ),
      ],
      child: _DetailsView(series: series, heroTag: heroTag),
    );
  }
}

/// The shared details screen with the two things a title carries beyond its
/// own record: the heart in the bar, and the row of similar titles under the
/// synopsis. The same shape a film's details page has.
class _DetailsView extends StatelessWidget {
  final SeriesEntity series;
  final String heroTag;

  const _DetailsView({required this.series, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final backdropUrl = series.backdropPath?.coverImage ?? series.posterPath?.coverImage ?? '';

    return DetailsScaffold(
      backdropUrl: backdropUrl,
      posterUrl: series.posterPath?.coverImage ?? '',
      title: series.name ?? '',
      heroTag: heroTag,
      year: series.firstAirDate?.year,
      rating: series.voteAverage,
      voteCount: series.voteCount,
      genreIds: series.genreIds,
      isSeries: true,
      overview: series.overview,
      action: _LikeButton(series: series),
      extras: [
        // The trailer sits directly under the synopsis: it is the one thing on
        // this page you can actually watch.
        TrailerSection(fallbackImageUrl: backdropUrl),
        const _SimilarSeries(),
        const ReviewsSection(),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  final SeriesEntity series;

  const _LikeButton({required this.series});

  @override
  Widget build(BuildContext context) {
    // Only the like flag matters here, so only it triggers a rebuild.
    return BlocSelector<SeriesDetailsCubit, SeriesDetailsState, bool>(
      selector: (state) => state.isSeriesLiked,
      builder: (context, isLiked) {
        return CircleIconButton(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: isLiked ? context.l10n.unlikeAction : context.l10n.likeAction,
          iconColor: context.palette.accentSoft,
          onPressed: () => isLiked
              ? context.read<SeriesDetailsCubit>().dislikeSeries(series: series)
              : context.read<SeriesDetailsCubit>().likeSeries(series: series),
        );
      },
    );
  }
}

class _SimilarSeries extends StatelessWidget {
  const _SimilarSeries();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.sheet,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, 0, 0),
        child: BlocSelector<SeriesDetailsCubit, SeriesDetailsState, SimilarSeriesState>(
          selector: (state) => state.similars,
          builder: (context, similars) {
            return switch (similars) {
              SimilarSeriesLoading() => SizedBox(height: 168.h, child: const Center(child: CircularProgressIndicator())),
              SimilarSeriesFailure(:final message) => Text(message, style: context.styles.meta),
              SimilarSeriesLoaded(:final series) when series.isEmpty => const SizedBox.shrink(),
              SimilarSeriesLoaded(:final series) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppInsets.right,
                      child: SectionHeader(title: context.l10n.similarSeries),
                    ),
                    AppGap.vertical(AppSpacing.md),
                    SizedBox(
                      height: 144.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: AppInsets.right,
                        itemCount: series.length,
                        separatorBuilder: (context, index) => AppGap.horizontal(AppSpacing.md),
                        itemBuilder: (context, index) {
                          final similar = series[index];
                          final tag = posterHeroTag('series-similar', index: index, id: similar.id);
                          return SizedBox(
                            width: 96.w,
                            child: SeriesPosterCard(series: similar, heroTag: tag),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}
