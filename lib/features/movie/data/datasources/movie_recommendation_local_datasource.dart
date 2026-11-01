import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/storage/liked_titles_stamp.dart';

import '../../domain/entities/movie.dart';
import '../models/movie_model.dart';

/// The recommendation the films tab opens on, kept between launches.
///
/// Asking the service for it costs one request for the ids and one more per
/// title, every time the app starts — the most expensive thing the tab does,
/// for an answer that changes at most a few times a day. So the answer is
/// written here and read back until it is [_ttl] old.
///
/// Stored as the JSON the API already answered with rather than through a Hive
/// adapter: [MovieModel] is then the only reader of the shape, and a generated
/// adapter cannot fall out of step with it. An entry written by an older
/// version that no longer parses is treated as no entry at all.
///
/// Keyed by user id, because the recommendation is about the account rather
/// than about the device: signing in as somebody else reads their own entry
/// instead of theirs, and signing back in finds the tab where it was left.
///
/// An entry also stops standing the moment the account likes or un-likes
/// something, however young it is — see [LikedTitlesStamp]. The picks are
/// derived from the liked titles, so a reader who has just liked three films
/// should not be shown what the service made of the two before them.
class MovieRecommendationLocalDataSource {
  /// The Hive box this cache lives in. Opened once, in `initDependencies`.
  static const boxName = 'recommended_movies';

  /// How long an entry stands before the service is asked again.
  static const _ttl = Duration(hours: 6);

  static const _cachedAtKey = 'cached_at';
  static const _moviesKey = 'movies';

  final Box<String> _box;

  /// When the account last changed what it likes, which is the other way an
  /// entry can stop standing.
  final LikedTitlesStamp _likes;

  MovieRecommendationLocalDataSource(this._box, this._likes);

  /// What was cached for [userId], or null when nothing was, when what was is
  /// older than [_ttl] or predates their last like, or when it can no longer
  /// be read.
  ///
  /// An empty list is a cached answer like any other — the service having
  /// nothing to suggest for an account that has liked little is worth
  /// remembering too, or every launch asks again to be told the same thing.
  /// [ignoreAge] is what the repository falls back to when the service cannot
  /// be reached: a stale block is better than an empty one.
  List<MovieEntity>? read(String userId, {bool ignoreAge = false}) {
    final raw = _box.get(userId);
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;

      if (!ignoreAge) {
        final cachedAt = DateTime.tryParse(entry[_cachedAtKey] as String? ?? '');
        if (cachedAt == null || DateTime.now().difference(cachedAt) > _ttl) return null;

        final likedAt = _likes.changedAt(userId);
        if (likedAt != null && likedAt.isAfter(cachedAt)) return null;
      }

      return (entry[_moviesKey] as List<dynamic>).map((movie) => MovieModel.fromJson(Map<String, dynamic>.from(movie as Map)).toEntity()).toList();
    } on Object {
      // Anything unreadable is a cache miss, not a crash: the service is
      // still there to ask.
      return null;
    }
  }

  Future<void> write(String userId, List<MovieEntity> movies) {
    final entry = {
      _cachedAtKey: DateTime.now().toIso8601String(),
      _moviesKey: [for (final movie in movies) MovieModel.fromEntity(movie).toJson()],
    };

    return _box.put(userId, jsonEncode(entry));
  }
}
