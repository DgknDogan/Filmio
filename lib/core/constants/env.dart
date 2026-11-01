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

/// Which Firebase project to use, as a dart-define.
///
/// Only iOS needs this: on Android the flavor comes from `--flavor`, which is
/// also what picks the matching `google-services.json`. Empty when the build
/// did not name one — `AppFlavor.resolve` is where the two are read together
/// and where an unnamed build is decided.
const flavorName = String.fromEnvironment('FLAVOR');

/// Whether the build said anything about the emulators at all.
///
/// Three-way rather than two: not mentioning them is different from saying
/// no. `AppFlavor.usesEmulators` is where the difference is decided.
const hasEmulatorDefine = bool.hasEnvironment('USE_FIREBASE_EMULATOR');

/// What the build said, when it said anything. Read together with
/// [hasEmulatorDefine] — on its own this is false for a build that never
/// mentioned it.
const emulatorDefine = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// Where those emulators answer, when they are not where the platform would
/// assume. Empty means the default: `localhost` everywhere except the Android
/// emulator, which reaches its host at a different address. A physical device
/// needs the host's address on the local network, and this is how it is given
/// one.
const firebaseEmulatorHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
