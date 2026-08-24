import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/auth/domain/usecases/login.dart';
import 'package:filmio/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLoginUseCase login;
  late MockIsProfileCompleteUseCase isProfileComplete;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    login = MockLoginUseCase();
    isProfileComplete = MockIsProfileCompleteUseCase();
    when(() => login.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
    when(() => isProfileComplete.call()).thenAnswer((_) async => true);
  });

  LoginCubit build() => LoginCubit(login, isProfileComplete);

  test('an empty field never reaches the network and says so', () async {
    final cubit = build();

    final outcome = await cubit.login(email: '', password: 'x');

    expect(outcome, LoginOutcome.failed);
    expect(cubit.state.errorMessage, isNotNull);
    verifyNever(() => login.call(params: any(named: 'params')));
  });

  test('a rejected credential surfaces the mapped message', () async {
    when(() => login.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(AuthFailure('Wrong e-mail or password.', code: 'wrong-password')));
    final cubit = build();

    final outcome = await cubit.login(email: 'a@b.c', password: 'x');

    expect(outcome, LoginOutcome.failed);
    expect(cubit.state.errorMessage, 'Wrong e-mail or password.');
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a signed-in user with no display name is sent to profile setup', () async {
    when(() => isProfileComplete.call()).thenAnswer((_) async => false);

    expect(await build().login(email: 'a@b.c', password: 'x'), LoginOutcome.needsProfile);
  });

  test('a signed-in user with a profile goes straight to the app', () async {
    expect(await build().login(email: 'a@b.c', password: 'x'), LoginOutcome.ready);
  });

  test('the remember-me checkbox is passed through to the use case', () async {
    final cubit = build()..changeCheckBox(true);

    await cubit.login(email: 'a@b.c', password: 'x');

    final params = verify(() => login.call(params: captureAny(named: 'params'))).captured.single as LoginParams;
    expect(params.rememberMe, isTrue);
  });

  blocTest<LoginCubit, LoginState>(
    'ticking the checkbox is the only thing that changes',
    build: build,
    act: (cubit) => cubit.changeCheckBox(true),
    expect: () => const [LoginState(isChecked: true)],
  );
}
