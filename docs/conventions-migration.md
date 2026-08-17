# Filmio — Conventions Migration Plan

Gap analysis of the current codebase against `.claude/skills/flutter-conventions`, plus a
phased integration guide. Each phase is independently shippable: the app compiles and runs
at the end of every phase.

Baseline: `flutter analyze` = 2 infos (deprecated `cacheExtent`). No tests.
Features present: `movie`, `series`, `auth`, `account`, `landing`.

## Status

| Group | State |
|---|---|
| **P0** (5 items) | **Done** — see the ✅ notes below. |
| **Phase 0** (toolchain) | **Done** — lint gate live, 9 dead deps removed, repo formatted at `page_width: 150`. |
| **Phase 1** (`Either`/`Failure`) | **Done** — all four features; `core/resources/` deleted. |
| **Phase 2** (data layer) | **Done** — model/entity split, `guardApiCall`, `Isolate.run` removed, folders renamed. |
| **Phase 3** (credentials + prefs) | **Done** — no `SharedPreferences` access left outside a datasource. |
| **Phase 4** (theme system) | **Done** — palette, typography, spacing, radii, decorations; both brightnesses checked on device. |
| **Phase 5** (assets / images / l10n) | **Done** — flutter_gen, `AppNetworkImage`, ARB localization. |
| **Phase 6** (states + folder normalization) | **Done** — no `states/` folders, no naming drift left. |
| **Phase 7** (tests) | **Mostly done** — 93 tests; see the gaps below. |
| **Phase 8** (page decomposition) | **Done** — no build method over 100 lines. |

**All eight phases and every P0 are now complete.** What remains is listed under the Phase 7
gaps and the open decisions in Part 3.

**Dependency unblock.** Phase 5 could not start until `auto_route` was upgraded: version
9.3.1 of its generator pins old `build`/`analyzer` ranges, and that was blocking
`flutter_gen_runner` ≥5.14.1 *and* `bloc_test` — the same root cause noted back in Phase 0.
Upgraded `auto_route` 9 → 11 (generator 10.6) and `retrofit_generator` 9 → 10 in one move.
Cost: **two lines** — a deprecated `durationInMilliseconds` and a new `DioExceptionType`
enum value the failure mapper had to match. `bloc_test` is now installable, so Phase 7 is
unblocked too.

Tests: **93 passing**, `test/` mirroring `lib/`.

Verified after each: `flutter analyze` → *No issues found* with the full rule set,
`flutter test` green, iOS simulator build succeeds, app boots and routes correctly.

**Signed-in device pass (after Phase 7).** Everything behind the login screen was finally
exercised against real TMDB and real Firebase: home lists populate, search returns results,
movie details loads its similar-titles row, the like state restores from Firestore, and a
like → read-back → unlike round trip works. Two things this proved that no test could:
`liked_movies` documents written by the **old** code still parse through the new
`MovieModel`, and `arrayRemove` still matches a document written by the **new** one. Two more
regressions surfaced and were fixed — see below.

Deliberately left for their own phase:
- `SeriesSearchPage` still never invokes `SeriesSearchCubit` — the search bar has no
  controller or `onChanged`. The cubit and its states are now correct; wiring the UI is
  feature work, not a P0 fix.
- **No `TokenManager` / `flutter_secure_storage`.** The skill puts credentials there, but
  after P0-1 the app stores no credential and no token — Firebase owns the session. Adding
  an empty `TokenManager` over an unused dependency would be ceremony. Revisit the moment
  something needs storing.
- Dependencies are added at the phase that uses them, not up front: `flutter_secure_storage`
  (nothing stores a credential any more — add it when something does), `google_fonts`
  (Phase 4), `flutter_gen_runner` (Phase 5), `patrol` (Phase 7). Adding them now would just
  recreate the unused-dependency problem Phase 0 cleaned up.

---

## Part 1 — Findings

Severity: **P0** breaks correctness or security · **P1** structural, blocks the conventions ·
**P2** consistency and polish.

### P0 — Correctness and security

**P0-1 · Plaintext password stored in `shared_preferences`** ✅ *fixed*
`lib/features/auth/presentation/cubit/login_cubit.dart:26-28` writes `email`, `password`, and
`is_remembered` to prefs. Read back at `lib/features/landing/pages/splash_page.dart:46-47`,
cleared at `lib/features/account/presentation/cubit/settings_cubit.dart:17-19`.

The skill: *"Auth tokens and any credential → `flutter_secure_storage`, only ever through
`TokenManager` in `core/storage/`. Never `shared_preferences`."*

Beyond the storage choice, storing the password at all is unnecessary — Firebase Auth already
persists the session. "Remember me" should mean "don't sign out on launch", checked via
`FirebaseAuth.instance.currentUser`, not a replayed credential.

*Fix:* `AuthLocalDataSource` now owns the one remaining flag (`is_remembered`); the
e-mail and password are never written. `RestoreSessionUseCase` answers the splash's question
from `isRemembered && FirebaseAuth.currentUser != null`. `initDependencies` calls
`purgeLegacyCredentials()` once on launch so existing installs lose the stored password.
`SettingsCubit` no longer touches prefs — `logout()` clears the flag inside the repository.


**P0-2 · `LoginCubit` is a factory but used as a singleton — the state is thrown away** ✅ *fixed*
`injection_container.dart:76` registers `LoginCubit` with `registerFactory`. Every `getIt<LoginCubit>()`
call therefore returns a **new** instance:

- `splash_page.dart:48` — `getIt<LoginCubit>().isAccountRemembered(...)` mutates instance A
- `splash_page.dart:62` — `create: (context) => getIt<LoginCubit>()` provides instance B
- `splash_page.dart:76` — `getIt<LoginCubit>().login(...)` calls instance C

`isRemembered` is set on an object nothing ever reads. The registration is correct per the
skill (cubits are always `registerFactory`); the call sites are the bug. Resolve the cubit
once in the `BlocProvider`, then use `context.read<LoginCubit>()`.

*Fix:* the splash no longer uses `LoginCubit` at all. A dedicated `SplashCubit` +
sealed `SplashState` (`Checking` / `Authenticated` / `Unauthenticated`) is provided once and
navigated from a `BlocListener`. `LoginState.isRemembered`, which nothing read, is gone.


**P0-3 · `MovieEntity` → `MovieModel` downcast in the Firebase repository** ✅ *fixed*
`lib/features/movie/data/repository/firebase_repository_impl.dart:47` and `:58` do
`(movie as MovieModel).toJson()`. The contract
(`firebase_repository.dart`) accepts a `MovieEntity`, so any caller passing a real entity —
one built in a test, or mapped from a different source — throws at runtime. This is the
Liskov violation the skill calls out: the impl does not honour the contract it declares.

Root cause is P1-2 (model extends entity instead of mapping to it).

*Fix:* `MovieModel.fromEntity` added; the Firestore repository maps at the boundary
instead of casting. The full model/entity split still belongs to Phase 2.


**P0-4 · Search failures are silent** ✅ *fixed*
`search_cubit.dart:23` and `series_search_cubit.dart:26` both do `if (dataState.data != null)`
and otherwise emit nothing. A failed search leaves the previous results on screen with no
error and no way to retry. `SearchState` / `SeriesSearchState` have no loading or error case
at all.

*Fix:* both states are now sealed + `Equatable` with `Initial` / `Loading` / `Loaded` /
`Failure` variants, matched by an exhaustive `switch` in `MovieSearchPage`. Both cubits also
drop responses whose query is no longer the latest, so a slow early request cannot overwrite
a fast later one. The failure message is a single generic string for now — presentation has
no typed `Failure` to read until Phase 1.

**P0-5 · TMDB bearer token is a compiled-in constant** ✅ *fixed*
`lib/core/utils/api_key.dart` is gitignored (good), but it is a `const String` baked into the
binary and passed by hand as `apiKey: "Bearer $apiKey"` on every one of the ~7 call sites.
Move it to `--dart-define` and attach it once in a Dio interceptor. (Also: extractable from a
release build either way — TMDB read tokens are low-value, but the pattern is what matters.)

*Fix:* token moved to `env.json` (gitignored, template in `env.example.json`), read via
`String.fromEnvironment` in `core/constants/env.dart`, and attached once in
`core/network/dio_client.dart`. Both Retrofit services lost their `accept`/`apiKey`
parameters. Run with `flutter run --dart-define-from-file=env.json`.

Credentials sit on `BaseOptions` rather than in an interceptor. The original reason was that
the repositories ran requests inside `Isolate.run` and a plain header map copies across an
isolate boundary where a closure-carrying interceptor may not — Phase 2 removed the isolates
(P2-7), so that constraint is gone. `BaseOptions` stays because the token is static and
never refreshes; move to an interceptor when it does.


### Found during Phase 1 — bugs the review missed ✅ *all fixed*

Converting every call site surfaced live bugs that reading alone did not:

**F-1 · `MovieDetailsCubit._init()` never ran anything.** Both `_isMovieLiked()` and
`_getSimilarMovies()` opened with `if (!isClosed) return;` — inverted, so they returned
immediately for every open cubit. The similar-movies row never populated and the like state
was never restored on the details page. Now `if (isClosed) return;`, placed *after* the
await where it belongs.

**F-2 · The recommended film could crash the home screen.** `MovieBloc` and `SeriesBloc`
picked `recommendedMovie` at random from the **unfiltered** list, then the lists were
filtered to poster-bearing entries. `RecommendedContainer` reads `posterPath!`, so any pick
without a poster threw. Both blocs now filter first and pick from the filtered list, and
emit a failure when nothing is left rather than indexing an empty list.

**F-3 · Registration did not wait for the user document.** `AuthRepositoryImpl.register`
called `FirebaseFirestore.instance.getUserDocRef().set(...)` without `await`, so registering
could return success before the `liked_movies` document existed. Now awaited.

**F-4 · `LikedMoviesCubit` bypassed every layer.** It called Firestore directly from
presentation and did `docSnapshot.data()!["liked_movies"]` — a crash for a user whose
document is missing. It now goes through `GetLikedMoviesUseCase` like everything else, and
the page renders loading / empty / failure states instead of assuming a list.

**F-5 · A third, dead copy of "get liked movies".** `features/account/domain/repository/
account_repository.dart` and its impl duplicated the Firestore read a third time, were never
registered in `injection_container.dart`, and would have thrown anyway — the impl cast the
raw list to `List<Map<String, dynamic>>`, which Firestore never returns. Both deleted.

**F-6 · Login and registration failed silently.** A wrong password produced no message, no
snackbar, nothing — `LoginCubit.login` returned `false` and the page ignored it. Both cubits
now carry `errorMessage` in state and both pages show it via a `BlocListener`. This is the
payoff of the phase: the mapper writes a real message and the user actually sees it.

**F-7 · `FirebaseAuth` was still being read straight from widgets.** `login_page` branched on
`auth.currentUser!.displayName`, `account_page` called `FirebaseAuth.instance.userPhoto`, and
`ProfileCubit` called `updateDisplayName` / `updatePhotoURL` itself. All three now go through
`AuthRepository` and small use cases (`IsProfileComplete`, `UpdateDisplayName`,
`UpdateProfilePhoto`, `GetProfilePhoto`), which is what let the phase's exit criterion pass.

---

### P1 — Structural

**P1-1 · No `fpdart` / `Either<Failure, T>`; error types leak into domain and presentation** ✅ *fixed*
`core/resources/data_state.dart` exposes a `DioException`; `core/resources/firebase_state.dart`
exposes a `FirebaseException`. Both are imported by `domain/repository/*.dart` and by
`presentation/**` — `movie_state.dart:8` literally stores a `DioException` in UI state.

The skill: repositories return `Either<Failure, T>` from `fpdart`, and *"Only `data/` knows
about `DioException`, `HiveError`, or `PlatformException`."*

`DataState` also can't be pattern-matched safely — it isn't sealed, and both subclasses share
nullable `data`/`error` fields, so `DataSuccess.error` is a legal expression.

*Fix:* `core/resource/failure.dart` (sealed `Failure`: `Network` / `Server` / `Auth` /
`Cache` / `Unknown`) and `core/resource/failure_mapper.dart` (Dio, HTTP status, and Firebase
→ `Failure`), covered by 15 unit tests — the first tests in the repo. Every repository
contract, use case, cubit, and bloc across all four features now speaks
`Either<Failure, T>`, consumed with `fold`. `core/resources/` is deleted.
`grep -rn "package:dio\|package:firebase\|package:cloud_firestore" lib/features/*/domain
lib/features/*/presentation` returns nothing.

Two contracts also stopped leaking values that were never used: `AuthRepository` returned
`UserCredential` into the domain (now `Either<Failure, Unit>`), and the liked-movies
repository returned `Right(true)` to mean success (now `Right(unit)`) — the skill's
"never return `Right` with an empty result to signal an error" read from the other side.

**P1-2 · `MovieModel extends MovieEntity` — no mapping seam** ✅ *fixed*
`lib/core/models/movie.dart:9`. The skill wants `Model` in `data/models/` with a `toEntity()`,
so a TMDB field rename touches exactly one file. Two consequences today: the downcast in
P0-3, and the model living in `core/models/` while being used by exactly one feature —
`core/models/` is for models genuinely shared across features.
Same for `core/models/series_model.dart`.

*Fix:* both models moved to their feature's `data/models/`, stopped extending their entity,
and gained an explicit `toEntity()` (`MovieModel` also keeps `fromEntity`, which Firestore
writes need). `core/models/` is deleted. The generated JSON keys were diffed against the
old `movie.g.dart` before and after — identical, so `liked_movies` documents already on the
server still match and `arrayRemove` keeps working. A test now pins that wire format.

**P1-3 · `flutter_screenutil` is the de-facto spacing system**
`.sp` / `.h` / `.w` / `.r` appear across every page and inside `theme.dart`. The skill's
system is `AppSpacing.*` (four-based), `AppRadius.*`, `AppInsets.*`, with no bare numbers in
`EdgeInsets` or `SizedBox` — 51 `EdgeInsets` sites currently use raw numbers. screenutil is
also not in the skill's package list. **This is a decision point, see Part 3.**

**P1-4 · No theme abstraction — colours and styles are named at call sites**
- 11 `Color(0x…)` outside `config/theme/`, e.g. `register_page.dart:48-56`,
  `login_page.dart:51-59,163`, `account_page.dart:37,51`, `set_profile_page.dart:200`,
  `custom_sliver_app_bar.dart:18`, `custom_text_field.dart:57`
- `Theme.of(context)` 42× — no `context.theme` / `context.palette` / `context.styles` extensions
- `brightness_extension.dart` drives appearance branching (`Theme.of(context).isLight ? A : B`)
  in widgets. The skill's model is one palette per brightness resolved by a slot name, so a
  widget never asks which brightness it is in.
- `theme.dart` is a flat pair of `ThemeData` literals with no shared `_themeOf(palette)`, so
  light and dark can (and already do) drift — e.g. the light `appBarTheme` sets a
  `titleTextStyle`, the dark one doesn't.

**P1-5 · No localization**
No `flutter_localizations`, no `intl` ARB setup, no `context.l10n`. Hardcoded user-facing
strings in `movie_page.dart:31`, `liked_movies_page.dart:29`, `movie_details_page.dart:357`,
`series_deatails_page.dart:330`, plus button labels, hints, and validation messages.

**P1-6 · No `flutter_gen`; asset paths are strings**
`splash_page.dart:65`, `home_page.dart:91` use `"assets/logo.png"`. Worse,
`profile_cubit.dart:22,30` *builds* paths with string interpolation
(`"assets/male/male$i.png"`) — a missing file is a runtime crash with no compile-time signal.

**P1-7 · No `AppNetworkImage` wrapper**
`CachedNetworkImage` is called directly in `hero_image.dart`, `movie_details_page.dart`,
`series_deatails_page.dart`, `movie_search_page.dart`. `hero_image.dart:29-36` has a
placeholder but **no `errorWidget`** — a broken poster URL renders as a red error box.
The skill requires a single `core/custom/app_network_image.dart` with placeholder + error +
bounded size, and forbids calling `CachedNetworkImage` anywhere else.

**P1-8 · Sealed state classes carry every field on the base**
`movie_state.dart:3-15` — `MovieState` declares `popularFilmsList`, `topFilmsList`,
`recommendedMovie`, and `error`, so `MovieLoading().error` compiles and `MovieSuccess.error`
compiles. That is precisely the "impossible combination" the skill says sealed states exist to
prevent: fields belong on the variant that owns them. Also `MovieState` is not `Equatable`,
so `emit` of an equal state still rebuilds. `SearchState` and `SeriesSearchState` are neither
sealed nor `Equatable`.

**P1-9 · Zero tests**
`test/widget_test.dart` is the untouched counter template — it pumps `MyApp` and looks for
`Icons.add`. It fails, and it would also hit real `Firebase.initializeApp` and real DI.
Nothing exists for models, repositories, or cubits, and there is no `integration_test/`.

Missing dev dependencies: `bloc_test`, `mocktail`, `patrol`.

**P1-10 · `analysis_options.yaml` is missing the enforced rules**
Currently only `prefer_relative_imports`, and it is written in list form under `rules:`
rather than the map form the skill shows. Missing: the four `prefer_const_*` rules,
`avoid_print`, `avoid_relative_lib_imports`.

**P1-11 · `json_serializable` is a runtime dependency**
`pubspec.yaml:47` puts it under `dependencies`. It is a generator — it belongs in
`dev_dependencies` with `build_runner`. Only `json_annotation` is a runtime dependency.

### P2 — Structure and naming

**P2-1 · Folder names differ from the skill in five places** ✅ *fixed*

| Now | Skill |
|---|---|
| `core/resources/` | `core/resource/` |
| `core/usecases/` | `core/usecase/` |
| `core/utils/custom/` | `core/custom/` |
| `features/*/data/data_sources/remote/` | `features/*/data/datasources/` |
| `features/*/data/repository/`, `domain/repository/` | `…/repositories/` |

*Fix:* all five renamed with `git mv` so history follows, plus `domain/usecase/` →
`domain/usecases/` from P2-3 (same mechanical pass — splitting it across two phases would
have doubled the churn). Only the `data_sources/remote/` → `datasources/` move changed
relative-import depth; those were fixed by hand.

**P2-2 · `features/series/states/` sits outside `presentation/`**
`series_state.dart`, `series_details_state.dart`, `series_search_state.dart` are at
`features/series/states/` while movie/auth/account use `presentation/states/`. The skill puts
state next to its cubit in `presentation/cubit/`. Pick one — the skill's — and apply it to all
four features.

**P2-3 · `domain/usecase/` (auth) vs `domain/usecases/` (movie, series)** ✅ *fixed* — folded into P2-1.

**P2-4 · `FirebaseRepository` is named after a technology, not a domain concept**
`features/movie/domain/repository/firebase_repository.dart` is the liked-movies contract, it
lives under `movie`, and it is consumed by the `account` feature
(`liked_movies_cubit.dart`). Rename to `LikedMoviesRepository` and move it to the feature
that owns the concept.

**P2-5 · `features/landing/` has no layer structure**
`home_page.dart` is a shell hosting the nested `movie` / `series` / `account` routes — that is
exactly the skill's `wrapper_page.dart`. `splash_page.dart` is a route with real logic
(reads prefs, drives `LoginCubit`) living in a folder with no `presentation/` directory.

**P2-6 · Four near-identical blocks in `movie_repository_impl.dart`** ✅ *fixed*
Lines 18-45, 48-74, 77-105, 108-137 are the same try / status-check / `DioException` construction
with a different call in the middle. Same shape again in `series_repository_impl.dart`.
One `_guard` helper removes ~100 lines and makes the error mapping testable in one place.

*Fix:* `core/network/api_guard.dart` — `guardApiCall(request, map)` handles the 200 / non-200
/ `DioException` branches once. Both repositories dropped from ~140 and ~100 lines to 58 and
50, each method now four lines. Five tests cover the branches, which is the error handling
for the entire HTTP data layer.

**P2-7 · `Isolate.run` wraps the whole network call** ✅ *fixed*
`movie_repository_impl.dart:19,50,79,110`. The HTTP request is already off the UI thread —
what actually blocks is JSON decoding, and Retrofit does that inside the isolate too, so it
works but the isolate deep-copies the `Dio`/service graph on every request. If the goal is
keeping big list parses off the main thread, isolate the *decode* step, not the request.
Worth re-measuring before keeping.

*Resolution:* removed entirely. Dio 5.8's default `FusedTransformer` already moves JSON
decoding to an isolate once a body passes 50 KB (`dio_mixin.dart:50`), using a fused
UTF-8 + JSON decoder that is faster than doing it by hand. The manual wrapper was therefore
copying the whole Dio/Retrofit graph into a fresh isolate per request to duplicate work the
client already does — and TMDB list responses are well under the threshold anyway. The
repositories are now plain async methods.

**P2-8 · `UseCase` signature makes required params optional**
`core/usecases/usecase.dart` — `Future<Return> call({Params? params})`. Every caller can omit
`params`, and every implementation has to `!` it. Prefer a positional, non-nullable parameter
plus a `NoParams` value type.

**P2-9 · Naming drift**
- `series_deatails_page.dart` — typo, and it propagates into the generated `SeriesDeatailsRoute`
- `SetProfile` page class (route `SetProfile.page`) should be `SetProfilePage` → `SetProfileRoute`
- `SeriesSearchState.searchedMovies` and `SeriesSearchCubit.searchMovies()` hold/handle series
- `entities/movie.dart` declares `MovieEntity`; `entities/series_entity.dart` declares
  `SeriesEntity` — pick one file-naming rule
- Use cases are `GetPopularMoviesUseCase`; the skill's example is `GetStaff` (verb + noun, no
  suffix). Currently consistent, so this is a rename-everything-or-nothing call.

**P2-10 · Dead and duplicated constants**
`core/constants/constants.dart` — `tmdbMovieBaseUrl` and `tmdbSeriesBaseUrl` are the same
string; `topRatedMoviesUrl`, `popularMoviesUrl`, `topRatedSeriesUrl`, `popularSeriesUrl`,
`tbdbSearchUrl` (typo) are unused now that Retrofit uses relative paths.

**P2-11 · Overlapping packages**
- Animation: `animations` + `animate_do` + `flutter_animate` — three libraries for one concern
- Colour extraction: `extract_colors_from_image` + `palette_generator`
- `flutter_isolate` is declared but the code uses `dart:isolate`'s `Isolate.run`
- `flutter_cache_manager` is a transitive dep of `cached_network_image`; no need to declare it
- `meta` ships with the SDK

**P2-12 · Two pages over 480 lines**
`movie_details_page.dart` (520) and `series_deatails_page.dart` (483). The skill's threshold is
~100 lines per `build`, split into widget classes. Good news: there are zero
`Widget _buildX()` methods in the codebase, so the split is into real classes from the start.

**P2-13 · No `BlocSelector` anywhere, and no page-deep `BlocBuilder` discipline**
44 bloc-widget usages, none of them `BlocSelector`. Worth a pass once states are properly
sealed.

---

## Part 2 — Integration guide

Nine phases. Phases 0–3 are foundation and touch every feature; 4–8 can be done feature by
feature. After each phase: `dart format . && flutter analyze && flutter test`.

### Phase 0 — Toolchain and lint gate ✅ *done*
*No production code changes beyond `const` additions.*

1. ✅ `analysis_options.yaml` now carries the skill's rule set in map form — four
   `prefer_const_*`, `avoid_print`, `prefer_relative_imports`, `avoid_relative_lib_imports` —
   plus `formatter: page_width: 150` and an `exclude: build/**` (an iOS build checks SPM
   dependencies out there, and some ship Dart sources).
2. ✅ The rules surfaced 126 issues (120 `prefer_const_constructors`,
   6 `prefer_const_literals_to_create_immutables`). `dart fix --apply` cleared 95 across
   22 files; the rest followed from the import fix below.
3. ✅ `dart format .` — 18 of 943 files changed. Choosing 150 over 80 kept the churn to the
   handful of files that were already wider.
4. ✅ **Nine unused dependencies removed**: `animations`, `animate_do`,
   `extract_colors_from_image`, `palette_generator`, `flutter_isolate`, `meta`,
   `flutter_cache_manager`, `flutter_page_stepper`, `email_validator`. Every one had zero
   imports in `lib/` — the "which animation library wins" question answered itself.
   `json_serializable` and `flutter_native_splash` moved to `dev_dependencies` (both are
   tools, not runtime deps). `fpdart` and `mocktail` added. Remaining deps regrouped under
   comment headers by concern.
5. ✅ Both `cacheExtent` deprecations migrated to `scrollCacheExtent`. Note `dart fix`
   rewrote the call but did **not** add the `package:flutter/rendering.dart` import that
   `ScrollCacheExtent` needs — that had to be done by hand in both files.

**Done:** `flutter analyze` → *No issues found*; iOS simulator build + boot verified.

### Phase 1 — `core/resource`: `Failure` and `Either`
*Foundation for everything else. One PR, mechanical, large diff.*

1. Create `core/resource/failure.dart` — a sealed `Failure` with `NetworkFailure`,
   `ServerFailure`, `AuthFailure`, `CacheFailure`, `UnknownFailure`, each carrying a `message`.
2. Create `core/resource/failure_mapper.dart` — `Failure fromDio(DioException)` and
   `Failure fromFirebase(FirebaseException)`. This is where every `DioExceptionType` and
   `FirebaseAuthException.code` becomes a user-facing message. **Unit-test this file** — it is
   pure logic with real branching.
3. Change every repository contract from `DataState<T>` / `FirebaseState<T>` to
   `Future<Either<Failure, T>>`.
4. Update the impls, then the use cases, then the cubits — consume with `fold`, never
   `isRight()` + `getOrElse`.
5. Delete `core/resources/`.

Do movie → series → auth → account, compiling between each.

**Done when:** no `dio` or `firebase` import exists under any `domain/` or `presentation/`
directory. Verify: `grep -rn "package:dio\|firebase" lib/features/*/domain lib/features/*/presentation`

### Phase 2 — Data layer cleanup

1. `core/network/dio_client.dart` — one configured `Dio` with an auth interceptor that sets
   `accept` and `Authorization` headers. Register it in `injection_container.dart`.
2. Strip the `accept` / `apiKey` parameters from both `*_api_service.dart` files; regenerate.
3. Move the TMDB token to `--dart-define=TMDB_TOKEN=…` read via
   `String.fromEnvironment`; keep a `.vscode/launch.json` entry and document it in the README.
   Delete `core/utils/api_key.dart`.
4. Split model from entity: move `core/models/movie.dart` → `features/movie/data/models/movie_model.dart`,
   stop extending `MovieEntity`, add `toEntity()`. Same for `series_model.dart`. Repository
   impls map at the boundary. This closes P0-3.
5. Extract the `_guard` helper in both repository impls; remove the four-fold duplication.
6. Re-evaluate `Isolate.run` (P2-7) — measure with a real list before keeping it.
7. Rename directories: `data_sources/remote/` → `datasources/`, `repository/` → `repositories/`,
   `core/resources/` → `core/resource/`, `core/usecases/` → `core/usecase/`.

**Done when:** `MovieModel` no longer extends `MovieEntity`, and no `as MovieModel` cast exists.

### Phase 3 — Credentials and the login bug ✅ *done*
*Steps 1–4 landed with P0; step 5 was the remaining work.*

1. ~~`core/storage/token_manager.dart` over `flutter_secure_storage`.~~ **Skipped** — nothing
   left to store; see the status note above.
2. Remove the `email` / `password` prefs writes from `LoginCubit`. "Remember me" becomes a
   boolean in prefs plus a `FirebaseAuth.instance.currentUser` check in `SplashPage` — no
   credential is stored anywhere.
3. Add a one-time migration that deletes the legacy `email` / `password` prefs keys on launch,
   so existing installs don't keep a plaintext password on disk.
4. Fix the `getIt<LoginCubit>()` call sites: resolve once in the `BlocProvider`, use
   `context.read<LoginCubit>()` thereafter.
5. ✅ `ThemeCubit` now depends on `core/storage/theme_local_datasource.dart` instead of
   reaching for `getIt<SharedPreferences>()`; it is registered in `injection_container.dart`
   and resolved in `main.dart`.

**Done:** `grep -rn "getIt<SharedPreferences>\|SharedPreferences.getInstance" lib` returns
nothing outside a datasource or the DI container.

Three things the move fixed on the way:

- **`DeviceTheme.label` was both the UI string and the persisted key.** Phase 5 translates
  that label — which would have silently invalidated every stored preference. The datasource
  now persists `DeviceTheme.name` (`light` / `dark` / `system`) and still reads the old
  labels, so an existing install migrates on its next write. Tested both directions.
- **An unrecognised stored value crashed the app on launch.** `getEnumByLabel` used
  `firstWhere` with no `orElse`, so any stale string threw a `StateError` before the first
  frame. The datasource falls back to `system`.
- **`ThemeState` held both `mode` and `deviceTheme`**, which could disagree, and was not
  `Equatable` — so every emit rebuilt the whole `MaterialApp`. `mode` is now derived from
  `deviceTheme`, and the state is `Equatable`.

### Phase 4 — Theme system ✅ *done*

1. `config/theme/app_colors.dart` — `AppPalette` with purpose-named slots
   (`surface`, `surfaceMuted`, `textPrimary`, `textSecondary`, `accent`, `danger`, …), one
   instance per brightness. The only file allowed to contain `Color(0x…)`.
2. `config/theme/app_typography.dart` — the only file allowed to call `GoogleFonts` or build a
   `TextStyle`. `AppTextStyles` for meaning-carrying styles (rating, genre chip, overview).
3. `config/theme/app_spacing.dart` — `AppSpacing` (4-based), `AppRadius`, `AppInsets`.
4. `config/theme/app_decorations.dart` — the repeated card/poster surfaces.
5. `config/theme/theme.dart` — a single `_themeOf(AppPalette)` producing both themes.
6. `core/extensions/context_extension.dart` — `context.palette`, `context.textTheme`,
   `context.styles`, `context.l10n`.
7. Migrate call sites feature by feature, deleting `brightness_extension.dart` usages as the
   slots replace them.

**Done.** All four checks are at zero: no `Color(0x…)` outside `config/theme`, no
`Theme.of(context)` outside the theme and its extension, no bare number in an `EdgeInsets`
or `spacing:`, no `TextStyle(` built outside `config/theme`. `brightness_extension.dart` is
deleted — widgets name a slot instead of asking which brightness they are in.

Checked on device in **both** brightnesses. Two regressions the screenshots caught, both
introduced by this phase and both fixed:

- **The auth greeting slid under the status bar.** The old `top: 50.h` became
  `AppSpacing.huge`, and because the scale uses `.r` rather than `.h` that is ~18pt shorter
  on a tall phone. Replaced with `SafeArea` plus a spacing step, which is the right answer
  anyway — that inset is notch clearance, not rhythm.
- **Text-field edges turned loud white in dark.** The border was `Colors.black` in both
  brightnesses, i.e. invisible in dark; mapping it to `textPrimary` made it a bright outline.
  It now uses a `fieldEdge` slot that reproduces the shipped look. **Dark deserves a real
  value here** — that is a design call, not a refactor, so it is left for you.

One thing worth your eye: in light, `Filmio` on the auth banner is `heading` (`#3700b3`) on
the purple gradient — low contrast. That is inherited, not new, but the palette now makes it
a one-line change.

Vertical rhythm is ~2% tighter overall from `.h` → `.r`; side-by-side the login screen is
within a couple of points of where it was.

### Phase 5 — Assets, images, strings ✅ *done*

1. `flutter_gen` — add the `flutter_gen:` config block, run `build_runner`, replace all four
   string paths. `profile_cubit.dart` builds a list from `Assets.male.values` instead of
   interpolating filenames.
2. `core/custom/app_network_image.dart` — wraps `CachedNetworkImage` with a shimmer
   placeholder, an error widget, and a required bounded size. Rewrite `HeroImage` on top of it
   and replace the three direct call sites.
3. Also promote `core/custom/app_error_view.dart` (the retry view for a `Failure` state) and
   `core/custom/app_shimmer.dart` — both are referenced by the skill by name and both will be
   needed by the sealed-state UI in Phase 6.
4. Localization: `flutter_localizations` + `config/l10n/app_en.arb`, `flutter gen-l10n`, then
   `context.l10n.x` everywhere. Remember: **do not** add `generate: true` under `flutter:` —
   it breaks `flutter_gen`; see `references/assets-and-l10n.md`.

**Done.** All four checks at zero: no `'assets/` string in Dart, no `CachedNetworkImage`
outside the wrapper, no `Image.network`, no hardcoded user-facing `Text("…")`, and no
`AppLocalizations.of(` outside the extension.

- `Assets.male.values` / `Assets.female.values` replaced `ProfileCubit`'s
  `"assets/male/male$i.png"` interpolation — the generator reads what is actually on disk,
  so a renamed file is now a compile error rather than a runtime crash. The *stored* value
  stays the same path string, because it lives in Firebase against existing users.
- `AppNetworkImage`, `AppShimmer`, `AppErrorView` added to `core/custom/`. `HeroImage` is
  rebuilt on top of it, which is how it finally got an `errorWidget` — a dead poster URL used
  to render as a red error box.
- `DeviceTheme.label` is gone: it was display text, and display text is now translated. The
  legacy-label migration moved into `ThemeLocalDataSource`, where it belongs.

**On the skill's `flutter_gen` / l10n conflict:** the reference says never to add
`generate: true` under `flutter:`. This SDK (Flutter with Dart 3.12) *refuses* to run
`gen-l10n` without it. The reference anticipates this — it says to check whether the current
SDK still needs `synthetic-package: false`. It does not: the synthetic package is gone,
`gen-l10n` writes next to the ARB files in `lib/config/l10n/`, and the package-name collision
that caused the original conflict no longer exists. Verified by running both generators back
to back — `lib/gen/assets.gen.dart` survives `flutter gen-l10n` and vice versa. `generate: true`
is set, with a comment in `pubspec.yaml` pointing here.

### Phase 6 — State modeling and folder normalization ✅ *done*

**Not everything became sealed, deliberately.** The skill's rule is that a state should not
be able to hold an impossible combination — it is not "every state is a sealed hierarchy".
`MovieDetailsState` and `SeriesDetailsState` hold independent view flags (`isPageShrinked`,
`isOpacityAnimating`), which are not phases of one thing; sealing them would be the pattern
applied for its own sake. They became `Equatable` records instead. What *did* get sealed is
the part that genuinely has phases:

- **`SimilarMoviesState`** (`Loading` / `Loaded` / `Failure`) is now a field on
  `MovieDetailsState`. Before, a failed request emitted an empty list — indistinguishable
  from "this film has no similar titles". The row now shows a spinner, then either results
  or the failure message.
- **`ProfileState.stage`** was a constructor argument on the base, so a `ProfileSetName`
  carrying `stage: 1` was constructible. It is now derived from the variant.
- **`SettingsState`** was an empty class. It is now `Idle` / `SigningOut` / `SignedOut`, which
  exposed a real bug: `settings_page` called `logout()` and navigated to the login screen in
  the same callback, without awaiting. Navigation moved into a `BlocListener` on
  `SignedOut`, so it waits for the sign-out instead of racing it.
- **`SeriesDetailsState.isMovieLiked` was deleted.** Nothing ever set it — liking a series is
  unimplemented and the button's `onTap` is commented out — so it was state in name only.

1. Rewrite each state as a sealed hierarchy where **fields live on the variant that owns them**:
   `MovieLoading` (no fields) / `MovieLoaded(popular, topRated, recommended)` /
   `MovieFailure(Failure)`. All `Equatable`. Match with an exhaustive `switch` in the UI.
2. Give `SearchState` / `SeriesSearchState` real `Initial` / `Loading` / `Loaded` / `Failure`
   variants — closes P0-4.
3. Move `features/series/states/` into `presentation/cubit/`; do the same for the other three
   features' `presentation/states/`.
4. Unify `domain/usecase/` → `domain/usecases/`.
5. Rename `FirebaseRepository` → `LikedMoviesRepository` and move it to the feature that owns it.
6. `features/landing/`: `home_page.dart` → `wrapper_page.dart`; give `splash` a
   `presentation/pages/` path.
7. Fix `series_deatails_page.dart` → `series_details_page.dart`, `SetProfile` → `SetProfilePage`,
   `SeriesSearchState.searchedMovies` → `searchedSeries`. Regenerate routes.
8. Clean `core/constants/constants.dart`.

**Done.** No `states/` folder remains — every state file sits beside the cubit or bloc that
owns it. Renames: `FirebaseRepository` → `LikedMoviesRepository` (it was named after a
technology; kept in `movie`, which owns `MovieEntity` and where liking happens — `account`
consumes it through the use case), `HomePage` → `WrapperPage` (it is the shell hosting the
nested routes), `SetProfile` → `SetProfilePage`, and `series_deatails_page` →
`series_details_page`, which finally removes the typo from the generated `SeriesDetailsRoute`.
`landing/` gained the `presentation/` layer it was missing.

`core/constants/constants.dart` lost five unused URLs and a duplicated base URL; the
Firestore extension now uses the `userCollection` constant that already existed instead of a
literal. Three more strings that the Phase 5 sweep missed — `"Next"`, `"Finish"`,
`"Set a profile picture"` — were not inside `Text(...)` so the grep never saw them; they are
in the ARB now.

### Phase 7 — Tests ⚠️ *mostly done*

93 tests, `test/` mirroring `lib/`, with `fixtures/`, `helpers/mocks.dart`,
`helpers/pump_app.dart` and `helpers/test_di.dart`. `bloc_test` went in once Phase 5's
`auto_route` upgrade unblocked it.

**Two real bugs the tests found, both fixed:**

- **Movie search threw `ProviderNotFoundException` the moment you typed.** In P0-4 I removed
  a `BlocBuilder` around the search field as a "pointless rebuild" — but its builder was the
  only context *below* the `BlocProvider`, and `onChanged` read the cubit from it. After the
  removal `context.read` ran against the page's own build context and could not find the
  cubit. This was **a regression I introduced**, and it survived every device check because
  the search screen sits behind login. The page now follows the skill's shape: the
  `@RoutePage` widget creates the provider, an inner `_SearchView` consumes it.
- **The search app bar overflowed on any phone under ~400pt.** A fixed `260.w` field plus a
  Cancel button did not fit; the field is now `Expanded`.

**Two more regressions the signed-in device pass caught, both mine, both fixed:**

- **`HeroImage` lost its screenutil scaling.** Rewriting it onto `AppNetworkImage` in Phase 5
  turned `height: 250.h` into `height: 250.0`, so every poster — search results, similar
  titles, the home rows, the liked list — rendered ~21% short.
- **`AppNetworkImage` forced `BoxFit.cover`.** The original `CachedNetworkImage` passed no
  `fit`, i.e. the framework default (`scaleDown`), which preserves a poster's aspect ratio.
  `fit` is now nullable and only the search grid asks for `cover`, which is what it always
  had.

**To make the Firebase repositories testable**, `AuthRepositoryImpl` and
`LikedMoviesRepositoryImpl` now take `FirebaseAuth` / `FirebaseFirestore` by constructor
instead of reaching for `.instance`, and both are registered in `injection_container.dart`.
The `getUserDocRef()` extension ignored its receiver and read the singletons itself; it is
now `userDoc(uid)`.

**Gaps, stated plainly:**

- Only one page has a widget test (`MovieSearchPage`, 5 tests). The other screens do not.
- `AppNetworkImage`'s **error** path is not covered: `cached_network_image` resolves through
  `flutter_cache_manager`, which needs file IO a widget test does not have, so a dead URL
  never reaches `errorWidget` under `flutter test`. Covering it would mean injecting a cache
  manager into production code purely for the test.
- `AuthRepositoryImpl`, `RegisterCubit`, `ProfileCubit`, `ThemeCubit`, `SettingsCubit`,
  `SeriesSearchCubit` and `SeriesRepositoryImpl` have no tests yet.
- The liked-movies list does not refresh after unliking from a details screen — the cubit
  loads once in its constructor. Pre-existing.
- `liked_movies_page` renders a literal `Text("data")` for every row, a placeholder from the
  original layout that ships to users. Left in place because removing visible content is a
  product decision; it is now isolated in `_LikedMovieCard` with a comment.
- **Patrol is scaffolded, not run.** `pubspec.yaml` has the config block,
  `integration_test/helpers/app_launcher.dart` boots the real app, and `movie_test.dart`
  asserts a cold start lands on login. Running it needs the CLI, which is a machine-level
  install:

```bash
flutter pub global activate patrol_cli
patrol doctor
patrol test --dart-define-from-file=env.json
```

1. Scaffold: `test/helpers/mocks.dart`, `test/helpers/pump_app.dart`, `test/helpers/test_di.dart`,
   `test/fixtures/fixture_reader.dart`, and real TMDB JSON captures in `test/fixtures/`.
   Delete `test/widget_test.dart`.
2. Per feature, mirroring `lib/`:
   - `data/models/*_model_test.dart` — `fromJson` and `toEntity`, including null-heavy TMDB rows
   - `data/repositories/*_repository_impl_test.dart` — the highest-value tests here: success,
     non-200, `DioException` → `Failure` mapping, and the Firestore paths
   - `presentation/cubit/*_cubit_test.dart` — `bloc_test`, mocked use cases, assert the emitted
     state sequence
   - Skip the Retrofit services and any pass-through use case — the skill explicitly says a
     test that only proves a mock returns its configured value should not exist.
3. Widget tests **after** the UI settles (Phase 8), one per page, mocked cubit via `whenListen`,
   asserting rendered state and that interactions call the right cubit method — never padding,
   colours, or font sizes.
4. `patrol` last: `patrol:` config block in `pubspec.yaml`, `integration_test/helpers/app_launcher.dart`,
   then `auth_test.dart`, `movie_test.dart`, `series_test.dart`. Gitignore `test_bundle.dart`
   and `.patrol.env`.

**Not done when:** every model, repository impl, and cubit has a unit test, and each feature
has one Patrol flow. See the gaps above — the pattern for each kind of test now exists, so
the remainder is repetition rather than design.

### Phase 8 — Page decomposition ✅ *done*

**The plan mis-stated this phase.** It was written from *file* lengths (`movie_details_page`
520 lines, `series_details_page` 483) and assumed the pages were monoliths. Measuring
actual `build` methods showed they were already split into private widget classes with no
`Widget _buildX()` anywhere — the longest were 91 and 87 lines. The one method genuinely over
the threshold was `_SetPhotoState.build` in `set_profile_page` at 108, plus
`LikedMoviesPage.build` at 103 once its list item was counted.

1. ✅ `_SetPhotoState.build` split — the avatar grid and the two gender arrows became
   `_AvatarPicker` and `_SwitchGenderArrow`. `LikedMoviesPage`'s row became `_LikedMovieCard`.
2. ✅ **Six `BlocBuilder`s became `BlocSelector`s** across the two details pages, each scoped
   to the single field it reads (`isMovieLiked`, `isOpacityAnimating`, `similars`). Two more
   read two fields each and stay `BlocBuilder`. One more disappeared entirely: the series
   like-button was wrapped in a `BlocBuilder` that rebuilt on every state change to draw a
   constant icon, because the only state it read is commented out.
3. ✅ Navigation already moved into `BlocListener` during Phases 1 and 6 (login, settings).
4. ✅ `const` pass via `dart fix`.

**Done.** No `build` method exceeds 100 lines; there are zero `Widget _buildX()` methods in
`lib/`. Verified on device by comparing the movie details screen before and after in both its
collapsed and expanded states — pixel-identical.

**Not done:** `movie_details_page` and `series_details_page` still hold ~250 lines of
near-identical widget code between them (`_ScrollBody`, `_InformationContainer`,
`_ShrinkedView`, `_ExpandedView`). Sharing them means a generic details scaffold parameterised
over `MovieEntity` / `SeriesEntity` — a design task, not a mechanical split, and out of scope
for a phase about build-method length.

---

## Part 3 — Decisions

### Settled

- ✅ **Formatter width: 150.** Set in `analysis_options.yaml`. Chosen because 6 files already
  ran past 120 and the most recently written code (`app_router.dart` at 148, `theme.dart` at
  127) is wide — reformatting at 80 would have re-wrapped 47 of 93 files.
- ✅ **Animation packages** — non-question. `animations` and `animate_do` had zero imports;
  only `flutter_animate` is used (8 files). Both removed.
- ✅ **Colour extraction** — also non-question. Both `extract_colors_from_image` and
  `palette_generator` had zero imports. Both removed; add one back when a screen needs it.
- ✅ **Dependency timing** — packages get added in the phase that uses them, not up front.
- ✅ **`flutter_screenutil` stays, hidden inside the scale.** `AppSpacing` and `AppRadius` are
  the only files that call it; every step is `.r` (the smaller of the width and height
  factors) so a step is the same size on both axes. Call sites read `AppSpacing.lg`. Dropping
  screenutil later means editing those getters and nothing else.
- ✅ **No `google_fonts` yet.** `app_typography.dart` is the single place a `TextStyle` is
  built, so adding a font is one line there — but picking one is a design decision, and the
  app currently uses the platform font. Left as-is.

### Still open

2. **Failure messages are not localized.** UI strings all come from `app_en.arb`, but the
   text on a `Failure` is still written in `failure_mapper.dart`. The skill says to map the
   failure *type* to an l10n key in the widget layer — which loses the status-code
   distinctions the mapper makes today (401 vs 404 vs 5xx all become "ServerFailure"). Doing
   it properly needs finer-grained `Failure` subtypes. Left as a decision.

3. **Only `app_en.arb` exists.** Adding `app_tr.arb` is now a single file — but which
   languages to ship is a product call.

4. **Use case naming** — keep the `…UseCase` suffix (currently consistent) or move to the
   skill's `GetPopularMovies`. **Recommendation: keep the suffix**, note it as an intentional
   project deviation, and don't spend a phase on a pure rename.

5. **Phase 7 timing** — the skill is test-driven, so strictly the tests come *before* the
   Phase 1/2 rewrites. Practically, writing repository tests against the current `DataState`
   API means rewriting them in Phase 1. **Recommendation:** write the tests immediately *after*
   each feature's Phase 1+2 migration, feature by feature, rather than as one late phase.

---

## Suggested order

Foundation, then feature by feature:

```
Phase 0  ─ toolchain                         (all)          ✅ done
Phase 1  ─ Failure/Either        ─ movie → series → auth → account
Phase 2  ─ data layer            ─ movie → series → auth → account
   └─ tests for each feature as it lands (Phase 7, steps 1-2)
Phase 3  ─ credentials + login bug           (auth)
Phase 4  ─ theme                             (all)
Phase 5  ─ assets / images / l10n            (all)
Phase 6  ─ sealed states + folders ─ per feature
Phase 8  ─ page decomposition      ─ movie details → series details
Phase 7  ─ widget + patrol tests             (all)
```

Start with **movie** in each phase — it is the largest feature and exercises both TMDB and
Firestore, so whatever pattern works there transfers to the rest.
