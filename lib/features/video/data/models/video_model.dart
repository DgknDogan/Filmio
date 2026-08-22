import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/video_entity.dart';

part 'video_model.g.dart';

/// The TMDB shape of a video. Identical for `/movie/{id}/videos` and
/// `/tv/{id}/videos`, which is why one model serves both features.
///
/// Deliberately does **not** extend [VideoEntity]: the mapping is explicit, so
/// a renamed TMDB field changes this file and nothing else. It is also where
/// the two free-text fields TMDB sends — `site` and `type` — become the enums
/// the domain reasons about.
@JsonSerializable(fieldRename: FieldRename.snake)
class VideoModel {
  final String? id;
  final String? name;
  final String? key;
  final String? site;

  /// The video's height in pixels: 1080, 720, 360.
  final int? size;

  final String? type;
  final bool? official;
  final String? publishedAt;

  @JsonKey(name: 'iso_639_1')
  final String? iso6391;

  @JsonKey(name: 'iso_3166_1')
  final String? iso31661;

  const VideoModel({
    this.id,
    this.name,
    this.key,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
    this.iso6391,
    this.iso31661,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  VideoEntity toEntity() => VideoEntity(
        id: id,
        name: name,
        key: key,
        site: VideoSite.fromName(site),
        size: size,
        type: VideoType.fromName(type),
        official: official,
        publishedAt: publishedAt,
        languageCode: iso6391,
        regionCode: iso31661,
      );
}
