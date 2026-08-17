import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/browse_view.dart';
import '../../../../core/custom/featured_hero.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/genre_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movie_bloc.dart';

/// The featured title's poster can also appear in a row further down, so its
/// tag is the banner's own rather than the title's.
const _featuredHeroTag = 'movie_featured_poster';

/// The search control and the search screen's field are the same object at two
/// widths, so they share a tag and the one becomes the other.
const _searchHeroTag = 'movie_searchbar';

@RoutePage()
class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MovieBloc>(),
      child: Scaffold(
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            return switch (state) {
              MovieSuccess() => _Content(state: state),
              MovieLoading() => const Center(child: CircularProgressIndicator()),
              MovieError() => AppErrorView(message: state.failure.message),
            };
          },
        ),
      ),
    );
  }
}

/// What the films tab puts into [BrowseView]: a recommendation at the head of
/// the page, then the rows.
class _Content extends StatelessWidget {
  final MovieSuccess state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final hint = context.l10n.moviesSearchHint;

    return BrowseView(
      searchHeroTag: _searchHeroTag,
      searchHint: hint,
      onSearch: () => context.router.push(
        MovieSearchRoute(heroTag: _searchHeroTag, hintText: hint),
      ),
      featuredBuilder: (context, stretch) => _Hero(movie: state.recommendedMovie, stretch: stretch),
      rows: [
        BrowseRow(
          title: context.l10n.moviesPopular,
          storageKey: const PageStorageKey('popular_movies'),
          posters: _posters(state.popularFilmsList, 'movies-popular'),
        ),
        BrowseRow(
          title: context.l10n.moviesTop,
          storageKey: const PageStorageKey('top_movies'),
          posters: _posters(state.topFilmsList, 'movies-top'),
        ),
      ],
    );
  }

  /// The two rows overlap — a film can be both popular and top rated — so each
  /// row scopes its own tags rather than naming the film.
  List<Widget> _posters(List<MovieEntity> movies, String scope) => [
        for (final (index, movie) in movies.indexed)
          _MoviePoster(movie: movie, tag: posterHeroTag(scope, index: index, id: movie.id)),
      ];
}

class _Hero extends StatelessWidget {
  final MovieEntity movie;
  final double stretch;

  const _Hero({required this.movie, required this.stretch});

  @override
  Widget build(BuildContext context) {
    return FeaturedHero(
      imageUrl: movie.backdropPath?.coverImage ?? movie.posterPath?.coverImage ?? '',
      posterUrl: movie.posterPath?.coverImage ?? '',
      kicker: context.l10n.recommendedForYou,
      title: movie.title ?? '',
      rating: movie.voteAverage,
      metaParts: [movie.genreIds.firstMovieGenre],
      heroTag: _featuredHeroTag,
      actionLabel: context.l10n.detailsAction,
      stretch: stretch,
      onAction: () => context.router.push(
        MovieDetailsRoute(movie: movie, heroTag: _featuredHeroTag),
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final MovieEntity movie;
  final String tag;

  const _MoviePoster({required this.movie, required this.tag});

  @override
  Widget build(BuildContext context) {
    final meta = [movie.releaseDate?.year, movie.voteAverage?.toStringAsFixed(1)].nonNulls.join(' · ');

    return PosterCard(
      imageUrl: movie.posterPath?.coverImage ?? '',
      title: movie.title ?? '',
      meta: meta,
      heroTag: tag,
      onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: tag)),
    );
  }
}
