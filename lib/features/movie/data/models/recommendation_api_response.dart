import 'package:json_annotation/json_annotation.dart';

part 'recommendation_api_response.g.dart';

/// What Filmio's recommendation service answers with: the ids it picked, and
/// how it picked them.
///
/// Only [movieIds] reaches the domain — the rest is there because the service
/// sends it and dropping it from the model would make a change in the service
/// invisible here. It is useful when reading a log or a network trace.
@JsonSerializable(fieldRename: FieldRename.snake)
class RecommendationApiResponse {
  /// TMDB ids, best first. The service sends an empty list when the user has
  /// liked too little for it to have an opinion.
  final List<int>? movieIds;

  /// How many ids came back.
  final int? count;

  /// How many liked titles the picks were derived from.
  final int? basedOn;

  /// Which of the service's strategies produced them.
  final String? strategy;

  const RecommendationApiResponse({
    this.movieIds,
    this.count,
    this.basedOn,
    this.strategy,
  });

  factory RecommendationApiResponse.fromJson(Map<String, dynamic> json) => _$RecommendationApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationApiResponseToJson(this);
}
