import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'series_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SeriesModel with EquatableMixin {
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
  final int? voteAverage;
  final int? voteCount;

  SeriesModel({
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

  SeriesModel copyWith({
    String? backdropPath,
    String? firstAirDate,
    List<int>? genreIds,
    int? id,
    String? name,
    List<String>? originCountry,
    String? originalLanguage,
    String? originalName,
    String? overview,
    double? popularity,
    String? posterPath,
    int? voteAverage,
    int? voteCount,
  }) {
    return SeriesModel(
      backdropPath: backdropPath ?? this.backdropPath,
      firstAirDate: firstAirDate ?? this.firstAirDate,
      genreIds: genreIds ?? this.genreIds,
      id: id ?? this.id,
      name: name ?? this.name,
      originCountry: originCountry ?? this.originCountry,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      originalName: originalName ?? this.originalName,
      overview: overview ?? this.overview,
      popularity: popularity ?? this.popularity,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}
