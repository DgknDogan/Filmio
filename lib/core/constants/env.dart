/// Build-time configuration, supplied with `--dart-define-from-file=env.json`.
///
/// See `env.example.json` for the shape of that file. Nothing secret is
/// checked in — `env.json` is gitignored.
library;

/// TMDB API read access token (the v4 bearer token, without the `Bearer `
/// prefix). Empty when the app is built without the define, which is why
/// [hasTmdbToken] exists.
const tmdbToken = String.fromEnvironment('TMDB_TOKEN');

bool get hasTmdbToken => tmdbToken.isNotEmpty;
