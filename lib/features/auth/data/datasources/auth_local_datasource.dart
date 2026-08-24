import 'package:shared_preferences/shared_preferences.dart';

/// Persists the small, non-sensitive auth flags.
///
/// No credential is ever written here. Firebase Auth owns the session; the
/// only thing this stores is whether that session should survive a cold start.
class AuthLocalDataSource {
  static const _rememberedKey = 'is_remembered';

  /// Whether the reader chose to look around without an account. There is no
  /// Firebase user behind a guest at all — this flag is the whole session.
  static const _guestKey = 'is_guest';

  /// Keys an earlier version of the app used to store the e-mail and password
  /// in plaintext. Kept only so [purgeLegacyCredentials] can delete them.
  static const _legacyEmailKey = 'email';
  static const _legacyPasswordKey = 'password';

  final SharedPreferences _preferences;

  const AuthLocalDataSource(this._preferences);

  bool get isRemembered => _preferences.getBool(_rememberedKey) ?? false;

  bool get isGuest => _preferences.getBool(_guestKey) ?? false;

  Future<void> setGuest(bool value) => _preferences.setBool(_guestKey, value);

  Future<void> clearGuest() => _preferences.remove(_guestKey);

  Future<void> setRemembered(bool value) => _preferences.setBool(_rememberedKey, value);

  Future<void> clearRemembered() => _preferences.remove(_rememberedKey);

  /// Deletes the plaintext e-mail and password written by earlier builds.
  /// Safe to call on every launch; a no-op once the keys are gone.
  Future<void> purgeLegacyCredentials() async {
    await _preferences.remove(_legacyEmailKey);
    await _preferences.remove(_legacyPasswordKey);
  }
}
