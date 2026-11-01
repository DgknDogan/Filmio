import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/cubit/title_list_cubit.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../../../injection_container.dart';
import '../../../movie/domain/entities/movie.dart';
import '../cubit/liked_movies_cubit.dart';
import '../widgets/title_list_view.dart';

@RoutePage()
class LikedMoviesPage extends StatelessWidget {
  const LikedMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LikedMoviesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<LikedMoviesCubit, TitleListState<MovieEntity>>(
            builder: (context, state) {
              return TitleListView<MovieEntity>(
                title: context.l10n.likedMovies,
                emptyMessage: context.l10n.likedMoviesEmpty,
                state: state,
                idOf: (movie) => movie.id,
                onRetry: () => context.read<LikedMoviesCubit>().load(),
                rowBuilder: (context, movie, index) {
                  final tag = posterHeroTag('liked-movies', index: index, id: movie.id);

                  return TitleListRow(
                    imageUrl: movie.posterPath?.coverImage ?? '',
                    title: movie.title ?? '',
                    year: movie.releaseDate?.year,
                    voteAverage: movie.voteAverage,
                    genreIds: movie.genreIds,
                    mark: Icons.favorite_rounded,
                    heroTag: tag,
                    // The film's own screen is where the like can be taken
                    // back, so the list reads itself again once that screen is
                    // closed — otherwise the row stays until the reader leaves
                    // and comes back.
                    onTap: () async {
                      final cubit = context.read<LikedMoviesCubit>();
                      await context.router.push(MovieDetailsRoute(movie: movie, heroTag: tag));
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
