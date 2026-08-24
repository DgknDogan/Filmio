import 'package:equatable/equatable.dart';

/// Where a video is hosted. TMDB names several hosts; [vimeo] is still
/// recognised so that a Vimeo video is understood rather than mistaken for a
/// malformed one, but only [youtube] can be opened — see [isPlayable].
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

  /// Whether the app can offer this video at all: a YouTube video, with a key
  /// to build a watch link from.
  ///
  /// YouTube only, deliberately. A trailer is handed to the YouTube app (or
  /// the browser), which is the one way to play it that stays inside YouTube's
  /// terms of use — and the only way App Review guideline 5.2.3 accepts
  /// without a licence to show for it. Vimeo has no equivalent hand-off worth
  /// the second integration for the handful of titles that use it, so a Vimeo
  /// video is treated as no trailer at all and the block simply does not
  /// appear.
  bool get isPlayable => site == VideoSite.youtube && (key?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [id, name, key, site, size, type, official, publishedAt, languageCode, regionCode];
}
