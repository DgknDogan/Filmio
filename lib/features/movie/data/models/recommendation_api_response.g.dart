// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationApiResponse _$RecommendationApiResponseFromJson(Map<String, dynamic> json) => RecommendationApiResponse(
      movieIds: (json['movie_ids'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      count: (json['count'] as num?)?.toInt(),
      basedOn: (json['based_on'] as num?)?.toInt(),
      strategy: json['strategy'] as String?,
    );

Map<String, dynamic> _$RecommendationApiResponseToJson(RecommendationApiResponse instance) => <String, dynamic>{
      'movie_ids': instance.movieIds,
      'count': instance.count,
      'based_on': instance.basedOn,
      'strategy': instance.strategy,
    };
