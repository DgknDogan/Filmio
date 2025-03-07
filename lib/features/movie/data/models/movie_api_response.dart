import 'package:filmio/core/models/movie.dart' show MovieModel;
import 'package:json_annotation/json_annotation.dart';

part 'movie_api_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MovieApiResponse {
  final int? page;
  final List<MovieModel>? results;
  final int? totalPages;
  final int? totalResults;

  MovieApiResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieApiResponse.fromJson(Map<String, dynamic> json) => _$MovieApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieApiResponseToJson(this);
}
