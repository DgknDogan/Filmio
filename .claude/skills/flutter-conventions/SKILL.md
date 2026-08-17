---
name: flutter-conventions
description: Architecture, SOLID rules, test-driven workflow, and Bloc/Cubit conventions for this Flutter project (auto_route, get_it, dio + retrofit, fpdart, hive, shared_preferences). Consult this skill whenever writing or refactoring Flutter/Dart code — starting a feature, creating a cubit/bloc, defining an API service or repository, writing a use case, adding a route, registering a dependency, writing tests, or touching any .dart file — even if the user does not explicitly mention architecture, testing, or conventions.
---

# Flutter Conventions

Rules for writing code in this project. The goal is that every feature has the same skeleton, so anyone can guess where a file lives without searching.

## Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` (Cubit by default) |
| Routing | `auto_route` |
| Dependency injection | `get_it` |
| Networking | `dio` + `retrofit` |
| Functional error handling | `fpdart` (`Either`) |
| Small local data | `shared_preferences` |
| Large local data | `hive` |
| Credentials and tokens | `flutter_secure_storage` |
| Value equality | `equatable` |
| Fonts | `google_fonts` |
| Assets, icons, fonts | `flutter_gen` (type-safe, no path strings) |
| Network images | `cached_network_image` |
| Localization | `flutter_localizations` + `intl` with `.arb` files |
| Backend services | Firebase |
| Unit + widget tests | `flutter_test` + `bloc_test` + `mocktail` |
| Integration tests | `patrol` (not `integration_test`) |

Do not introduce an alternative for any of these (no `go_router`, no `provider`, no `dartz`, no `riverpod`, no `mockito`, no raw `http`). Packages beyond this list are added only when a concern genuinely needs one — `bloc_concurrency` and `rxdart` for event transformers, `flutter_svg` or `lottie` for those asset types. If a task seems to need a new dependency, ask in chat before adding it.

### Code generation

`auto_route_generator`, `retrofit_generator`, and `json_serializable` are code generators — they belong in `dev_dependencies` together with `build_runner`:

```yaml
dev_dependencies:
  build_runner: ^2.12.0
  auto_route_generator: ^9.0.0
  retrofit_generator: ^9.0.0
  json_serializable: ^6.8.0
  flutter_gen_runner: ^5.15.0
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  patrol: ^4.0.0
  flutter_lints: ^5.0.0
```

`flutter_gen_runner` needs no runtime counterpart — its output lands in `lib/gen/`. It does conflict with Flutter's localization codegen unless configured correctly; see `references/assets-and-l10n.md`.

`mocktail` is the only mocking library used — no `mockito`, no generated mocks, so tests never depend on `build_runner`. `bloc_test` builds on it too: `MockCubit`/`MockBloc` and `whenListen` come from `bloc_test`, while `when`, `verify`, and `registerFallbackValue` come from `mocktail`.

Patrol replaces the `integration_test` package entirely — do not add `integration_test` to `pubspec.yaml`. It needs its own top-level config block and a CLI installed separately:

```yaml
patrol:
  app_name: <App Name>
  test_directory: integration_test
  android:
    package_name: com.example.app
  ios:
    bundle_id: com.example.app
```

```bash
flutter pub global activate patrol_cli
patrol doctor
```

Patrol generates `test_bundle.dart` in the test directory; it is gitignored along with `.patrol.env` and never committed.

After touching anything annotated (`@RoutePage`, `@RestApi`, `@JsonSerializable`, Hive adapters) or any asset, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

After touching any `.arb` file, regenerate localizations separately — this is a Flutter SDK command, not a `build_runner` builder:

```bash
flutter gen-l10n
```

Never hand-edit a `*.g.dart`, `*.gr.dart`, `*.gen.dart`, or `app_localizations*.dart` file — it will be overwritten. Fix the annotated source, the asset, or the ARB file instead.

### Lint rules

`analysis_options.yaml` at the project root, on top of `flutter_lints`. Three rules are non-negotiable because they enforce conventions this file would otherwise only state in prose:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # const wherever possible — the cheapest rebuild prevention there is
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true

    # no print in production code
    avoid_print: true

    # imports within lib/ are relative paths, not package: URIs
    prefer_relative_imports: true
    avoid_relative_lib_imports: true
```

`prefer_relative_imports` means `import '../../domain/entities/staff.dart';` inside `lib/`, not `import 'package:app/features/staff/domain/entities/staff.dart';`. Never enable `always_use_package_imports` — it is the direct opposite and the two cannot both hold.

Run before pushing, alongside the tests:

```bash
dart format .
flutter analyze
```

A lint warning is a build failure, not a suggestion. Do not silence one with `// ignore:` without a comment saying why.

## Folder layout

```
lib/
├── gen/                        # flutter_gen output (Assets, Fonts) — generated, committed
├── config/                     # App-wide configuration, not business logic
│   ├── l10n/                   # .arb files + generated AppLocalizations
│   ├── router/                 # AppRouter (auto_route), route guards
│   └── theme/                  # ThemeData, colors, typography, spacing
├── core/                       # Shared across features
│   ├── cubit/                  # Base cubit/state classes, app-level cubits
│   ├── custom/                 # Shared widgets: AppNetworkImage, AppErrorView, AppShimmer…
│   ├── enums/                  # Shared enums
│   ├── extensions/             # Extension methods (context, String, DateTime…)
│   ├── models/                 # Models shared across features
│   ├── resource/               # Failure types, Either helpers, result wrappers
│   ├── storage/                # TokenManager (flutter_secure_storage)
│   ├── usecase/                # Base UseCase contracts
│   └── utils/                  # Validators, formatters, constants, helpers
├── features/
│   └── <feature>/              # e.g. analytics, auth, shop, staff
│       ├── data/
│       │   ├── datasources/    # Retrofit services, Hive/prefs local sources
│       │   ├── models/         # DTOs — fromJson/toJson lives here only
│       │   └── repositories/   # Implementations of the domain contracts
│       ├── domain/
│       │   ├── entities/       # Pure Dart, no package dependencies
│       │   ├── repositories/   # Abstract contracts
│       │   └── usecases/       # One job per class
│       ├── presentation/
│       │   ├── cubit/          # Cubit/Bloc + state (+ event)
│       │   ├── pages/          # @RoutePage() screens
│       │   └── widgets/        # Widgets private to this feature
│       └── wrapper_page.dart   # Shell page hosting the feature's nested routes
├── firebase_options.dart
├── injection_container.dart    # All get_it registrations
└── main.dart
```

Where things go:

- **A widget used by exactly one feature** → that feature's `presentation/widgets/`. Only promote it to `core/custom/` once a second feature needs it. Premature sharing is worse than duplication.
- **The app-wide widgets** live in `core/custom/` and are used by name rather than rebuilt: `AppNetworkImage` (every remote image), `AppErrorView` (the retry view a failed state renders), `AppShimmer` (the loading placeholder). Check that folder before writing a new shared widget, and add to it rather than creating a second variant.
- **A model returned by one feature's API** → that feature's `data/models/`. `core/models/` is for models genuinely shared by multiple features (e.g. a paginated response envelope).
- **Anything a feature could not work without but has no business logic** (theme, router, localization) → `config/`.
- **New feature** → create the full `data / domain / presentation` triad plus a `wrapper_page.dart` if it owns nested routes.

## Layer rules

Dependency direction is one-way: `presentation → domain ← data`. Domain depends on nothing, which is what keeps business logic testable without Flutter or Dio.

- **Never import `package:flutter` in `domain/`.** No `BuildContext`, `Widget`, or `Color` there.
- **Models live in `data/`, entities in `domain/`.** The repository implementation maps model → entity, so an API field rename touches exactly one file.
- **Presentation never touches a datasource directly.** The chain is Widget → Cubit → UseCase → Repository → DataSource.
- **A use case exposes a single `call` method.** If it does two things, it is two use cases.
- **Only `data/` knows about `DioException`, `HiveError`, or `PlatformException`.** Those get converted to a `Failure` at the repository boundary.
- **Firebase SDK calls go directly in the repository implementation.** Firebase Auth, Storage, and Firestore are already service abstractions; wrapping them in another datasource that only forwards adds a file and no seam. Mock the Firebase interface in the repository test instead. The rule that survives is the one that matters: no Firebase type ever appears in `domain/` or in a widget.

For small CRUD features where use cases would only forward calls, letting the cubit talk to the repository directly is acceptable — but apply that choice consistently across the whole feature, not file by file.

## Assets, images, and text

Three rules, all enforcing the same idea: nothing user-facing is addressed by a raw string.

**Assets go through `flutter_gen`.** String asset paths are forbidden — `Image.asset('assets/images/logo.png')` fails at runtime, `Assets.images.logo.image()` fails at compile time. Always `Assets.<dir>.<name>` for images, SVGs, Lottie files, and paths. Add the file, list its directory under `flutter: assets:`, run `build_runner`, then use it; a new asset does not exist in Dart until the generator has run. Generated files under `lib/gen/` are committed and never edited by hand.

**Remote images go through `cached_network_image`.** `Image.network` is forbidden: no disk cache, re-downloads on rebuild, no clean placeholder or failure path. Every remote image needs both a `placeholder` (or `progressIndicatorBuilder`) and an `errorWidget`, plus a bounded size. Do not call `CachedNetworkImage` directly in feature code — go through the single `AppNetworkImage` wrapper in `core/custom/` so loading and error states look the same everywhere.

**Text comes from `.arb` files** via Flutter's own `gen-l10n` tool, and is read as `context.l10n.propertyName` — never `AppLocalizations.of(context)!.x`, never a hardcoded string, never a Dart string constant. ARB keys carry a `@key` description; plurals and gendered text use ICU `plural`/`select` syntax rather than Dart conditionals, because plural categories differ per language.

`references/assets-and-l10n.md` has the setup for these three, the `AppNetworkImage` wrapper, ARB placeholder and plural examples, and the `flutter_gen` / localization codegen conflict and how to avoid it. Read it before adding an asset, a remote image, or a new string.

## Theming

The fourth instance of the same rule: a widget never names a colour, a font size, or a radius — it names a slot and the theme resolves it for the brightness in effect.

- **Colours** → `context.palette.<slot>`. `config/theme/app_colors.dart` is the only file allowed to contain `Color(0x…)`.
- **Text** → `context.textTheme.<role>` for the scale, `context.styles.<name>` for styles that carry meaning (a price, a stat value, an error line). `app_typography.dart` is the only file allowed to call `GoogleFonts` or build a `TextStyle` from scratch.
- **Radii** → `AppRadius.*`. A radius outside that set is a bug.
- **Gaps and padding** → `AppSpacing.*` (a four-based scale) or an `AppInsets.*` preset. Never a bare number in an `EdgeInsets` or a `SizedBox`. This covers spacing only — border widths, divider thickness, shadow offsets, and fixed component sizes stay literal.
- **Repeated surfaces** → `AppDecorations(context.palette).<name>` rather than an inline `BoxDecoration`.
- **Component styling** → `theme.dart`, never a `style:` override at the call site reproducing what the theme already gives.

Slots are named by purpose (`textSecondary`, `surfaceMuted`), never by appearance (`grey600`). Both brightnesses come from one `_themeOf(palette)` function so components cannot drift between them; every new slot needs a deliberate value in both sets, and a new screen is not done until it has been checked in both.

`references/theming.md` covers the file-by-file layout, the five places a new palette slot must be added, and when a style earns a place in `AppTextStyles`.

## SOLID in practice

The layering above is what enforces these; the point of naming them is to know which rule a design smell violates.

- **Single responsibility** — one use case does one job. If it needs the word "and" to describe, split it. A cubit that manages two unrelated screens is two cubits.
- **Open/closed** — extend by adding a type, not by editing a switch. A new error case means a new `Failure` subclass; a new cross-cutting concern means a new Dio interceptor, not another `if` inside an existing one.
- **Liskov substitution** — `StaffRepositoryImpl` must honour the contract of `StaffRepository` fully. It never throws where the signature promises `Either`, and never returns `Right` with an empty result to signal an error.
- **Interface segregation** — a cubit depends on the narrow use cases it actually calls, not on a whole repository with twelve methods. This is the main reason use cases exist here; when a cubit needs six of them, that is a signal the screen is doing too much.
- **Dependency inversion** — presentation and domain depend on abstractions; `injection_container.dart` is the only place that knows about concrete implementations. Register the abstract type, never the impl.

A practical test of whether this is holding: if a unit test needs more than three mocks, the class under test has too many responsibilities. Fix the design rather than the test.

## Error handling

Repositories return `Either<Failure, T>` from `fpdart`. Left is the failure, Right is the value.

```dart
Future<Either<Failure, List<Staff>>> getStaff();
```

Consume it with `fold` — never with `isRight()` followed by `getOrElse`, which silently hides the failure:

```dart
final result = await _getStaff();
result.fold(
  (failure) => emit(StaffError(failure.message)),
  (staff) => emit(StaffLoaded(staff)),
);
```

`Failure` types and the Dio/Hive → `Failure` mapping live in `core/resource/`. See `references/data-layer.md` for the full pattern.

## Bloc or Cubit

**Cubit is the default.** Less boilerplate, easier to read.

Reach for Bloc only when:
- The order or timing of incoming events matters (debounce, throttle, `restartable`)
- You need an auditable trail of user actions (analytics, event sourcing)
- Many distinct sources drive the same state and you must tell them apart

When unsure, write a Cubit. Migrating Cubit → Bloc later is easier than the reverse.

Model state with Dart 3 sealed classes rather than a `status` enum plus nullable fields, so impossible combinations (`loading` with a non-null `error`) cannot be constructed. Match on it with an exhaustive `switch` in the UI. Full examples, event naming, and transformers are in `references/bloc-patterns.md`.

## Naming

| Thing | Convention |
|---|---|
| File | `snake_case.dart` |
| Cubit | `StaffCubit` → `staff_cubit.dart` |
| State | `StaffState` → `staff_state.dart` |
| Event | Past tense: `StaffRequested`, `StaffDeleted` |
| Page | `StaffPage` → `staff_page.dart` |
| Route (generated) | `StaffRoute` — derived from the page name, do not write it yourself |
| Use case | Verb + noun: `GetStaff`, `DeleteStaff` |
| Retrofit service | `StaffApiService` → `staff_api_service.dart` |
| Repository contract | `StaffRepository` (domain) |
| Repository impl | `StaffRepositoryImpl` (data) |

Name events after something that happened (`LoginButtonPressed`), not after a command (`DoLogin`). An event reports a fact; the bloc decides what to do about it.

## Widget rules

- Use `const` constructors wherever possible — the cheapest rebuild prevention available.
- Split any `build` method past ~100 lines into separate widget classes, not private `Widget _buildX()` methods. Methods cannot be `const` and cannot rebuild independently.
- Put `BlocBuilder` as deep in the tree as possible. Wrapping the whole page repaints everything on every state change.
- Side effects — navigation, snackbars, dialogs — belong in `BlocListener`, never in a builder. Use `BlocConsumer` when you need both.
- Reach for `BlocSelector` when a widget only cares about one field of the state.
- **Provide a cubit at page level.** The `@RoutePage` page creates the `BlocProvider`; an inner view consumes it. Move the provider up to the feature's `wrapper_page.dart` only in the rare case where sibling tabs genuinely share the same data and should not refetch when switching between them.
- Access context extensions from `core/extensions/` (e.g. `context.theme`, `context.l10n`) instead of repeating `Theme.of(context)`.

## Routing

Pages are annotated with `@RoutePage()`; `AppRouter` in `config/router/` declares the tree; a feature's `wrapper_page.dart` hosts its nested routes via `AutoRouter()`. Navigate with the generated typed routes (`context.router.push(StaffDetailRoute(id: id))`), never with raw path strings. See `references/routing.md`.

## Dependency injection

All registrations live in `injection_container.dart` at the `lib/` root, grouped by feature and ordered outer → inner (external → data → domain → presentation). Cubits and Blocs are always `registerFactory`; a singleton cubit hands you stale state when the user re-enters a screen. Pass dependencies through constructors — no global singletons or service locator calls from inside widgets other than at provider creation.

## Local storage

- **Small, non-critical values** (flags, tokens for non-sensitive scopes, last selected tab, onboarding seen) → `shared_preferences`.
- **Large, non-critical data** (cached lists, offline snapshots, drafts) → `hive`.
- Both are accessed only through a local datasource in `data/datasources/`. Widgets and cubits never call `SharedPreferences.getInstance()` or `Hive.box()` directly — otherwise the storage choice leaks into the UI and cannot be swapped or mocked.
- **Auth tokens and any credential** → `flutter_secure_storage`, only ever through `TokenManager` in `core/storage/`. Never `shared_preferences`, never Hive, never a plain field on a cubit.

## Development order (test-driven)

There are exactly three kinds of test in this project — **unit test**, **widget test**, **integration test**. Do not invent a fourth category or a project-specific name for one.

| Kind | Runs with | Renders UI? | Answers |
|---|---|---|---|
| Unit test | `flutter test` | No | Does this class behave correctly in isolation? |
| Widget test | `flutter test` | One page, mocked cubit | Does each state render correctly, and does each interaction call the right method? |
| Integration test | `patrol test` | Whole app on a device | Does the assembled app actually work? |

Build a feature in this order. Steps 1–5 run under `flutter test` without rendering a widget, and they must be green before any UI for that feature is written.

| Step | What | Test first? |
|---|---|---|
| 1 | Entity + abstract repository | No — contracts, not behaviour |
| 2 | `Model` (`fromJson`, `toEntity`) | **Yes** — unit test |
| 3 | `RepositoryImpl` | **Yes** — unit test, highest value in the feature |
| 4 | `UseCase` | Unit test only if it has logic of its own |
| 5 | `Cubit` / `Bloc` | **Yes** — unit test |
| 6 | DI registration + routes | No — wiring, not behaviour |
| 7 | Pages and widgets | No — write the UI first |
| 8 | Widget tests for those pages | After the UI exists |
| 9 | Integration test for the flow | Last, once the feature runs end to end |

In steps 2, 3, and 5 the cycle is red → green → refactor. The value is not coverage: writing the test first makes the contract the reference point instead of whatever the implementation happens to do, and it exposes design problems while changing course is still cheap.

Steps 7–8 invert deliberately. Writing a widget test before the widget exists means asserting on a layout you have not designed yet, which produces tests that get rewritten with every visual change. The UI comes first; the test then locks in the behaviour that matters.

**Test behaviour, not structure.** A class with no decision, no transformation, and no error handling does not get a test — such a test only proves the mock returns what you configured. So: no tests for Retrofit `@RestApi` services or any generated file, and no tests for use cases that merely forward a call (question whether those should exist at all). Do test model mappings, repository error mapping and fallbacks, cubits, interceptors, and any local datasource with real logic.

Because every unit test mocks its collaborators, none of them catches a wrong method call or swapped argument between layers. The integration test in step 9 is what closes that gap — which is why a feature is not done until it has one.

`references/feature-walkthrough.md` runs all nine steps on one real feature, file by file. Read it when starting a feature; `references/tdd-workflow.md` has the per-step detail and the decision table for what to test.

## Test folder structure

`test/` mirrors `lib/` exactly — never drop files in the root of `test/`. Everything that is not a mirror of a `lib/` file goes in `fixtures/` or `helpers/`. Integration tests live outside `test/` because Patrol runs them, not `flutter test`.

```
test/                                # unit + widget tests, run by `flutter test`
├── fixtures/
│   ├── fixture_reader.dart          # fixture('staff_list.json') helper
│   └── staff_list.json              # real API responses, one per endpoint
├── helpers/
│   ├── mocks.dart                   # shared mock classes and fallback values
│   ├── pump_app.dart                # pumpApp() — wraps a widget in MaterialApp + providers
│   └── test_di.dart                 # get_it setup/reset for widget tests
├── config/                          # mirrors lib/config
├── core/                            # mirrors lib/core
└── features/
    └── staff/
        ├── data/
        │   ├── models/staff_model_test.dart
        │   └── repositories/staff_repository_impl_test.dart
        ├── domain/
        │   └── usecases/delete_staff_test.dart
        └── presentation/
            ├── cubit/staff_cubit_test.dart
            └── pages/staff_page_test.dart

integration_test/                    # run by `patrol test`, one file per feature
├── helpers/
│   └── app_launcher.dart            # createApp($) — boots the real app for Patrol
├── auth_test.dart
└── staff_test.dart
```

A test file under `test/` is named after the file it covers plus `_test`, and sits at the same path. If a test does not map to a `lib/` file, it belongs in `fixtures/`, `helpers/`, or `integration_test/` — otherwise it should not exist.

Full workflow, worked examples for every step, and the decision table for what to test live in `references/tdd-workflow.md` — read it before starting a feature.

## Avoid

- Mixing `setState` with cubit state — a screen has exactly one source of state.
- Holding a `BuildContext` inside a cubit or bloc.
- Reading `cubit.state` inline to render; use `BlocBuilder` (`context.read` is fine for one-off calls).
- Business logic in a widget or in the router.
- `print` in production code — `avoid_print` is on; remove it or route it through a real reporting path once one exists.
- Editing generated files, or committing without running `build_runner` after changing annotated code.
- Writing UI for a feature while its unit tests are red or missing.
- Writing tests that assert a mock returns what you configured it to return.
- Reaching for a real network call, a real Hive box, or `SharedPreferences.getInstance()` inside a unit test.
- Mocking anything inside an integration test, or pointing one at production.
- Adding the `integration_test` package, or calling `IntegrationTestWidgetsFlutterBinding`, `WidgetsFlutterBinding.ensureInitialized`, or `runApp` inside a Patrol test.
- Asserting on padding, colours, or font sizes in a widget test.
- Using `mockito` or generated mocks — `mocktail` only.
- Inventing a test category beyond unit, widget, and integration.
- Writing a string asset path (`'assets/...'`) anywhere in Dart.
- Using `Image.network`, or calling `CachedNetworkImage` outside `AppNetworkImage`.
- A remote image without a placeholder, without an error widget, or without a bounded size.
- Hardcoding user-facing text, or reading it any way other than `context.l10n.propertyName`.
- Building plurals with Dart conditionals instead of ICU `plural` syntax in the ARB file.
- Adding `generate: true` under `flutter:` in `pubspec.yaml` — it breaks `flutter_gen`.
- Writing `Color(0x…)`, a bare `TextStyle(...)`, a `GoogleFonts` call, or a raw radius outside `config/theme/`.
- A bare number in an `EdgeInsets` or `SizedBox` instead of `AppSpacing.*` / `AppInsets.*`, or a spacing value that is not a multiple of four.
- Reproducing theme defaults with a `style:` override at a call site.
- Storing a token anywhere other than `TokenManager`.
- `package:` imports for files inside `lib/` — use relative paths.
- Silencing a lint with `// ignore:` and no reason.
- Guessing at a convention this file does not cover — ask in chat instead.

## References

Read the relevant one before starting; they are the detail this file summarises.

| File | When |
|---|---|
| `references/feature-walkthrough.md` | Starting a new feature — one complete example, every step in order |
| `references/tdd-workflow.md` | Any test question: what to test, in what order, how |
| `references/data-layer.md` | Retrofit, Dio, `Either`/`Failure`, Hive, prefs, tokens, DI |
| `references/bloc-patterns.md` | Writing a cubit or bloc, designing state, transformers |
| `references/routing.md` | Adding a page, nested routes, guards, arguments |
| `references/theming.md` | Any colour, text style, radius, or decoration |
| `references/assets-and-l10n.md` | Assets, remote images, ARB strings |
