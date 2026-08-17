# Feature Walkthrough

One complete feature, start to finish, in the order the steps actually happen. Read this when starting a new feature — it shows how the rules in the other references compose. The example is `staff`: a list of employees fetched from the API, cached offline, with a detail screen.

Every file path below is real. Create them in this order.

## Contents

- [0. Scaffold](#0-scaffold)
- [1. Domain contracts — no tests](#1-domain-contracts--no-tests)
- [2. Model — test first](#2-model--test-first)
- [3. Datasources, then repository — repository test first](#3-datasources-then-repository--repository-test-first)
- [4. Use cases](#4-use-cases)
- [5. Cubit — test first](#5-cubit--test-first)
- [6. Registration and routing](#6-registration-and-routing)
- [7. UI — no tests during this step](#7-ui--no-tests-during-this-step)
- [8. Widget tests](#8-widget-tests)
- [9. Integration test](#9-integration-test)
- [Done checklist](#done-checklist)

---

## 0. Scaffold

```
lib/features/staff/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

No `wrapper_page.dart` here: staff has no nested routes of its own yet. Add one only when the feature grows a tab bar or a shared shell.

---

## 1. Domain contracts — no tests

`domain/entities/staff.dart`

```dart
class Staff extends Equatable {
  const Staff({required this.id, required this.name, this.avatarUrl});

  final String id;
  final String name;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
```

`domain/repositories/staff_repository.dart`

```dart
abstract interface class StaffRepository {
  Future<Either<Failure, List<Staff>>> getStaff({int page});
  Future<Either<Failure, Staff>> getStaffById(String id);
  Future<Either<Failure, Unit>> deleteStaff(String id);
}
```

Deciding these signatures is the design work. Nothing here imports Flutter, Dio, or Hive.

---

## 2. Model — test first

`test/fixtures/staff_list.json` — paste a real response from the API, not an invented one.

`test/features/staff/data/models/staff_model_test.dart`

```dart
void main() {
  test('maps snake_case keys and a null avatar', () {
    final json = jsonDecode(fixture('staff_list.json'))['data'][0]
        as Map<String, dynamic>;

    final model = StaffModel.fromJson(json);

    expect(model.id, '1');
    expect(model.fullName, 'Ada Lovelace');
    expect(model.avatarUrl, isNull);
    expect(model.toEntity(), const Staff(id: '1', name: 'Ada Lovelace'));
  });
}
```

Red. Now write it:

`data/models/staff_model.dart`

```dart
@JsonSerializable()
class StaffModel {
  const StaffModel({required this.id, required this.fullName, this.avatarUrl});

  factory StaffModel.fromJson(Map<String, dynamic> json) =>
      _$StaffModelFromJson(json);

  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$StaffModelToJson(this);

  Staff toEntity() => Staff(id: id, name: fullName, avatarUrl: avatarUrl);
}
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

Green.

---

## 3. Datasources, then repository — repository test first

The Retrofit service gets **no test** — its body is generated.

`data/datasources/staff_api_service.dart`

```dart
part 'staff_api_service.g.dart';

@RestApi()
abstract class StaffApiService {
  factory StaffApiService(Dio dio, {String baseUrl}) = _StaffApiService;

  @GET('/staff')
  Future<List<StaffModel>> getStaff({@Query('page') int page = 1});

  @GET('/staff/{id}')
  Future<StaffModel> getStaffById(@Path('id') String id);

  @DELETE('/staff/{id}')
  Future<void> deleteStaff(@Path('id') String id);
}
```

`data/datasources/staff_local_data_source.dart` — Hive, because a cached list is large and non-critical.

```dart
class StaffLocalDataSource {
  const StaffLocalDataSource(this._box);

  final Box<StaffModel> _box;

  Future<void> cacheStaff(List<StaffModel> staff) async {
    await _box.clear();
    await _box.addAll(staff);
  }

  Future<List<StaffModel>> getCachedStaff() async => _box.values.toList();
}
```

Now the repository test, before the repository:

`test/features/staff/data/repositories/staff_repository_impl_test.dart`

```dart
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

  DioException offline() => DioException(
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

  test('falls back to the cache when offline', () async {
    when(() => api.getStaff(page: 1)).thenThrow(offline());
    when(() => local.getCachedStaff()).thenAnswer((_) async => [tModel]);

    expect((await repository.getStaff()).isRight(), isTrue);
  });

  test('returns NetworkFailure when offline with an empty cache', () async {
    when(() => api.getStaff(page: 1)).thenThrow(offline());
    when(() => local.getCachedStaff()).thenAnswer((_) async => []);

    expect(await repository.getStaff(), const Left(NetworkFailure()));
  });
}
```

Red. Then:

`data/repositories/staff_repository_impl.dart`

```dart
class StaffRepositoryImpl implements StaffRepository {
  const StaffRepositoryImpl(this._api, this._local);

  final StaffApiService _api;
  final StaffLocalDataSource _local;

  @override
  Future<Either<Failure, List<Staff>>> getStaff({int page = 1}) async {
    try {
      final models = await _api.getStaff(page: page);
      await _local.cacheStaff(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final cached = await _local.getCachedStaff();
      if (cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // getStaffById, deleteStaff — same shape.
}
```

Green. This is the only layer that knows `DioException` exists.

---

## 4. Use cases

`GetStaff` and `GetStaffById` forward straight through, so they get **no tests**. `DeleteStaff` validates, so it does:

`test/features/staff/domain/usecases/delete_staff_test.dart`

```dart
test('rejects a blank id without calling the repository', () async {
  final result = await deleteStaff('');

  expect(result, const Left(ValidationFailure('Id is required.')));
  verifyNever(() => repository.deleteStaff(any()));
});
```

---

## 5. Cubit — test first

Write the state sequence before the cubit exists. This is where the state model gets designed, with no layout to bias it.

`test/features/staff/presentation/cubit/staff_cubit_test.dart`

```dart
blocTest<StaffCubit, StaffState>(
  'emits [Loading, Loaded] on success',
  build: () {
    when(() => getStaff()).thenAnswer((_) async => const Right(tStaff));
    return StaffCubit(getStaff, deleteStaff);
  },
  act: (cubit) => cubit.load(),
  expect: () => const [StaffLoading(), StaffLoaded(tStaff)],
);

blocTest<StaffCubit, StaffState>(
  'emits [Loading, Error] on failure',
  build: () {
    when(() => getStaff()).thenAnswer((_) async => const Left(NetworkFailure()));
    return StaffCubit(getStaff, deleteStaff);
  },
  act: (cubit) => cubit.load(),
  expect: () => [const StaffLoading(), isA<StaffError>()],
);
```

Red. Then the state and the cubit:

`presentation/cubit/staff_state.dart` — sealed, one class per situation, `Equatable` for value equality.

`presentation/cubit/staff_cubit.dart`

```dart
class StaffCubit extends Cubit<StaffState> {
  StaffCubit(this._getStaff, this._deleteStaff) : super(const StaffInitial());

  final GetStaff _getStaff;
  final DeleteStaff _deleteStaff;

  Future<void> load() async {
    emit(const StaffLoading());
    final result = await _getStaff();
    if (isClosed) return;
    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (staff) => emit(StaffLoaded(staff)),
    );
  }
}
```

Green. Cubit, not Bloc: no ordering or debounce requirement here.

---

## 6. Registration and routing

`injection_container.dart` — outer to inner, cubit as a factory:

```dart
// ---- Staff ----
sl.registerLazySingleton(() => StaffApiService(sl()));
sl.registerLazySingleton(() => StaffLocalDataSource(sl()));
sl.registerLazySingleton<StaffRepository>(() => StaffRepositoryImpl(sl(), sl()));
sl.registerLazySingleton(() => GetStaff(sl()));
sl.registerLazySingleton(() => DeleteStaff(sl()));
sl.registerFactory(() => StaffCubit(sl(), sl()));
```

The Hive box is opened once during startup, in the external section.

`config/router/app_router.dart` — add the routes; the classes appear after `build_runner` runs.

```dart
AutoRoute(page: StaffRoute.page),
AutoRoute(page: StaffDetailRoute.page),
```

---

## 7. UI — no tests during this step

`presentation/pages/staff_page.dart` — the page creates the provider, an inner view consumes it. Provider at page level, because staff does not share a cubit with sibling tabs.

```dart
@RoutePage()
class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaffCubit>()..load(),
      child: const StaffView(),
    );
  }
}

class StaffView extends StatelessWidget {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.staffTitle)),
      body: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state is StaffError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => switch (state) {
          StaffInitial() || StaffLoading() =>
            const Center(child: CircularProgressIndicator()),
          StaffLoaded(:final staff) => StaffList(staff: staff),
          StaffError(:final message) => AppErrorView(
              message: message,
              onRetry: () => context.read<StaffCubit>().load(),
            ),
        },
      ),
    );
  }
}
```

`presentation/widgets/staff_tile.dart` — every visual value comes from the theme, the avatar from `AppNetworkImage`, the fallback from `Assets.*`, the text from `context.l10n`:

```dart
class StaffTile extends StatelessWidget {
  const StaffTile({required this.staff, super.key});

  final Staff staff;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations(context.palette).card,
      padding: AppInsets.card,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: staff.avatarUrl == null
                ? Assets.images.avatarPlaceholder.image(width: 48, height: 48)
                : AppNetworkImage(url: staff.avatarUrl!, width: 48, height: 48),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(staff.name, style: context.textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
```

New strings go into `app_en.arb` and every other `.arb`, then `flutter gen-l10n`.

---

## 8. Widget tests

Now that the UI exists, lock in its behaviour. Mock the cubit, pump the *view* rather than the `@RoutePage` wrapper.

```dart
testWidgets('shows the list once loaded', (tester) async {
  when(() => cubit.state).thenReturn(const StaffLoaded(tStaff));

  await tester.pumpApp(
    BlocProvider<StaffCubit>.value(value: cubit, child: const StaffView()),
  );

  expect(find.text('Ada'), findsOneWidget);
});

testWidgets('retry calls load()', (tester) async {
  when(() => cubit.state).thenReturn(const StaffError('boom'));
  when(() => cubit.load()).thenAnswer((_) async {});

  await tester.pumpApp(
    BlocProvider<StaffCubit>.value(value: cubit, child: const StaffView()),
  );
  await tester.tap(find.byKey(WidgetKeys.staffRetryButton));

  verify(() => cubit.load()).called(1);
});
```

One test per renderable state, one per interaction. Nothing about padding or colour.

---

## 9. Integration test

`integration_test/staff_test.dart` — the real app, on a device, against staging.

```dart
void main() {
  patrolTest('user opens staff and sees the list', ($) async {
    await createApp($);

    await $(WidgetKeys.staffTab).tap();

    expect($('Ada'), findsOneWidget);
  });
}
```

```bash
patrol test -t integration_test/staff_test.dart
```

---

## Done checklist

- [ ] `flutter analyze` clean, `dart format .` applied
- [ ] `flutter test` green — model, repository, cubit, widget
- [ ] `patrol test` green for the feature's flow
- [ ] No string asset paths, no `Image.network`, no hardcoded text, no `Color(0x…)` outside `app_colors.dart`, no bare numbers in `EdgeInsets`
- [ ] Screen checked in both light and dark
- [ ] Generated files committed
