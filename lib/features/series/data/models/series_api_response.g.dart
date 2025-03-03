// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesApiResponse _$SeriesApiResponseFromJson(Map<String, dynamic> json) =>
    SeriesApiResponse(
      page: (json['page'] as num?)?.toInt(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      totalResults: (json['totalResults'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SeriesApiResponseToJson(SeriesApiResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'results': instance.results,
      'totalPages': instance.totalPages,
      'totalResults': instance.totalResults,
    };
