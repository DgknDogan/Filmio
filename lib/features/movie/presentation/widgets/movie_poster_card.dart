import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../domain/entities/movie.dart';

/// A film's poster, and the way into the film.
///
/// Every screen that lists films — the tab, the search results, the browse
/// grid, the similar row on a details page — puts the same three lines in
/// front of [PosterCard]: the artwork path resolved, the title for the screen
/// reader, and a push to the details route. They live here once instead.
class MoviePosterCard extends StatelessWidget {
  final MovieEntity movie;

  /// What the poster flies on. Rows overlap — a film can be both popular and
  /// top rated — so the tag is scoped by the row that draws it rather than by
  /// the film.
  final String heroTag;

  const MoviePosterCard({super.key, required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return PosterCard(
      imageUrl: movie.posterPath?.coverImage ?? '',
      title: movie.title ?? '',
      heroTag: heroTag,
      onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: heroTag)),
    );
  }
}
