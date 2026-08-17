import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/series_entity.dart';

part 'series_model.g.dart';

/// The TMDB shape of a series. See [MovieModel] for why this does not extend
/// its entity.
///
/// The JSON keys are also what Firestore stores under `liked_series`, so
/// changing a field name here rewrites data that already exists on the server.
@JsonSerializable(fieldRename: FieldRename.snake)
class SeriesModel {
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

  const SeriesModel({
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

  factory SeriesModel.fromJson(Map<String, dynamic> json) => _$SeriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesModelToJson(this);

  /// The way back out of the domain, for writing a liked series to Firestore.
  factory SeriesModel.fromEntity(SeriesEntity entity) => SeriesModel(
        backdropPath: entity.backdropPath,
        firstAirDate: entity.firstAirDate,
        genreIds: entity.genreIds,
        id: entity.id,
        name: entity.name,
        originCountry: entity.originCountry,
        originalLanguage: entity.originalLanguage,
        originalName: entity.originalName,
        overview: entity.overview,
        popularity: entity.popularity,
        posterPath: entity.posterPath,
        voteAverage: entity.voteAverage,
        voteCount: entity.voteCount,
      );

  SeriesEntity toEntity() => SeriesEntity(
        backdropPath: backdropPath,
        firstAirDate: firstAirDate,
        genreIds: genreIds,
        id: id,
        name: name,
        originCountry: originCountry,
        originalLanguage: originalLanguage,
        originalName: originalName,
        overview: overview,
        popularity: popularity,
        posterPath: posterPath,
        voteAverage: voteAverage,
        voteCount: voteCount,
      );
}
