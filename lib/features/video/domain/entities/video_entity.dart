import 'package:equatable/equatable.dart';

/// Where a video is hosted. TMDB names several hosts; the two the app can
/// actually play are the two it names here, and anything else is [unknown] —
/// which is what keeps an unplayable host out of the UI rather than in front
/// of a player that cannot open it.
enum VideoSite {
  youtube,
  vimeo,
  unknown;

  /// TMDB writes these as `YouTube` and `Vimeo`, but the casing is theirs to
  /// change and ours to survive.
  static VideoSite fromName(String? name) => switch (name?.toLowerCase()) {
        'youtube' => VideoSite.youtube,
        'vimeo' => VideoSite.vimeo,
        _ => VideoSite.unknown,
      };
}

/// What kind of clip it is. TMDB has a longer list — Clip, Featurette, Behind
/// the Scenes, Bloopers — but only the two that are a trailer matter to the
/// choice being made, so the rest collapse into [other].
enum VideoType {
  trailer,
  teaser,
  other;

  static VideoType fromName(String? name) => switch (name?.toLowerCase()) {
        'trailer' => VideoType.trailer,
        'teaser' => VideoType.teaser,
        _ => VideoType.other,
      };
}

/// One video TMDB holds for a film or a series.
class VideoEntity extends Equatable {
  final String? id;
  final String? name;

  /// The host's own id for the video — a YouTube video id, or a numeric Vimeo
  /// id. It is what the player is pointed at.
  final String? key;

  final VideoSite site;

  /// The video's height in pixels: 1080, 720, 360. TMDB calls it `size`.
  final int? size;

  final VideoType type;

  /// Whether the studio published it, as opposed to a channel re-uploading it.
  final bool? official;

  /// ISO 8601, as sent.
  final String? publishedAt;

  final String? languageCode;
  final String? regionCode;

  const VideoEntity({
    this.id,
    this.name,
    this.key,
    this.site = VideoSite.unknown,
    this.size,
    this.type = VideoType.other,
    this.official,
    this.publishedAt,
    this.languageCode,
    this.regionCode,
  });

  /// Whether there is something here a player could open: a host the app
  /// supports, and a key to give it.
  bool get isPlayable => site != VideoSite.unknown && (key?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [id, name, key, site, size, type, official, publishedAt, languageCode, regionCode];
}
