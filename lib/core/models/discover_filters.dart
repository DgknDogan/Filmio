import 'package:equatable/equatable.dart';

/// What the reader narrowed a browsed catalogue down to.
///
/// The same three questions for films and for series — genre, rating, year —
/// so the filter sheet is one widget and only the query each repository builds
/// out of this differs. Everything is optional: an empty instance means the
/// unfiltered catalogue.
class DiscoverFilters extends Equatable {
  /// TMDB genre ids. Empty means every genre; several means any of them.
  final Set<int> genreIds;

  /// Score, out of 10.
  final double? minRating;
  final double? maxRating;

  /// Release year for a film, first-air year for a series.
  final int? minYear;
  final int? maxYear;

  const DiscoverFilters({
    this.genreIds = const {},
    this.minRating,
    this.maxRating,
    this.minYear,
    this.maxYear,
  });

  static const none = DiscoverFilters();

  bool get isEmpty => this == none;

  /// How many of the three are set, for the count next to the filter control.
  int get activeCount => [
        genreIds.isNotEmpty,
        minRating != null || maxRating != null,
        minYear != null || maxYear != null,
      ].where((isSet) => isSet).length;

  /// Null is a value here — clearing a bound is as ordinary as setting one —
  /// so each field carries a flag rather than relying on `??`.
  DiscoverFilters copyWith({
    Set<int>? genreIds,
    double? minRating,
    bool clearMinRating = false,
    double? maxRating,
    bool clearMaxRating = false,
    int? minYear,
    bool clearMinYear = false,
    int? maxYear,
    bool clearMaxYear = false,
  }) {
    return DiscoverFilters(
      genreIds: genreIds ?? this.genreIds,
      minRating: clearMinRating ? null : minRating ?? this.minRating,
      maxRating: clearMaxRating ? null : maxRating ?? this.maxRating,
      minYear: clearMinYear ? null : minYear ?? this.minYear,
      maxYear: clearMaxYear ? null : maxYear ?? this.maxYear,
    );
  }

  @override
  List<Object?> get props => [genreIds, minRating, maxRating, minYear, maxYear];
}
