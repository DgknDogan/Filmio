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

### 2. Run

```bash
flutter run --dart-define-from-file=env.json
```

The VS Code launch configurations in `.vscode/launch.json` already pass this
flag, so `F5` works without extra arguments.

Building without the define starts the app but every TMDB request will fail
with 401; the console prints a reminder on launch.

### 3. Code generation

After changing anything annotated (`@RoutePage`, `@RestApi`, `@JsonSerializable`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Conventions

Architecture, layering, and testing rules live in
`.claude/skills/flutter-conventions/`. The migration plan tracking this
codebase against them is in [docs/conventions-migration.md](docs/conventions-migration.md).
