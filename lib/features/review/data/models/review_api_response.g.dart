// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewApiResponse _$ReviewApiResponseFromJson(Map<String, dynamic> json) =>
    ReviewApiResponse(
      id: (json['id'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
      totalResults: (json['total_results'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReviewApiResponseToJson(ReviewApiResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'page': instance.page,
      'results': instance.results,
      'total_pages': instance.totalPages,
      'total_results': instance.totalResults,
    };
