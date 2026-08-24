import 'package:filmio/core/constants/constants.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseFirestore firestore;
  late MockAuthLocalDataSource localDataSource;
  late MockUser user;
  late MockCollectionReference collection;
  late MockDocumentReference userDoc;
  late AuthRepositoryImpl repository;

  const uid = 'uid-1';
  const email = 'reader@filmio.app';
  const password = 'hunter22';

  setUpAll(registerCommonFallbacks);

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    localDataSource = MockAuthLocalDataSource();
    user = MockUser();
    collection = MockCollectionReference();
    userDoc = MockDocumentReference();
    repository = AuthRepositoryImpl(localDataSource, auth, firestore);

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    when(() => firestore.collection(userCollection)).thenReturn(collection);
    when(() => collection.doc(uid)).thenReturn(userDoc);
    when(() => user.reauthenticateWithCredential(any())).thenAnswer((_) async => MockUserCredential());
    when(() => userDoc.delete()).thenAnswer((_) async {});
    when(() => user.delete()).thenAnswer((_) async {});
    when(() => localDataSource.clearRemembered()).thenAnswer((_) async {});
  });

  group('the guest session', () {
    setUp(() {
      when(() => localDataSource.setGuest(any())).thenAnswer((_) async {});
      when(() => localDataSource.clearGuest()).thenAnswer((_) async {});
      when(() => localDataSource.clearRemembered()).thenAnswer((_) async {});
      when(() => localDataSource.setRemembered(any())).thenAnswer((_) async {});
      when(() => auth.signOut()).thenAnswer((_) async {});
    });

    test('is a flag on this device and nothing on the server', () async {
      await repository.continueAsGuest();

      verify(() => localDataSource.setGuest(true)).called(1);
      verifyNever(() => firestore.collection(any()));
    });

    test('drops any Firebase session still open underneath', () async {
      await repository.continueAsGuest();

      // Otherwise a reader who signed in once, then chose to look around as a
      // guest, would still be carrying that account into every request.
      verifyInOrder([
        () => auth.signOut(),
        () => localDataSource.clearRemembered(),
        () => localDataSource.setGuest(true),
      ]);
    });

    test('ends when somebody signs in', () async {
      final credential = MockUserCredential();
      when(() => credential.user).thenReturn(user);
      when(() => auth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password'))).thenAnswer((_) async => credential);

      await repository.login(email: email, password: password, rememberMe: true);

      verify(() => localDataSource.clearGuest()).called(1);
    });

    test('ends on the way out, so the next launch asks again', () async {
      await repository.logout();

      verify(() => localDataSource.clearGuest()).called(1);
    });
  });

  group('deleteAccount', () {
    test('re-authenticates, then removes the stored data before the account itself', () async {
      final result = await repository.deleteAccount(password: password);

      expect(result, const Right<Failure, Unit>(unit));

      // Order is the point: the document has to go while its owner still
      // exists, otherwise the security rules lock it away for good.
      verifyInOrder([
        () => user.reauthenticateWithCredential(any()),
        () => userDoc.delete(),
        () => user.delete(),
        () => localDataSource.clearRemembered(),
      ]);
    });

    test('fails without touching anything when nobody is signed in', () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await repository.deleteAccount(password: password);

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<AuthFailure>()), (_) => fail('expected a failure'));
      verifyNever(() => userDoc.delete());
      verifyNever(() => user.delete());
    });

    test('leaves the data in place when the password is wrong', () async {
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'wrong-password'),
      );

      final result = await repository.deleteAccount(password: 'not-the-password');

      result.fold(
        (failure) => expect(failure.message, 'Wrong e-mail or password.'),
        (_) => fail('expected a failure'),
      );
      verifyNever(() => userDoc.delete());
      verifyNever(() => user.delete());
      verifyNever(() => localDataSource.clearRemembered());
    });

    test('reports a Firestore failure rather than deleting the account anyway', () async {
      when(() => userDoc.delete()).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      final result = await repository.deleteAccount(password: password);

      expect(result.isLeft(), isTrue);
      verifyNever(() => user.delete());
    });

    test('keeps the remembered flag when the account itself cannot be deleted', () async {
      when(() => user.delete()).thenThrow(
        FirebaseAuthException(code: 'requires-recent-login'),
      );

      final result = await repository.deleteAccount(password: password);

      expect(result.isLeft(), isTrue);
      verifyNever(() => localDataSource.clearRemembered());
    });
  });
}
