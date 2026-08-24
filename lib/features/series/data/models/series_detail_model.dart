import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/genre_model.dart';
import '../../domain/entities/series_entity.dart';

part 'series_detail_model.g.dart';

/// The TMDB shape of a single series, as `/tv/{id}` returns it.
///
/// A list entry and a detail response are not the same payload, which is the
/// whole reason this model exists next to `SeriesModel`: the detail response
/// names genres in full where a list entry carries bare ids. Everything the
/// app shows is common to both, so both map to the same [SeriesEntity] and the
/// difference stops here.
@JsonSerializable(fieldRename: FieldRename.snake)
class SeriesDetailModel {
  final String? backdropPath;
  final String? firstAirDate;
  final List<GenreModel>? genres;
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

  const SeriesDetailModel({
    this.backdropPath,
    this.firstAirDate,
    this.genres,
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

  factory SeriesDetailModel.fromJson(Map<String, dynamic> json) => _$SeriesDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesDetailModelToJson(this);

  /// The entity carries genre ids, so the named genres come back down to their
  /// ids here — `genre_extension` turns them into a label again where one is
  /// shown, and that way a series from this endpoint reads exactly like one
  /// from a list endpoint.
  SeriesEntity toEntity() => SeriesEntity(
        backdropPath: backdropPath,
        firstAirDate: firstAirDate,
        genreIds: genres.ids,
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
