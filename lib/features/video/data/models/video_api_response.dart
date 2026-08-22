import 'package:json_annotation/json_annotation.dart';

import 'video_model.dart';

part 'video_api_response.g.dart';

/// The videos endpoint is not paged: it answers with the title's id and every
/// video it has, so there is no envelope beyond these two fields.
@JsonSerializable(fieldRename: FieldRename.snake)
class VideoApiResponse {
  final int? id;
  final List<VideoModel>? results;

  VideoApiResponse({this.id, this.results});

  factory VideoApiResponse.fromJson(Map<String, dynamic> json) => _$VideoApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VideoApiResponseToJson(this);
}
