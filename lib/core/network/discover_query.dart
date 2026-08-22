import '../enums/discover_sort.dart';
import '../enums/media_type.dart';
import '../models/discover_filters.dart';

/// Turns what the reader chose into what TMDB's discover endpoint expects.
///
/// Kept apart from the repository because it is the one part of discover with
/// rules in it — an empty filter has to become an absent parameter rather than
/// an empty one, and a year has to become a date — and because films and
/// series build the same query under different parameter names.
abstract final class DiscoverQuery {
  /// Below this many votes a 10/10 is one enthusiast rather than a rating.
  ///
  /// The two catalogues need different floors, and the numbers are measured
  /// rather than guessed: `/discover/tv` sorted by rating with a floor of 200
  /// reproduces `/tv/top_rated` exactly, and 400 is the closest a film floor
  /// gets to `/movie/top_rated` — which weights its ranking in a way discover
  /// cannot be asked for. A film gathers votes an order of magnitude faster
  /// than a series, so one floor for both would either bury television or let
  /// thinly-rated films in.
  static const movieVoteFloor = 400;
  static const seriesVoteFloor = 200;

  static String sortBy(DiscoverSort sort) => switch (sort) {
        DiscoverSort.popularity => 'popularity.desc',
        DiscoverSort.topRated => 'vote_average.desc',
      };

  /// The vote floor, which only the top-rated order needs.
  static int? voteCountFloor(DiscoverSort sort, MediaType mediaType) {
    if (sort != DiscoverSort.topRated) return null;

    return switch (mediaType) {
      MediaType.movie => movieVoteFloor,
      MediaType.series => seriesVoteFloor,
    };
  }

  /// Genres, as TMDB reads them: a pipe means any of these. A reader asking
  /// for action and comedy wants either, not a film that is both.
  static String? genres(DiscoverFilters filters) => filters.genreIds.isEmpty ? null : filters.genreIds.join('|');

  /// The first day of the earliest year asked for.
  static String? fromYear(int? year) => year == null ? null : '$year-01-01';

  /// The last day of the latest year asked for, so the year itself is included.
  static String? toYear(int? year) => year == null ? null : '$year-12-31';
}
