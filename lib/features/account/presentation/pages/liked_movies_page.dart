import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../cubit/liked_movies_cubit.dart';
import '../widgets/movie_list_row.dart';
import '../widgets/title_list_header.dart';

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
                  TitleListHeader(
                    title: context.l10n.likedMovies,
                    count: state is LikedMoviesLoaded ? state.movies.length : null,
                  ),
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
                          itemBuilder: (context, index) => MovieListRow(
                            movie: movies[index],
                            heroTag: posterHeroTag('liked-movies', index: index, id: movies[index].id),
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
