import 'package:equatable/equatable.dart';

import '../../../../core/enums/movie_type.dart';
import '../../../../core/enums/series_type.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../movie/domain/entities/movie.dart';
import '../../../series/domain/entities/series_entity.dart';

/// What an account's lists add up to: how much is in them, and what the liked
/// titles have in common.
///
/// Derived, never stored. Every figure here comes out of the four arrays
/// already on the user document, so this costs no request of its own and
/// cannot disagree with the lists it describes.
///
/// Only the liked titles shape the taste figures. A watchlist is a statement
/// of intent rather than of taste — counting what somebody has not watched yet
/// among their favourite genres would describe a person they are not.
class TasteProfile extends Equatable {
  final int likedMovies;
  final int likedSeries;
  final int watchlistMovies;
  final int watchlistSeries;

  /// The genres that come up most often across the liked titles, most first.
  ///
  /// By name rather than by id: TMDB keeps separate id lists for film and
  /// television that overlap without matching, and a film's Drama and a
  /// series' Drama are the same taste.
  final List<String> topGenres;

  /// The decade most of the liked titles came out in, as `1990s`.
  final String? favouriteDecade;

  /// What the liked titles average on TMDB. Null when none of them carries a
  /// score, which is not the same as averaging zero.
  final double? averageRating;

  const TasteProfile({
    required this.likedMovies,
    required this.likedSeries,
    required this.watchlistMovies,
    required this.watchlistSeries,
    required this.topGenres,
    required this.favouriteDecade,
    required this.averageRating,
  });

  /// Nothing in any of the four lists, so there is nothing to say yet.
  bool get isEmpty => likedMovies == 0 && likedSeries == 0 && watchlistMovies == 0 && watchlistSeries == 0;

  /// Nothing liked, so the taste figures have nothing behind them even if
  /// there is a watchlist.
  bool get hasNoTaste => likedMovies == 0 && likedSeries == 0;

  int get watchlistTotal => watchlistMovies + watchlistSeries;

  factory TasteProfile.from({
    required List<MovieEntity> likedMovies,
    required List<SeriesEntity> likedSeries,
    required List<MovieEntity> watchlistMovies,
    required List<SeriesEntity> watchlistSeries,
  }) {
    final genres = <String, int>{};
    final decades = <int, int>{};
    final ratings = <double>[];

    void record({required List<int>? genreIds, required String? date, required double? rating, required bool isSeries}) {
      for (final id in genreIds ?? const <int>[]) {
        final name = _genreName(id, isSeries: isSeries);
        if (name != null) genres[name] = (genres[name] ?? 0) + 1;
      }

      final year = int.tryParse(date?.year ?? '');
      if (year != null) {
        final decade = year - year % 10;
        decades[decade] = (decades[decade] ?? 0) + 1;
      }

      if (rating != null && rating > 0) ratings.add(rating);
    }

    for (final movie in likedMovies) {
      record(genreIds: movie.genreIds, date: movie.releaseDate, rating: movie.voteAverage, isSeries: false);
    }

    for (final series in likedSeries) {
      record(genreIds: series.genreIds, date: series.firstAirDate, rating: series.voteAverage, isSeries: true);
    }

    final rankedDecades = _ranked(decades);

    return TasteProfile(
      likedMovies: likedMovies.length,
      likedSeries: likedSeries.length,
      watchlistMovies: watchlistMovies.length,
      watchlistSeries: watchlistSeries.length,
      topGenres: _ranked(genres).take(3).toList(),
      favouriteDecade: rankedDecades.isEmpty ? null : '${rankedDecades.first}s',
      averageRating: ratings.isEmpty ? null : ratings.reduce((a, b) => a + b) / ratings.length,
    );
  }

  /// The keys of [counts], the most counted first.
  ///
  /// A tie is broken by the key itself, descending — so the answer does not
  /// move between two reads of the same lists, and the later decade wins a
  /// draw, which is the one a reader would recognise as theirs.
  static List<T> _ranked<T extends Comparable<dynamic>>(Map<T, int> counts) {
    final keys = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : b.compareTo(a);
      });

    return keys;
  }

  /// The genre's name, or null for an id the app has no name for — TMDB adds
  /// genres, and an unknown one drops out of the profile rather than taking
  /// the screen down.
  static String? _genreName(int id, {required bool isSeries}) {
    try {
      return isSeries ? SeriesType.getEnumById(id: id) : MovieType.getEnumById(id: id);
    } on StateError {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        likedMovies,
        likedSeries,
        watchlistMovies,
        watchlistSeries,
        topGenres,
        favouriteDecade,
        averageRating,
      ];
}
