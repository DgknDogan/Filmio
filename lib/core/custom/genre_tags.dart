import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../enums/movie_type.dart';
import '../enums/series_type.dart';
import 'app_tag.dart';

/// A title's genres, as chips.
///
/// The first chip takes the accent pair and the rest the neutral one: TMDB
/// orders the ids by relevance, so tinting the first is a way of saying which
/// genre the film actually is.
class GenreTags extends StatelessWidget {
  final List<int>? genreIds;

  /// Television has its own id list, which overlaps the film one without
  /// matching it.
  final bool isSeries;

  /// A row has less room than a details sheet.
  final int limit;

  const GenreTags({super.key, required this.genreIds, this.isSeries = false, this.limit = 3});

  @override
  Widget build(BuildContext context) {
    final names = (genreIds ?? const <int>[]).map((id) => _name(id)).nonNulls.take(limit).toList();

    if (names.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (index, name) in names.indexed) AppTag(name: name, isPrimary: index == 0),
      ],
    );
  }

  /// The enums throw on an id they do not carry, and TMDB does add genres —
  /// an unknown one drops out of the row rather than taking the screen down.
  String? _name(int id) {
    try {
      return isSeries ? SeriesType.getEnumById(id: id) : MovieType.getEnumById(id: id);
    } on StateError {
      return null;
    }
  }
}
