// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_recommendation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieRecommendationResponse _$MovieRecommendationResponseFromJson(
        Map<String, dynamic> json) =>
    MovieRecommendationResponse(
      movieIds: (json['movie_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      count: (json['count'] as num?)?.toInt(),
      basedOn: (json['based_on'] as num?)?.toInt(),
      strategy: json['strategy'] as String?,
    );

Map<String, dynamic> _$MovieRecommendationResponseToJson(
        MovieRecommendationResponse instance) =>
    <String, dynamic>{
      'movie_ids': instance.movieIds,
      'count': instance.count,
      'based_on': instance.basedOn,
      'strategy': instance.strategy,
    };
