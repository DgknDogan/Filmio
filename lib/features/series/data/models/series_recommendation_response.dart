import 'package:json_annotation/json_annotation.dart';

part 'series_recommendation_response.g.dart';

/// What `/recommendations/series` answers with: the ids it picked, and how it
/// picked them.
///
/// Only [seriesIds] reaches the domain — the rest is there because the service
/// sends it and dropping it from the model would make a change in the service
/// invisible here. It is useful when reading a log or a network trace.
@JsonSerializable(fieldRename: FieldRename.snake)
class SeriesRecommendationResponse {
  /// TMDB television ids, best first.
  final List<int>? seriesIds;

  /// How many ids came back.
  final int? count;

  /// How many liked series the picks were derived from.
  final int? basedOn;

  /// Which of the service's strategies produced them: `personalized` when the
  /// likes were enough to build a profile from, `popular` when they were not.
  final String? strategy;

  const SeriesRecommendationResponse({
    this.seriesIds,
    this.count,
    this.basedOn,
    this.strategy,
  });

  factory SeriesRecommendationResponse.fromJson(Map<String, dynamic> json) => _$SeriesRecommendationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesRecommendationResponseToJson(this);
}
