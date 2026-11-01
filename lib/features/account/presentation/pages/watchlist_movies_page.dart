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
import '../cubit/watchlist_movies_cubit.dart';
import '../widgets/title_list_view.dart';

@RoutePage()
class WatchlistMoviesPage extends StatelessWidget {
  const WatchlistMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => WatchlistMoviesCubit(getIt()),
        child: SafeArea(
          child: BlocBuilder<WatchlistMoviesCubit, TitleListState<MovieEntity>>(
            builder: (context, state) {
              return TitleListView<MovieEntity>(
                title: context.l10n.watchlistMovies,
                emptyMessage: context.l10n.watchlistMoviesEmpty,
                state: state,
                idOf: (movie) => movie.id,
                onRetry: () => context.read<WatchlistMoviesCubit>().load(),
                rowBuilder: (context, movie, index) {
                  final tag = posterHeroTag('watchlist-movies', index: index, id: movie.id);

                  return TitleListRow(
                    imageUrl: movie.posterPath?.coverImage ?? '',
                    title: movie.title ?? '',
                    year: movie.releaseDate?.year,
                    voteAverage: movie.voteAverage,
                    genreIds: movie.genreIds,
                    mark: Icons.bookmark_rounded,
                    heroTag: tag,
                    // The film's own screen is where it can be taken out of the
                    // watchlist, so the list reads itself again once that screen is
                    // closed — otherwise the row stays until the reader leaves
                    // and comes back.
                    onTap: () async {
                      final cubit = context.read<WatchlistMoviesCubit>();
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
