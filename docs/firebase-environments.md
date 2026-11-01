# Firebase environments

There are three places this app's data can live. Which one a build opens is
decided by two things that must always agree: the **flavor**, and whether the
build was told to use the **emulators**.

| Environment | Project id | What it is |
|---|---|---|
| Emulators | `demo-filmio` | A Firestore and an Auth emulator on your own machine. No cloud project behind it — the `demo-` prefix is what tells the Firebase tooling that. |
| Dev | `filmio-dev` | A real cloud project for builds handed to testers. **Does not exist yet** — see [Creating the dev project](#creating-the-dev-project). |
| Prod | `filmio-74b41` | The project real people's accounts and liked lists are in. |

## The one rule

**A build's native configuration and its Dart options must name the same
project.** Firebase is configured twice on a phone — once natively from
`google-services.json` / `GoogleService-Info.plist`, and once from Dart
through `FirebaseOptions` — and which of the two wins for the default app is
not something to rely on. So the flavor drives both:

- Gradle resolves `android/app/src/<flavor>/google-services.json` from the
  flavor name. There is deliberately **no** copy of that file in
  `android/app/`: the plugin treats one there as the fallback for any flavor
  without its own, and that fallback is how a dev build quietly carries the
  production configuration.
- Flutter hands the same flavor name to Dart as `appFlavor`, which is what
  `AppFlavor.resolve` reads, which is what picks between
  `lib/firebase_options.dart` and `lib/firebase_options_dev.dart`.

**A dev build uses the emulators unless it says otherwise.** There is a cloud
dev project only once somebody creates one, so for a build that names no
environment the alternative to the emulators is not a dev project but a crash
on launch. A plain `flutter run` therefore gets the one environment that is
always there and can never touch anybody's data.
`--dart-define=USE_FIREBASE_EMULATOR=false` is how a dev build asks for the
cloud dev project instead — and is what then needs that project to exist.

## Naming the environment

Which argument says it depends on the platform, and the two do not currently
agree.

| | What names the environment | What breaks |
|---|---|---|
| Android | `--flavor dev` / `--flavor prod` | A build that names no flavor is refused: the product flavors exist, and Gradle will not pick one for you. |
| iOS | `--dart-define=FLAVOR=prod`, and **no** `--flavor` | Any `--flavor` is refused. Flutter looks for an Xcode scheme named after it — sentence-cased, so `Dev` or `Prod` — and the project has none. With no flavor it resolves the `Runner` scheme and builds. |

So an iOS build that passes `--flavor` fails with *"You must specify a
--flavor option to select one of the available schemes"*, listing every scheme
in the project including the ones Swift Package Manager generates for the
plugins. That message is Flutter saying the flavor it was given matches none
of them, not that one is missing from the command.

This is why `FLAVOR` exists as a dart-define at all, and it goes away once the
iOS schemes are created — see [iOS flavors](#ios-flavors-not-done-yet). Until
then an iOS **dev** build should use the emulators, because natively it is
still carrying the production plist.

A default flavor in `pubspec.yaml` (`flutter: default-flavor:`) does not
bridge the gap: Flutter applies it to both platforms, so it would fix the
Android command by breaking every iOS one.

## Day to day: the emulators

A build that names no environment is a dev build on the emulators, so the
default for a working copy is a run that cannot touch anyone's data. Start them
first:

```bash
firebase emulators:start --project demo-filmio
```

Then run the app:

```bash
flutter run --dart-define-from-file=env.json
```

```bash
flutter run --flavor dev --dart-define-from-file=env.json
```

The first is iOS, the second Android. `--flavor` is Android-only here, and
the split is not a preference — see [Naming the
environment](#naming-the-environment) below.

The emulator UI is at <http://localhost:4000>. Emulator data is thrown away on
shutdown unless you ask for it to be kept:

```bash
firebase emulators:start --project demo-filmio --import=.emulator-data --export-on-exit
```

On the Android emulator the app reaches your machine at `10.0.2.2`, which it
works out on its own. A physical device needs your machine's address on the
network:

```bash
flutter run --dart-define-from-file=env.json --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.42
```

### Running against production on purpose

There is a VS Code configuration called **filmio (PRODUCTION data)**, or on the
command line:

```bash
flutter run --dart-define-from-file=env.json --dart-define=FLAVOR=prod --dart-define=USE_FIREBASE_EMULATOR=false
```

```bash
flutter run --flavor prod --dart-define-from-file=env.json --dart-define=FLAVOR=prod --dart-define=USE_FIREBASE_EMULATOR=false
```

iOS first, Android second.

Nothing it writes is reversible. Explicit flags rather than a default is the
point.

## Rules

`firebase/firestore.rules` is the only description of who can read and write
what. It is the file of record, not the console — an edit made there leaves no
trace of what changed and is overwritten by the next deploy from here.

Neither the test nor the deploy runs in CI. The rules change a few times a
year, and the two jobs ran on every push regardless, so both are done by hand,
the same way the indexes are.

Test a change before deploying it:

```bash
cd scripts/firestore_rules_test
npm install
npm test
```

That starts the emulator, runs `rules.test.js` against the real rules file, and
shuts it down. A rule that is loosened without a test proving what it now
admits is a rule nobody can review.

Then deploy it:

```bash
firebase deploy --only firestore:rules --project prod
```

### Indexes are not deployed from CI

`firebase/firestore.indexes.json` is currently empty, because the app makes no
query that needs a composite index — every read is by document id. Deploying
an empty index file offers to **delete** every index that is live but absent
from it, which includes anything added from the console. So export what is
really there before touching it:

```bash
firebase firestore:indexes --project prod > firebase/firestore.indexes.json
```

## Creating the dev project

Nothing below has been done — it needs console access.

1. Create a Firebase project named `filmio-dev`. The Spark (free) plan is
   enough. `.firebaserc` already points the `dev` alias at that id, so no
   change is needed there.
2. In that project, create a Firestore database and enable **Email/Password**
   sign-in under Authentication.
3. Register the two apps, with the ids the dev flavor uses:
   - Android: `com.dogukan.filmio.dev`
   - iOS: `com.dogukan.filmio.dev`
4. Generate the configuration:

   ```bash
   flutterfire configure \
     --project=filmio-dev \
     --out=lib/firebase_options_dev.dart \
     --android-package-name=com.dogukan.filmio.dev \
     --ios-bundle-id=com.dogukan.filmio.dev
   ```

   This overwrites the placeholder `lib/firebase_options_dev.dart` — which
   exists only so the dev flavor compiles before this step, and which throws
   with these instructions if a build asks for the cloud dev project before it
   exists — and writes `android/app/src/dev/google-services.json` over the
   placeholder there.
5. Push the rules to it:

   ```bash
   firebase deploy --only firestore:rules --project dev
   ```

6. Create a test account in it, and point `TEST_EMAIL` / `TEST_PASSWORD` in
   your `env.json` at that account rather than one in production.

## iOS flavors (not done yet)

Android flavors are Gradle only, so they are in place. iOS flavors need
changes inside the Xcode project, which are not safe to make by editing
`project.pbxproj` by hand:

1. Open `ios/Runner.xcworkspace`.
2. Duplicate the `Debug`, `Release` and `Profile` build configurations into
   `Debug-Dev`, `Release-Dev`, `Profile-Dev` and `Debug-Prod`, `Release-Prod`,
   `Profile-Prod`.
3. Set `PRODUCT_BUNDLE_IDENTIFIER` per configuration —
   `com.dogukan.filmio.dev` for the dev set, `com.dogukan.filmio` for prod.
4. Create schemes named `Dev` and `Prod` bound to those configurations. The
   capitalisation matters: Flutter looks for the sentence-cased form of
   whatever `--flavor` is given, and expects the build configurations to be
   named `<mode>-<scheme>`, which is where step 2's names come from.
5. Add a build phase that copies the right `GoogleService-Info.plist` for the
   configuration in effect, and move the current one to
   `ios/config/prod/GoogleService-Info.plist`.
6. Then `flutterfire configure --flavor dev` / `--flavor prod` records them,
   and `flutter run --flavor dev` works on iOS as it does on Android.

Until then: iOS dev work goes through the emulators, and the iOS CI job names
the flavor with `--dart-define=FLAVOR=prod`, which it does already.

## Known gaps

Three things this setup does not cover.

**The recommendation service is always the production one.** Its URL is
`recommendationBaseUrl` in `lib/core/constants/constants.dart`, and it is
interpolated into a Retrofit annotation — so `build_runner` bakes it into
`*.g.dart` at generation time and a dart-define at build time cannot change
it. Pointing dev at a dev instance of that service means moving the URL out of
the annotation and onto the Dio request instead. The service is read-only and
authenticates with a Firebase ID token, so the effect today is that
recommendations are empty in dev rather than that dev reads production data.

**Integration tests need an account wherever they are pointed.** They sign in
as `TEST_EMAIL` and write as that account, which is why `createApp` now
refuses to run against prod. Against the emulators the account has to be
seeded first; against `filmio-dev` it has to exist there.

**Deleting an account leaves its subcollections behind.** `deleteAccount` in
`auth_repository_impl.dart` deletes the user document, but Firestore does not
delete subcollections with their parent, so `User/{uid}/LikedMovies/*` and
`LikedSeries/*` outlive the account — and once the account is gone, nothing
is authorised to clean them up. The fix is the `delete-user-data` extension or
an `onUserDeleted` function, in both projects.
