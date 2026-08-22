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
import '../../../movie/domain/entities/movie.dart';
import '../cubit/liked_movies_cubit.dart';

@RoutePage()
class LikedMoviesPage extends StatelessWidget {
  const LikedMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LikedMoviesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<LikedMoviesCubit, LikedMoviesState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(count: state is LikedMoviesLoaded ? state.movies.length : null),
                  Expanded(
                    child: switch (state) {
                      LikedMoviesLoading() => const Center(child: CircularProgressIndicator()),
                      LikedMoviesFailure(:final message) => AppErrorView(
                          message: message,
                          onRetry: () => context.read<LikedMoviesCubit>().getLikedMovies(),
                        ),
                      LikedMoviesLoaded(:final movies) when movies.isEmpty => Center(
                          child: Text(context.l10n.likedMoviesEmpty, style: context.styles.meta),
                        ),
                      LikedMoviesLoaded(:final movies) => ListView.separated(
                          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                          itemCount: movies.length,
                          separatorBuilder: (context, index) => AppGap.vertical(AppSpacing.md),
                          itemBuilder: (context, index) => _LikedMovieRow(
                            movie: movies[index],
                            tag: posterHeroTag('liked-movies', index: index, id: movies[index].id),
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
                Text(context.l10n.likedMovies, style: context.styles.screenTitle),
                if (count != null) ...[
                  AppGap.vertical(AppSpacing.xs / 2),
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
class _LikedMovieRow extends StatelessWidget {
  final MovieEntity movie;
  final String tag;

  const _LikedMovieRow({required this.movie, required this.tag});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: tag)),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: AppDecorations(palette).panel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62.w,
              child: PosterCard(
                imageUrl: movie.posterPath?.coverImage ?? '',
                title: movie.title ?? '',
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
                          movie.title ?? '',
                          style: context.styles.rowTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppGap.horizontal(AppSpacing.md),
                      if (movie.voteAverage != null) ...[
                        Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
                        AppGap.horizontal(AppSpacing.xs),
                        Text(movie.voteAverage!.toStringAsFixed(1), style: context.styles.ratingSmall),
                      ],
                    ],
                  ),
                  AppGap.vertical(AppSpacing.sm),
                  if (movie.releaseDate?.year case final year?) Text(year, style: context.styles.meta),
                  AppGap.vertical(AppSpacing.sm),
                  GenreTags(genreIds: movie.genreIds, limit: 2),
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
