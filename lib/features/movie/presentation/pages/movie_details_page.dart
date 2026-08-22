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
import '../../domain/entities/movie.dart';
import '../cubit/movie_details_cubit.dart';
import '../widgets/movie_poster_card.dart';

@RoutePage()
class MovieDetailsPage extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;

  const MovieDetailsPage({super.key, required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    // Both cubits are stood up here rather than inside the widgets that read
    // them: the reviews block is one of several things hung off the details
    // sheet, and the page is what knows which film it is showing.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MovieDetailsCubit(
            getIt(),
            getIt(),
            movie,
            getIt(),
            getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => ReviewsCubit(getIt(), mediaId: movie.id, mediaType: MediaType.movie),
        ),
        BlocProvider(
          create: (context) => TrailerCubit(getIt(), mediaId: movie.id, mediaType: MediaType.movie),
        ),
      ],
      child: _DetailsView(
        movie: movie,
        heroTag: heroTag,
      ),
    );
  }
}

/// The shared details screen with the two things only a film has hung off it:
/// the heart in the bar, and the row of similar titles under the synopsis.
class _DetailsView extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;

  const _DetailsView({required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final backdropUrl = movie.backdropPath?.coverImage ?? movie.posterPath?.coverImage ?? '';

    return DetailsScaffold(
      backdropUrl: backdropUrl,
      posterUrl: movie.posterPath?.coverImage ?? '',
      title: movie.title ?? '',
      heroTag: heroTag,
      year: movie.releaseDate?.year,
      rating: movie.voteAverage,
      voteCount: movie.voteCount,
      genreIds: movie.genreIds,
      overview: movie.overview,
      action: _LikeButton(movie: movie),
      extras: [
        // The trailer sits directly under the synopsis: it is the one thing on
        // this page you can actually watch.
        TrailerSection(fallbackImageUrl: backdropUrl),
        const _SimilarMovies(),
        const ReviewsSection(),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  final MovieEntity movie;

  const _LikeButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    // Only the like flag matters here, so only it triggers a rebuild.
    return BlocSelector<MovieDetailsCubit, MovieDetailsState, bool>(
      selector: (state) => state.isMovieLiked,
      builder: (context, isLiked) {
        return CircleIconButton(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: isLiked ? context.l10n.unlikeAction : context.l10n.likeAction,
          iconColor: context.palette.accentSoft,
          onPressed: () =>
              isLiked ? context.read<MovieDetailsCubit>().dislikeMovie(movie: movie) : context.read<MovieDetailsCubit>().likeMovie(movie: movie),
        );
      },
    );
  }
}

class _SimilarMovies extends StatelessWidget {
  const _SimilarMovies();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.sheet,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, 0, 0),
        child: BlocSelector<MovieDetailsCubit, MovieDetailsState, SimilarMoviesState>(
          selector: (state) => state.similars,
          builder: (context, similars) {
            return switch (similars) {
              SimilarMoviesLoading() => SizedBox(height: 168.h, child: const Center(child: CircularProgressIndicator())),
              SimilarMoviesFailure(:final message) => Text(message, style: context.styles.meta),
              SimilarMoviesLoaded(:final movies) when movies.isEmpty => const SizedBox.shrink(),
              SimilarMoviesLoaded(:final movies) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppInsets.right,
                      child: SectionHeader(title: context.l10n.similarTitles),
                    ),
                    AppGap.vertical(AppSpacing.md),
                    SizedBox(
                      height: 144.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: AppInsets.right,
                        itemCount: movies.length,
                        separatorBuilder: (context, index) => AppGap.horizontal(AppSpacing.md),
                        itemBuilder: (context, index) {
                          final similar = movies[index];
                          final tag = posterHeroTag('movie-similar', index: index, id: similar.id);

                          return SizedBox(
                            width: 96.w,
                            child: MoviePosterCard(movie: similar, heroTag: tag),
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
