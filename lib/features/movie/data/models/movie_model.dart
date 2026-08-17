import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

/// The TMDB shape of a movie.
///
/// Deliberately does **not** extend [MovieEntity]: the mapping is explicit, so
/// a renamed TMDB field changes this file and nothing else.
///
/// The JSON keys are also what Firestore stores under `liked_movies`, so
/// changing a field name here rewrites data that already exists on the server.
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieModel {
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

  const MovieModel({
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

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  factory MovieModel.fromEntity(MovieEntity entity) => MovieModel(
        adult: entity.adult,
        backdropPath: entity.backdropPath,
        genreIds: entity.genreIds,
        id: entity.id,
        originalLanguage: entity.originalLanguage,
        originalTitle: entity.originalTitle,
        overview: entity.overview,
        popularity: entity.popularity,
        posterPath: entity.posterPath,
        releaseDate: entity.releaseDate,
        title: entity.title,
        video: entity.video,
        voteAverage: entity.voteAverage,
        voteCount: entity.voteCount,
      );

  MovieEntity toEntity() => MovieEntity(
        adult: adult,
        backdropPath: backdropPath,
        genreIds: genreIds,
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
