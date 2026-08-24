import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movie_detail_model.g.dart';

/// The TMDB shape of a single movie, as `/movie/{id}` returns it.
///
/// A list entry and a detail response are not the same payload, which is the
/// whole reason this model exists next to `MovieModel`: the detail response
/// names genres in full where a list entry carries bare ids. Everything the
/// app shows is common to both, so both map to the same [MovieEntity] and the
/// difference stops here.
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieDetailModel {
  final bool? adult;
  final String? backdropPath;
  final List<MovieGenreModel>? genres;
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

  const MovieDetailModel({
    this.adult,
    this.backdropPath,
    this.genres,
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

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) => _$MovieDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDetailModelToJson(this);

  /// The entity carries genre ids, so the named genres come back down to their
  /// ids here — `genre_extension` turns them into a label again where one is
  /// shown, and that way a title from this endpoint reads exactly like a title
  /// from a list one.
  MovieEntity toEntity() => MovieEntity(
        adult: adult,
        backdropPath: backdropPath,
        genreIds: genres?.map((genre) => genre.id).whereType<int>().toList(),
        id: id,
        originalLanguage: originalLanguage,
        originalTitle: originalTitle,
        overview: overview,
        popularity: popularity,
        posterPath: posterPath,
        releaseDate: releaseDate,
        title: title,
        video: video,
        voteAverage: voteAverage,
        voteCount: voteCount,
      );
}

/// One entry of the detail response's `genres` array.
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieGenreModel {
  final int? id;
  final String? name;

  const MovieGenreModel({this.id, this.name});

  factory MovieGenreModel.fromJson(Map<String, dynamic> json) => _$MovieGenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieGenreModelToJson(this);
}
