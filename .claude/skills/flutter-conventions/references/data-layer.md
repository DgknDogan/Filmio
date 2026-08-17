# Data Layer

Read this when defining an API service, writing a repository, mapping errors, adding local storage, or registering dependencies.

## Contents

- [Retrofit service](#retrofit-service)
- [Dio setup](#dio-setup)
- [Models and entities](#models-and-entities)
- [Failure types](#failure-types)
- [Repository implementation](#repository-implementation)
- [Use cases](#use-cases)
- [Local storage](#local-storage)
- [Firebase](#firebase)
- [Dependency injection](#dependency-injection)

---

## Retrofit service

One service per feature, in `features/<feature>/data/datasources/`. Methods return models, never entities — mapping happens in the repository.

```dart
// features/staff/data/datasources/staff_api_service.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'staff_api_service.g.dart';

@RestApi()
abstract class StaffApiService {
  factory StaffApiService(Dio dio, {String baseUrl}) = _StaffApiService;

  @GET('/staff')
  Future<List<StaffModel>> getStaff({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @GET('/staff/{id}')
  Future<StaffModel> getStaffById(@Path('id') String id);

  @POST('/staff')
  Future<StaffModel> createStaff(@Body() StaffModel body);

  @DELETE('/staff/{id}')
  Future<void> deleteStaff(@Path('id') String id);
}
```

The `part` directive and the `_StaffApiService` reference will not resolve until `build_runner` runs. That is expected — do not try to write the `.g.dart` by hand.

Keep endpoint paths in the annotations, not scattered as string constants elsewhere. `baseUrl` comes from the Dio instance configured in DI, so services stay environment-agnostic.

## Dio setup

A single configured `Dio` is registered in `injection_container.dart` and injected into every service:

```dart
Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(sl()),     // attaches the bearer token
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
}
```

Cross-cutting concerns — auth headers, token refresh, retries, logging — belong in interceptors, not repeated in every service or repository.

## Models and entities

Models carry serialization and live in `data/models/`; entities are plain Dart in `domain/entities/`. The model owns the conversion:

```dart
// features/staff/data/models/staff_model.dart
@JsonSerializable()
class StaffModel {
  const StaffModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

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

This is the one place a backend field rename has to be handled. Never let `@JsonKey` or snake_case API naming reach the domain or the UI.

## Failure types

In `core/resource/`:

```dart
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
```

`ValidationFailure` is the one a use case produces on its own, before any I/O happens — a blank id, a malformed date. Everything else originates in `data/`.

Mapping lives next to it so every repository produces consistent messages:

```dart
Failure mapDioException(DioException e) => switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const NetworkFailure(),
      DioExceptionType.badResponse => ServerFailure(
          _messageFromResponse(e.response),
          statusCode: e.response?.statusCode,
        ),
      DioExceptionType.cancel => const UnexpectedFailure('Request cancelled.'),
      _ => const UnexpectedFailure(),
    };
```

Putting the user-facing text on `Failure` keeps the same error from being worded three different ways on three screens. If a screen needs bespoke copy, override it in that cubit.

## Repository implementation

The contract sits in `domain/repositories/` and returns `Either`:

```dart
abstract interface class StaffRepository {
  Future<Either<Failure, List<Staff>>> getStaff({int page});
  Future<Either<Failure, Unit>> deleteStaff(String id);
}
```

The implementation is the only place exceptions are caught:

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

  @override
  Future<Either<Failure, Unit>> deleteStaff(String id) async {
    try {
      await _api.deleteStaff(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    }
  }
}
```

Use `Unit` / `unit` from fpdart for void successes rather than `Either<Failure, void>`, which is awkward to match on.

## Use cases

Base contract in `core/usecase/`:

```dart
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

final class NoParams {
  const NoParams();
}
```

An implementation stays thin — it exists so the cubit depends on one narrow capability instead of a whole repository:

```dart
class GetStaff implements UseCase<List<Staff>, NoParams> {
  const GetStaff(this._repository);

  final StaffRepository _repository;

  @override
  Future<Either<Failure, List<Staff>>> call([NoParams params = const NoParams()]) =>
      _repository.getStaff();
}
```

## Local storage

The rule is size, not importance — sensitive data belongs in neither of these.

**`shared_preferences` — small, non-critical values:** feature flags, onboarding seen, last selected tab, theme mode, locale.

```dart
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';

  ThemeMode get themeMode =>
      ThemeMode.values.byName(_prefs.getString(_kThemeMode) ?? 'system');

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);
}
```

**`flutter_secure_storage` — credentials.** Auth tokens never touch prefs or Hive. One `TokenManager` in `core/storage/`, and nothing else reads the storage directly:

```dart
// core/storage/token_manager.dart
class TokenManager {
  const TokenManager(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
```

`AuthInterceptor` reads from it to attach the bearer header and to drive refresh on a 401; the auth repository writes to it after login and clears it on logout. A cubit never holds a token in a field, and a token never appears in a state class — states get serialised into logs and error reports.

**`hive` — large, non-critical data:** cached list responses, offline snapshots, drafts.

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

Keep keys as private `static const` strings on the datasource, and open Hive boxes once during startup — not lazily inside methods, which makes failures surface at random points in the UI. Widgets and cubits must never call `SharedPreferences.getInstance()` or `Hive.box()` directly; going through a datasource is what lets the storage choice change without touching the UI.

## Firebase

Firebase Auth, Storage, and Firestore are already service abstractions with their own interfaces. Call them **directly in the repository implementation** — an extra datasource that only forwards `FirebaseAuth.instance.signIn…` adds a file and no seam.

```dart
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._auth, this._tokens);

  final FirebaseAuth _auth;
  final TokenManager _tokens;

  @override
  Future<Either<Failure, Unit>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await credential.user?.getIdToken();
      if (token == null) return const Left(UnexpectedFailure());
      await _tokens.save(access: token, refresh: credential.user!.refreshToken!);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(mapFirebaseAuthError(e)); // lives in core/resource, beside mapDioException
    }
  }
}
```

What still holds: `FirebaseAuthException` is caught here and mapped to a `Failure`, and no Firebase type ever reaches `domain/` or a widget. Register the Firebase instance in `injection_container.dart` and inject it, rather than reaching for `.instance` inside the repository — that is what keeps the repository testable with a mocked Firebase interface.

## Dependency injection

`injection_container.dart` at the `lib/` root, grouped by feature, registered outer → inner:

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---- External ----
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  await Hive.initFlutter();
  Hive.registerAdapter(StaffModelAdapter());
  sl.registerSingleton<Box<StaffModel>>(await Hive.openBox('staff'));

  sl.registerLazySingleton<Dio>(buildDio);
  sl.registerLazySingleton<AppRouter>(AppRouter.new);

  // ---- Staff ----
  sl.registerLazySingleton(() => StaffApiService(sl()));
  sl.registerLazySingleton(() => StaffLocalDataSource(sl()));
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetStaff(sl()));
  sl.registerLazySingleton(() => DeleteStaff(sl()));
  sl.registerFactory(() => StaffCubit(sl(), sl()));
}
```

- Anything needing `await` uses `registerSingleton` after the await, or `registerSingletonAsync`.
- Repositories, datasources, and use cases are `registerLazySingleton` — stateless and cheap to keep.
- Cubits and blocs are always `registerFactory`. A singleton cubit returns stale state when the user re-enters a screen.
- Register the abstract type (`sl.registerLazySingleton<StaffRepository>`), not the implementation, so consumers depend on the contract.
- Call `initDependencies()` in `main.dart` before `runApp`.
