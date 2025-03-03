import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/series_entity.dart';

part 'series_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SeriesModel extends SeriesEntity {
  SeriesModel({
    super.backdropPath,
    super.firstAirDate,
    super.genreIds,
    super.id,
    super.name,
    super.originCountry,
    super.originalLanguage,
    super.originalName,
    super.overview,
    super.popularity,
    super.posterPath,
    super.voteAverage,
    super.voteCount,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) => _$SeriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesModelToJson(this);
}
