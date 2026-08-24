// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_recommendation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesRecommendationResponse _$SeriesRecommendationResponseFromJson(Map<String, dynamic> json) => SeriesRecommendationResponse(
      seriesIds: (json['series_ids'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      count: (json['count'] as num?)?.toInt(),
      basedOn: (json['based_on'] as num?)?.toInt(),
      strategy: json['strategy'] as String?,
    );

Map<String, dynamic> _$SeriesRecommendationResponseToJson(SeriesRecommendationResponse instance) => <String, dynamic>{
      'series_ids': instance.seriesIds,
      'count': instance.count,
      'based_on': instance.basedOn,
      'strategy': instance.strategy,
    };
