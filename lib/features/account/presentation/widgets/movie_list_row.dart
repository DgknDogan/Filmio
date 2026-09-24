import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../movie/domain/entities/movie.dart';
import 'title_list_row.dart';

/// A film in an account list; opens its details on tap.
class MovieListRow extends StatelessWidget {
  final MovieEntity movie;
  final String heroTag;
  final IconData badge;

  const MovieListRow({super.key, required this.movie, required this.heroTag, required this.badge});

  @override
  Widget build(BuildContext context) {
    return TitleListRow(
      posterUrl: movie.posterPath?.coverImage ?? '',
      title: movie.title ?? '',
      year: movie.releaseDate?.year,
      rating: movie.voteAverage,
      genreIds: movie.genreIds,
      isSeries: false,
      heroTag: heroTag,
      badge: badge,
      onTap: () => context.router.push(MovieDetailsRoute(movie: movie, heroTag: heroTag)),
    );
  }
}
