import 'package:json_annotation/json_annotation.dart';

part 'movie_recommendation_response.g.dart';

/// What `/recommendations/movies` answers with: the ids it picked, and how it
/// picked them.
///
/// Only [movieIds] reaches the domain — the rest is there because the service
/// sends it and dropping it from the model would make a change in the service
/// invisible here. It is useful when reading a log or a network trace.
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieRecommendationResponse {
  /// TMDB ids, best first.
  final List<int>? movieIds;

  /// How many ids came back.
  final int? count;

  /// How many liked titles the picks were derived from.
  final int? basedOn;

  /// Which of the service's strategies produced them: `personalized` when the
  /// likes were enough to build a profile from, `popular` when they were not.
  final String? strategy;

  const MovieRecommendationResponse({
    this.movieIds,
    this.count,
    this.basedOn,
    this.strategy,
  });

  factory MovieRecommendationResponse.fromJson(Map<String, dynamic> json) => _$MovieRecommendationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieRecommendationResponseToJson(this);
}
