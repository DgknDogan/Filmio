import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLogoutUseCase logoutUseCase;
  late MockDeleteAccountUseCase deleteAccountUseCase;

  const password = 'hunter22';

  setUp(() {
    logoutUseCase = MockLogoutUseCase();
    deleteAccountUseCase = MockDeleteAccountUseCase();
  });

  SettingsCubit build() => SettingsCubit(logoutUseCase, deleteAccountUseCase);

  group('logout', () {
    blocTest<SettingsCubit, SettingsState>(
      'reports it is working, then that the session is over',
      setUp: () => when(() => logoutUseCase.call()).thenAnswer((_) async {}),
      build: build,
      act: (cubit) => cubit.logout(),
      expect: () => const [SettingsSigningOut(), SettingsSignedOut()],
    );
  });

  group('deleteAccount', () {
    blocTest<SettingsCubit, SettingsState>(
      'passes the password through and announces the account is gone',
      setUp: () => when(() => deleteAccountUseCase.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit)),
      build: build,
      act: (cubit) => cubit.deleteAccount(password),
      expect: () => const [SettingsDeletingAccount(), SettingsAccountDeleted()],
      verify: (_) => verify(() => deleteAccountUseCase.call(params: password)).called(1),
    );

    blocTest<SettingsCubit, SettingsState>(
      'surfaces the failure message so the screen can announce it',
      setUp: () =>
          when(() => deleteAccountUseCase.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(AuthFailure('Wrong e-mail or password.'))),
      build: build,
      act: (cubit) => cubit.deleteAccount('not-the-password'),
      expect: () => const [SettingsDeletingAccount(), SettingsDeleteFailed('Wrong e-mail or password.')],
    );
  });
}
