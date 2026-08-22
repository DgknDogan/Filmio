// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoApiResponse _$VideoApiResponseFromJson(Map<String, dynamic> json) =>
    VideoApiResponse(
      id: (json['id'] as num?)?.toInt(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideoApiResponseToJson(VideoApiResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'results': instance.results,
    };
