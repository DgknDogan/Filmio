import 'package:filmio/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// The splash screen's only question, and it has three inputs — so it is the
/// kind of use case that earns a test of its own.
void main() {
  late MockAuthRepository repository;
  late RestoreSessionUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = RestoreSessionUseCase(repository);

    when(() => repository.isGuest).thenReturn(false);
    when(() => repository.isRemembered).thenReturn(false);
    when(() => repository.hasActiveSession).thenReturn(false);
  });

  test('a guest goes straight in, with no account to verify', () async {
    when(() => repository.isGuest).thenReturn(true);

    expect(await useCase.call(), isTrue);
    verifyNever(() => repository.hasActiveSession);
  });

  test('a remembered account with a live session goes straight in', () async {
    when(() => repository.isRemembered).thenReturn(true);
    when(() => repository.hasActiveSession).thenReturn(true);

    expect(await useCase.call(), isTrue);
  });

  test('a live session nobody asked to remember still signs in again', () async {
    when(() => repository.hasActiveSession).thenReturn(true);

    expect(await useCase.call(), isFalse);
  });

  test('nothing stored means the sign-in screen', () async {
    expect(await useCase.call(), isFalse);
  });
}
