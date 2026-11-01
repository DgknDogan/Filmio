# filmio

A Flutter movie and series browser backed by TMDB and Firebase.

## Getting Started

### 1. Configure secrets

The TMDB token is supplied at build time, not committed. Copy the template and
fill in your own [TMDB API read access token](https://www.themoviedb.org/settings/api):

```bash
cp env.example.json env.json
```

`env.json` is gitignored.

### 2. Start the Firebase emulators

The copied `env.json` points the app at the local emulators, so a run out of
the box cannot read or write anybody's real data:

```bash
firebase emulators:start --project demo-filmio
```

### 3. Run

```bash
flutter run --flavor dev --dart-define-from-file=env.json
```

`--flavor` is required: `dev` and `prod` each compile in their own Firebase
configuration, and a build that names neither is refused rather than guessed
at. The VS Code launch configurations in `.vscode/launch.json` pass the defines
for you, including one for running against production on purpose.

Building without the define starts the app but every TMDB request will fail
with 401; the console prints a reminder on launch.

[`docs/firebase-environments.md`](docs/firebase-environments.md) is the rest of
it: which project each build opens, how the security rules are tested and
deployed, and what is still to do for the dev project and iOS flavors.

### 4. Code generation

After changing anything annotated (`@RoutePage`, `@RestApi`, `@JsonSerializable`):

```bash
dart run build_runner build --delete-conflicting-outputs
```
