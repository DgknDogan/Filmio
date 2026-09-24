import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  final bool? adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int? id;
  final String? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final String? releaseDate;
  final String? title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;

  const MovieEntity({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
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
        adult,
        backdropPath,
        genreIds,
        id,
        originalLanguage,
        originalTitle,
        overview,
        popularity,
        posterPath,
        releaseDate,
        title,
        video,
        voteAverage,
        voteCount,
      ];
}
