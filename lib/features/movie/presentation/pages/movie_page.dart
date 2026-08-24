import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/cubit/session_cubit.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/browse_skeleton.dart';
import '../../../../core/custom/browse_view.dart';
import '../../../../core/custom/featured_hero.dart';
import '../../../../core/enums/discover_sort.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/genre_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/utils/hero_tags.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movie_bloc.dart';
import '../widgets/movie_poster_card.dart';

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
              MovieLoading() => const _Loading(),
              MovieError() => AppErrorView(message: state.failure.message),
            };
          },
        ),
      ),
    );
  }
}

/// The tab before its rows have arrived: the same block and the same two
/// headings, with the artwork still to come.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final hint = context.l10n.moviesSearchHint;

    return BrowseSkeleton(
      searchHeroTag: _searchHeroTag,
      searchHint: hint,
      onSearch: () => context.router.push(
        MovieSearchRoute(heroTag: _searchHeroTag, hintText: hint),
      ),
      rowTitles: [context.l10n.moviesPopular, context.l10n.moviesTop],
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
      featuredBuilder: (context, stretch) {
        // A guest has no recommendation to be waiting for: the service needs
        // an account to answer for, and refuses before it reaches the network.
        // Rather than showing that refusal, the head of the tab keeps its
        // usual shape and takes one of the top rated films instead.
        if (context.select((SessionCubit cubit) => cubit.state.isGuest)) {
          return _GuestHero(movies: state.topFilmsList, stretch: stretch);
        }

        return switch (state.recommended) {
          RecommendedMovieLoaded(:final movie) => _Hero(movie: movie, stretch: stretch),
          RecommendedMovieLoading() => FeaturedHeroSkeleton(stretch: stretch),
          RecommendedMovieEmpty() => _NoHero(message: context.l10n.recommendedEmpty),
          RecommendedMovieFailure(:final message) => _NoHero(message: message),
        };
      },
      rows: [
        BrowseRow(
          title: context.l10n.moviesPopular,
          storageKey: const PageStorageKey('popular_movies'),
          posters: _posters(state.popularFilmsList, 'movies-popular'),
          actionLabel: context.l10n.seeAll,
          onAction: () => _browseAll(context, context.l10n.moviesPopular, DiscoverSort.popularity),
        ),
        BrowseRow(
          title: context.l10n.moviesTop,
          storageKey: const PageStorageKey('top_movies'),
          posters: _posters(state.topFilmsList, 'movies-top'),
          actionLabel: context.l10n.seeAll,
          onAction: () => _browseAll(context, context.l10n.moviesTop, DiscoverSort.topRated),
        ),
      ],
    );
  }

  /// The whole catalogue the row is the head of, in the row's own order.
  void _browseAll(BuildContext context, String title, DiscoverSort sort) {
    context.router.push(MovieDiscoverRoute(title: title, sort: sort));
  }

  /// The two rows overlap — a film can be both popular and top rated — so each
  /// row scopes its own tags rather than naming the film.
  List<Widget> _posters(List<MovieEntity> movies, String scope) => [
        for (final (index, movie) in movies.indexed) MoviePosterCard(movie: movie, heroTag: posterHeroTag(scope, index: index, id: movie.id)),
      ];
}

/// The head of the tab with no title in it: the recommendation service had
/// nothing to suggest, or could not be reached. It holds the block's height so
/// the rows below start where they always do.
class _NoHero extends StatelessWidget {
  final String message;

  const _NoHero({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FeaturedHero.height,
      width: double.infinity,
      child: AppErrorView(message: message),
    );
  }
}

/// The head of the tab for a guest: one of the top rated films, drawn exactly
/// as a recommendation is.
///
/// Stateful because the choice has to survive a rebuild. The hero restretches
/// on every scroll frame, and a film chosen inside `build` would change on
/// each one. It is re-drawn only when the list itself is replaced.
class _GuestHero extends StatefulWidget {
  final List<MovieEntity> movies;
  final double stretch;

  const _GuestHero({required this.movies, required this.stretch});

  @override
  State<_GuestHero> createState() => _GuestHeroState();
}

class _GuestHeroState extends State<_GuestHero> {
  MovieEntity? _pick;

  @override
  void initState() {
    super.initState();
    _pick = _choose();
  }

  @override
  void didUpdateWidget(_GuestHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.movies, widget.movies)) _pick = _choose();
  }

  MovieEntity? _choose() {
    if (widget.movies.isEmpty) return null;
    return widget.movies[Random().nextInt(widget.movies.length)];
  }

  @override
  Widget build(BuildContext context) {
    final pick = _pick;
    if (pick == null) return FeaturedHeroSkeleton(stretch: widget.stretch);

    return _Hero(movie: pick, stretch: widget.stretch);
  }
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
