import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/cubit/session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockIsGuestUseCase isGuest;
  late MockContinueAsGuestUseCase continueAsGuest;
  late MockEndGuestSessionUseCase endGuestSession;

  setUp(() {
    isGuest = MockIsGuestUseCase();
    continueAsGuest = MockContinueAsGuestUseCase();
    endGuestSession = MockEndGuestSessionUseCase();

    when(() => isGuest.call()).thenAnswer((_) async => false);
    when(() => continueAsGuest.call()).thenAnswer((_) async {});
    when(() => endGuestSession.call()).thenAnswer((_) async {});
  });

  SessionCubit build() => SessionCubit(isGuest, continueAsGuest, endGuestSession);

  blocTest<SessionCubit, SessionState>(
    'reads the stored flag on the way in',
    setUp: () => when(() => isGuest.call()).thenAnswer((_) async => true),
    build: build,
    expect: () => const [SessionState(isGuest: true)],
  );

  blocTest<SessionCubit, SessionState>(
    'starting a guest session says so without re-reading the flag',
    build: build,
    act: (cubit) => cubit.startGuestSession(),
    skip: 1,
    expect: () => const [SessionState(isGuest: true)],
    verify: (_) => verify(() => continueAsGuest.call()).called(1),
  );

  blocTest<SessionCubit, SessionState>(
    'ending a guest session clears it',
    setUp: () => when(() => isGuest.call()).thenAnswer((_) async => true),
    build: build,
    act: (cubit) => cubit.endGuestSession(),
    expect: () => const [SessionState(isGuest: true), SessionState()],
    verify: (_) => verify(() => endGuestSession.call()).called(1),
  );

  blocTest<SessionCubit, SessionState>(
    'refreshing picks up a sign-in that happened elsewhere',
    setUp: () => when(() => isGuest.call()).thenAnswer((_) async => true),
    build: build,
    act: (cubit) async {
      when(() => isGuest.call()).thenAnswer((_) async => false);
      await cubit.refresh();
    },
    expect: () => const [SessionState(isGuest: true), SessionState()],
  );
}
