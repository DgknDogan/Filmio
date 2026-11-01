import 'package:shared_preferences/shared_preferences.dart';

/// When an account last changed what it likes.
///
/// The recommendation each tab opens on is derived from the liked titles, so
/// liking or un-liking one is what makes a cached recommendation wrong — and
/// it is the only thing that does, short of the service changing its mind.
/// A time-to-live alone cannot see that: it would keep serving yesterday's
/// picks to somebody who spent this morning liking things.
///
/// So the liked-title repositories leave a mark here, and the recommendation
/// caches refuse anything written before it.
///
/// One stamp for both catalogues rather than one each: the service is asked
/// separately for films and for series, but it is the same account's taste
/// behind both, and a film liked today may well be why its series picks should
/// move. Being wrong this way costs one request on the next launch — which is
/// what every launch used to cost. Being wrong the other way is the reader
/// seeing picks that ignore what they just liked.
///
/// In [SharedPreferences] rather than beside the caches in Hive: it is one
/// short string per account, which is exactly what preferences are for, and
/// keeping it out of either box is what lets both boxes depend on it.
class LikedTitlesStamp {
  static const _prefix = 'liked_titles_changed_at:';

  final SharedPreferences _preferences;

  const LikedTitlesStamp(this._preferences);

  /// When [userId] last liked or un-liked something, or null when they never
  /// have on this device — in which case nothing cached here can predate it.
  DateTime? changedAt(String userId) {
    final stored = _preferences.getString('$_prefix$userId');
    return stored == null ? null : DateTime.tryParse(stored);
  }

  Future<void> markChanged(String userId) {
    return _preferences.setString('$_prefix$userId', DateTime.now().toIso8601String());
  }
}
