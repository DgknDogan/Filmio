import 'package:filmio/injection_container.dart';

/// Pages resolve their cubit's dependencies from `get_it`, so a widget test has
/// to stand that container up with mocks first.
///
/// Call [registerTestSingleton] in `setUp` and [resetTestDependencies] in
/// `tearDown`, or `get_it` leaks registrations between tests.
void registerTestSingleton<T extends Object>(T instance) {
  if (getIt.isRegistered<T>()) getIt.unregister<T>();
  getIt.registerSingleton<T>(instance);
}

Future<void> resetTestDependencies() => getIt.reset();
