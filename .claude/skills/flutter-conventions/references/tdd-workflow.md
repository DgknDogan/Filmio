# TDD Workflow

Read this before starting any new feature, and whenever deciding whether a class needs a test.

## Contents

- [The order](#the-order)
- [What gets a test and what does not](#what-gets-a-test-and-what-does-not)
- [Step 1 — Domain contracts](#step-1--domain-contracts)
- [Step 2 — Model, test first](#step-2--model-test-first)
- [Step 3 — Repository implementation, test first](#step-3--repository-implementation-test-first)
- [Step 4 — Use case, conditional](#step-4--use-case-conditional)
- [Step 5 — Cubit, test first](#step-5--cubit-test-first)
- [Step 6 — Registration and routing](#step-6--registration-and-routing)
- [Step 7 — UI](#step-7--ui)
- [Step 8 — Widget tests](#step-8--widget-tests)
- [Step 9 — Integration test (Patrol)](#step-9--integration-test-patrol)
- [Test setup conventions](#test-setup-conventions)

---

## The order

There are exactly three kinds of test — **unit test**, **widget test**, **integration test**. Never introduce a fourth category or a project-specific label for one.

Work through a feature in this sequence. Steps 1–5 run under `flutter test` without rendering a single widget, and getting them green first is what keeps the state model honest.

| Step | What | Test first? |
|---|---|---|
| 1 | Entity + abstract repository | No test — these are contracts, not behaviour |
| 2 | `Model` (`fromJson`, `toEntity`) | **Yes** |
| 3 | `RepositoryImpl` | **Yes** — the most valuable tests in the feature |
| 4 | `UseCase` | Only if it has its own logic |
| 5 | `Cubit` / `Bloc` | **Yes** |
| 6 | DI registration + routes | No — wiring, not behaviour |
| 7 | Pages and widgets | No — write the UI first |
| 8 | Widget tests | After the UI exists |
| 9 | Integration test | Last |

Before writing any UI for the feature, `flutter test` must be green.

Within steps 2, 3, and 5 the cycle is red → green → refactor: write the failing test from the contract, write the least code that passes it, then clean up. The point is not coverage. It is that writing the test first forces the reference point to be the contract rather than whatever the implementation happens to do — and it surfaces design problems (too many collaborators to mock, a class doing two jobs) while changing course is still free.

## What gets a test and what does not

The rule: **test behaviour, not structure.** If a class has no decision, no transformation, and no error handling, a test for it only proves that the mock you just configured returns what you told it to.

| Do test | Do not test |
|---|---|
| `fromJson` / `toEntity` mappings | Retrofit `@RestApi` services — the body is generated |
| `RepositoryImpl` error mapping and fallbacks | `*.g.dart` / `*.gr.dart` files |
| Use cases with validation, transformation, or composition | Use cases that only forward a call |
| Cubits and blocs | Freezed/JsonSerializable boilerplate |
| Interceptors (auth, token refresh, retry) | Thin local datasource wrappers with no ordering logic |
| Local datasources with real logic (cache clear + write, key migration) | Getters, `copyWith`, `props` |

When a "should I test this" question comes up that the table does not answer, ask whether a plausible bug could exist in the code without any other test catching it. If not, skip it.

## Step 1 — Domain contracts

Write the entity and the abstract repository first, without tests. They carry no behaviour, but the next step's test is written in their vocabulary, so they have to exist.

```dart
// features/staff/domain/entities/staff.dart
class Staff extends Equatable {
  const Staff({required this.id, required this.name, this.avatarUrl});

  final String id;
  final String name;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
```

```dart
// features/staff/domain/repositories/staff_repository.dart
abstract interface class StaffRepository {
  Future<Either<Failure, List<Staff>>> getStaff({int page});
  Future<Either<Failure, Unit>> deleteStaff(String id);
}
```

Deciding the return types here — `Either<Failure, T>`, `Unit` for void successes — is the actual design work. Everything downstream follows from it.

## Step 2 — Model, test first

Save a real API response as a fixture so the test breaks when the backend changes:

```
test/fixtures/staff_list.json
```

```dart
// test/features/staff/data/models/staff_model_test.dart
void main() {
  test('maps snake_case keys and a null avatar', () {
    final json = jsonDecode(fixture('staff_list.json'))['data'][0]
        as Map<String, dynamic>;

    final model = StaffModel.fromJson(json);

    expect(model.id, '1');
    expect(model.fullName, 'Ada Lovelace');
    expect(model.avatarUrl, isNull);
  });

  test('toEntity carries every field across', () {
    const model = StaffModel(id: '1', fullName: 'Ada', avatarUrl: 'x.png');

    final entity = model.toEntity();

    expect(entity, const Staff(id: '1', name: 'Ada', avatarUrl: 'x.png'));
  });
}
```

What is under test is the `@JsonKey` mapping and `toEntity`, not the generated function. Cover nullable fields and any date or enum parsing explicitly — that is where mapping bugs actually live.

## Step 3 — Repository implementation, test first

The highest-value tests in the feature. Mock the Retrofit service and the local datasource; test your own decisions.

```dart
class MockStaffApiService extends Mock implements StaffApiService {}
class MockStaffLocalDataSource extends Mock implements StaffLocalDataSource {}

void main() {
  late MockStaffApiService api;
  late MockStaffLocalDataSource local;
  late StaffRepositoryImpl repository;

  const tModel = StaffModel(id: '1', fullName: 'Ada');

  setUp(() {
    api = MockStaffApiService();
    local = MockStaffLocalDataSource();
    repository = StaffRepositoryImpl(api, local);
  });

  DioException connectionError() => DioException(
        requestOptions: RequestOptions(path: '/staff'),
        type: DioExceptionType.connectionError,
      );

  test('returns entities and caches them on success', () async {
    when(() => api.getStaff(page: 1)).thenAnswer((_) async => [tModel]);
    when(() => local.cacheStaff(any())).thenAnswer((_) async {});

    final result = await repository.getStaff();

    expect(result.isRight(), isTrue);
    verify(() => local.cacheStaff([tModel])).called(1);
  });

  test('falls back to cache when the network fails', () async {
    when(() => api.getStaff(page: 1)).thenThrow(connectionError());
    when(() => local.getCachedStaff()).thenAnswer((_) async => [tModel]);

    final result = await repository.getStaff();

    expect(result.isRight(), isTrue);
  });

  test('returns NetworkFailure when the network fails and the cache is empty',
      () async {
    when(() => api.getStaff(page: 1)).thenThrow(connectionError());
    when(() => local.getCachedStaff()).thenAnswer((_) async => []);

    final result = await repository.getStaff();

    expect(result, const Left(NetworkFailure()));
  });
}
```

At minimum: the happy path, one failure path per `Failure` type the method can produce, and every fallback branch. Writing these before the implementation is what makes the error mapping deliberate instead of an afterthought.

No unit test may touch the real network. If an endpoint's query or path construction is genuinely intricate, `http_mock_adapter` can verify the generated URL — treat that as an exception, not a rule.

## Step 4 — Use case, conditional

Test it when it has logic of its own:

- Validation (reject an empty id before hitting the repository)
- Parameter transformation (page number → offset)
- Composition of more than one source (profile + permissions)
- A decision (cache is stale, go remote)
- A business rule (sorting, filtering, permission check)

```dart
test('returns ValidationFailure without calling the repository for a blank id',
    () async {
  final result = await deleteStaff('');

  expect(result, const Left(ValidationFailure('Id is required.')));
  verifyNever(() => repository.deleteStaff(any()));
});
```

If the use case only forwards the call, do not write a test for it — and question whether the class needs to exist. For CRUD-shaped features, letting the cubit call the repository directly is fine, as long as the whole feature is consistent about it. Since every unit test mocks its collaborators, a use case wired to the wrong repository method is caught by the integration test in step 9, not here.

## Step 5 — Cubit, test first

Write the expected state sequence before the cubit exists. This is the step that designs the state model: listing the states you expect to be emitted forces you to think in flows rather than screens, before any layout exists to bias you.

```dart
void main() {
  late MockGetStaff getStaff;
  const tStaff = [Staff(id: '1', name: 'Ada')];

  setUp(() {
    getStaff = MockGetStaff();
    registerFallbackValue(const NoParams());
  });

  group('StaffCubit.load', () {
    blocTest<StaffCubit, StaffState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => getStaff()).thenAnswer((_) async => const Right(tStaff));
        return StaffCubit(getStaff);
      },
      act: (cubit) => cubit.load(),
      expect: () => const [StaffLoading(), StaffLoaded(tStaff)],
    );

    blocTest<StaffCubit, StaffState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => getStaff())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return StaffCubit(getStaff);
      },
      act: (cubit) => cubit.load(),
      expect: () => [const StaffLoading(), isA<StaffError>()],
    );
  });
}
```

Cover every public method, and both branches of every `fold`. For debounced or delayed logic, pass `wait:`.

## Step 6 — Registration and routing

No tests here — this is wiring. Register the feature in `injection_container.dart` outer to inner (datasources → repository → use cases → cubit as a `registerFactory`), then add its routes to `AppRouter` and run `build_runner` so the generated route classes exist. See `references/data-layer.md` and `references/routing.md`.

Doing this before the UI means the page can resolve its cubit from `sl` the moment it is written, instead of being built against a constructor that does not exist yet.

## Step 7 — UI

Write the pages and widgets once steps 1–5 are green. No tests during this step — asserting on a layout that does not exist yet produces tests you rewrite with every visual change.

While writing the UI, add `Key`s to the elements a test will need to find. Keep them as constants so tests and widgets cannot drift apart:

```dart
// core/utils/widget_keys.dart
abstract final class WidgetKeys {
  static const staffList = Key('staff_list');
  static const staffRetryButton = Key('staff_retry_button');
}
```

Prefer finding by text or type where it is stable; reach for keys when the same widget type appears more than once, or when the visible text is localized and would make the test brittle.

## Step 8 — Widget tests

Render one page with a mocked cubit and assert on what the user sees. The questions a widget test answers: does each state render the right thing, and does each interaction call the right cubit method. It does not test business logic — that is already covered by steps 2–5.

Use `MockCubit` from `bloc_test` together with `whenListen` to script the state stream:

```dart
// test/helpers/mocks.dart
class MockStaffCubit extends MockCubit<StaffState> implements StaffCubit {}
```

```dart
// test/features/staff/presentation/pages/staff_page_test.dart
void main() {
  late MockStaffCubit cubit;
  const tStaff = [Staff(id: '1', name: 'Ada')];

  setUp(() => cubit = MockStaffCubit());

  Future<void> pumpPage(WidgetTester tester) => tester.pumpApp(
        BlocProvider<StaffCubit>.value(value: cubit, child: const StaffView()),
      );

  testWidgets('shows a spinner while loading', (tester) async {
    when(() => cubit.state).thenReturn(const StaffLoading());

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the list once loaded', (tester) async {
    when(() => cubit.state).thenReturn(const StaffLoaded(tStaff));

    await pumpPage(tester);

    expect(find.byKey(WidgetKeys.staffList), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('retry button calls load()', (tester) async {
    when(() => cubit.state).thenReturn(const StaffError('boom'));
    when(() => cubit.load()).thenAnswer((_) async {});

    await pumpPage(tester);
    await tester.tap(find.byKey(WidgetKeys.staffRetryButton));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('shows a snackbar when the state turns to error', (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable([const StaffLoading(), const StaffError('boom')]),
      initialState: const StaffInitial(),
    );

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('boom'), findsOneWidget);
  });
}
```

Cover, per page: one test per state the page can render, one per user interaction that calls the cubit, and any `BlocListener` side effect (snackbar, dialog, navigation). Skip pure layout assertions — padding, colours, font sizes change constantly and testing them only creates maintenance work.

Pump the page through the shared helper so every test gets the same theme, localization, and router setup:

```dart
// test/helpers/pump_app.dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) => pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      );
}
```

Test the inner view (`_StaffView` made package-private or extracted as `StaffView`), not the `@RoutePage` wrapper — the wrapper resolves its cubit from `get_it`, which a widget test should not need to boot.

`await tester.pumpAndSettle()` hangs forever on an indefinite animation such as a spinner. Use `await tester.pump()` or `pump(Duration(...))` when a loading indicator is on screen.

Golden tests are optional and not required by these conventions.

## Step 9 — Integration test (Patrol)

One file per feature in `integration_test/`, driving the real app on a real device or emulator: real DI, real navigation, real widgets, real backend. This is the only test that proves the assembled application works — and the only one that catches a layer wired to the wrong method, since every unit test above mocks its collaborators.

Integration tests use **Patrol**, not the `integration_test` package. Patrol runs through its own CLI, adds native automation (system permission dialogs, notifications, WebViews, device settings), and gives full isolation between tests.

```dart
// integration_test/staff_test.dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('user logs in, opens staff, and sees the list', ($) async {
    await createApp($);

    await $(WidgetKeys.emailField).enterText('test@example.com');
    await $(WidgetKeys.passwordField).enterText('password');
    await $(WidgetKeys.loginButton).tap();

    await $(WidgetKeys.staffTab).tap();

    expect($('Ada'), findsOneWidget);
  });
}
```

Patrol's finder (`$`) auto-waits for the widget to appear and settles after each action, so the `pumpAndSettle` calls a `testWidgets` version would need are unnecessary.

The app launcher differs from `main.dart` in three ways that will silently break tests if ignored:

```dart
// integration_test/helpers/app_launcher.dart
Future<void> createApp(PatrolIntegrationTester $) async {
  // NO WidgetsFlutterBinding.ensureInitialized()
  // NO runApp()
  // NO FlutterError.onError overrides (Crashlytics etc. swallow test failures)
  await initDependencies();
  await $.pumpWidgetAndSettle(const App());
}
```

Extract whatever `main.dart` and this helper share into a common function rather than letting the two drift apart.

Rules for this layer:

- **Point it at a staging backend, never production.**
- **Reset state between tests** — `await sl.reset()`, clear Hive boxes and prefs — or one test leaks into the next.
- **Keep the count low.** Happy paths for critical flows only. These are the slowest and flakiest tests you will own; a hundred of them get muted rather than fixed.
- **Assert on what the user can see**, not on internal state.
- **Never mock inside an integration test.** If a scenario needs a mock, it is a widget test.
- Reach for native automation (`$.platform...`) only when the flow genuinely crosses into the OS — a permission dialog, a notification, a WebView. Check the current Patrol docs for the exact API; it changed across major versions.

Running them:

```bash
patrol test                                  # all integration tests
patrol test -t integration_test/staff_test.dart
```

`flutter test` does not run these, so the unit and widget suite stays fast.

**Before writing a Patrol test, check whether Patrol's own agent skill is installed** (LeanCode ships maintained skills for writing Patrol tests). If it is, follow it for Patrol API specifics and treat this section as the project-level policy — what to test, where it lives, what to avoid — rather than as an API reference. Patrol's API moves faster than this file does.

## Test setup conventions

`test/` mirrors `lib/` exactly; nothing goes loose in the root of `test/`. Anything that is not a mirror of a `lib/` file belongs in `fixtures/` or `helpers/`:

```
test/
├── fixtures/
│   ├── fixture_reader.dart
│   └── staff_list.json
├── helpers/
│   ├── mocks.dart
│   ├── pump_app.dart
│   └── test_di.dart
├── config/
├── core/
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

integration_test/
├── helpers/
│   └── app_launcher.dart
├── auth_test.dart
└── staff_test.dart
```

Integration tests sit outside `test/` because Patrol runs them, not `flutter test`. Point Patrol at this directory with `test_directory: integration_test` in the `patrol` block of `pubspec.yaml`, and gitignore the generated `test_bundle.dart` along with `.patrol.env`.

The fixture reader:

```dart
// test/fixtures/fixture_reader.dart
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();
```

Shared mocks live in `test/helpers/mocks.dart` so the same `MockStaffApiService` is not redeclared in four files. Keep a mock there once a second test file needs it — not before.

Remaining conventions:

- **Mocking is `mocktail` only.** No `mockito`, no generated mocks, so tests never need `build_runner`. `MockCubit`, `MockBloc`, and `whenListen` come from `bloc_test`; `when`, `verify`, and `registerFallbackValue` come from `mocktail`.
- A test file under `test/` is named after the file it covers plus `_test`, at the same path. A test that maps to no `lib/` file belongs in `fixtures/`, `helpers/`, or `integration_test/` — otherwise it should not exist.
- Name tests after the behaviour, not the method: `'returns NetworkFailure when the network fails and the cache is empty'`, not `'test getStaff'`. The name is what a failing CI run shows you.
- One `group` per method under test.
- Prefix test data with `t` (`tStaff`, `tModel`) so it is distinguishable from production values at a glance.
- `registerFallbackValue` for any custom type used with `any()`; keep those calls in `test/helpers/mocks.dart` behind a single `registerFallbacks()` function.
- Reset `get_it` in `tearDown` for any test that touches it.

Run before pushing:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test                    # unit + widget
patrol test                     # integration; needs a device or emulator
```
