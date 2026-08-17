import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/features/landing/presentation/cubit/splash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockRestoreSessionUseCase restoreSession;

  setUp(() => restoreSession = MockRestoreSessionUseCase());

  SplashCubit build() => SplashCubit(restoreSession);

  blocTest<SplashCubit, SplashState>(
    'a restorable session sends the user into the app',
    build: build,
    setUp: () => when(() => restoreSession.call()).thenAnswer((_) async => true),
    act: (cubit) => cubit.resolveDestination(),
    expect: () => const [SplashAuthenticated()],
  );

  blocTest<SplashCubit, SplashState>(
    'no session means the login screen',
    build: build,
    setUp: () => when(() => restoreSession.call()).thenAnswer((_) async => false),
    act: (cubit) => cubit.resolveDestination(),
    expect: () => const [SplashUnauthenticated()],
  );
}
