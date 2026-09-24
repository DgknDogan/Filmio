import 'package:equatable/equatable.dart';

class SeriesEntity with EquatableMixin {
  final String? backdropPath;
  final String? firstAirDate;
  final List<int>? genreIds;
  final int? id;
  final String? name;
  final List<String>? originCountry;
  final String? originalLanguage;
  final String? originalName;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final double? voteAverage;
  final int? voteCount;

  const SeriesEntity({
    this.backdropPath,
    this.firstAirDate,
    this.genreIds,
    this.id,
    this.name,
    this.originCountry,
    this.originalLanguage,
    this.originalName,
    this.overview,
    this.popularity,
    this.posterPath,
    this.voteAverage,
    this.voteCount,
  });

  /// Whether the app can actually draw this title.
  ///
  /// TMDB's catalogue is crowd-maintained, so a title can arrive with no
  /// artwork or no description at all. A poster card with a placeholder where
  /// the artwork should be, or a details screen with nothing under the
  /// heading, reads as a broken app rather than a thin entry — so a title
  /// missing either never reaches the UI. The repository is where it is
  /// dropped, once, rather than each screen filtering for itself.
  bool get isShowable => posterPath != null && (overview?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props => [
        backdropPath,
        firstAirDate,
        genreIds,
        id,
        name,
        originCountry,
        originalLanguage,
        originalName,
        overview,
        popularity,
        posterPath,
        voteAverage,
        voteCount
      ];
}
