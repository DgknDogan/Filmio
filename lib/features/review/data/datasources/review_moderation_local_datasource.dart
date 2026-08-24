import 'package:shared_preferences/shared_preferences.dart';

/// The only place the moderation choices are read from or written to disk.
///
/// Local on purpose. Blocking is one reader's decision about what they want to
/// see, not a claim about the author, and it should work signed out and
/// offline. Reports are the part that leaves the device.
class ReviewModerationLocalDataSource {
  static const _blockedAuthorsKey = 'blocked_review_authors';
  static const _hiddenReviewsKey = 'hidden_review_ids';

  final SharedPreferences _preferences;

  const ReviewModerationLocalDataSource(this._preferences);

  Set<String> get blockedAuthors => _read(_blockedAuthorsKey);

  Set<String> get hiddenReviewIds => _read(_hiddenReviewsKey);

  Future<void> blockAuthor(String author) => _add(_blockedAuthorsKey, author);

  Future<void> hideReview(String reviewId) => _add(_hiddenReviewsKey, reviewId);

  Set<String> _read(String key) => (_preferences.getStringList(key) ?? const []).toSet();

  Future<void> _add(String key, String value) {
    final stored = _read(key)..add(value);
    return _preferences.setStringList(key, stored.toList());
  }
}
