import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/core/storage/firestore_title_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore_for_file: subtype_of_sealed_class
// cloud_firestore seals its reference types, but mocking them is the only way
// to test this without a live Firestore. This is the pattern the FlutterFire
// test suite itself uses, and the one the repository tests use.

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}

class _MockDocument extends Mock implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockTransaction extends Mock implements Transaction {}

Future<void> _noopHandler(Transaction transaction) async {}

/// Something to put in a list, standing in for a title without dragging a
/// generated model into a test about the mechanism.
class _Title {
  final int? id;
  final String name;

  const _Title(this.id, this.name);
}

void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockDocument document;
  late _MockSnapshot snapshot;
  late _MockTransaction transaction;

  const title = _Title(1, 'A');

  /// A list configured the way the watchlist is: no mirror, nothing to notify.
  FirestoreTitleList<_Title> listWith({String? mirrorCollection, Future<void> Function(String)? onChanged}) {
    return FirestoreTitleList<_Title>(
      firestore: firestore,
      auth: auth,
      field: 'watchlist_movies',
      mirrorCollection: mirrorCollection,
      idOf: (title) => title.id,
      toJson: (title) => {'id': title.id, 'name': title.name},
      fromJson: (json) => _Title(json['id'] as int?, json['name'] as String),
      signedOutMessage: 'Sign in to keep a watchlist.',
      onChanged: onChanged,
    );
  }

  List<Map<String, dynamic>> written() {
    final update = verify(() => transaction.update(document, captureAny())).captured.single as Map<Object, Object?>;
    expect(update.keys.single, 'watchlist_movies');

    return [for (final entry in update['watchlist_movies'] as List) Map<String, dynamic>.from(entry as Map)];
  }

  void stubStored(List<Map<String, dynamic>> entries) {
    when(() => snapshot.exists).thenReturn(true);
    when(snapshot.data).thenReturn({'watchlist_movies': entries});
  }

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Duration.zero);
    registerFallbackValue(_noopHandler);
    registerFallbackValue(_MockDocument());
  });

  setUp(() {
    firestore = _MockFirestore();
    auth = _MockAuth();
    document = _MockDocument();
    snapshot = _MockSnapshot();
    transaction = _MockTransaction();

    final user = _MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => auth.currentUser).thenReturn(user);

    final collection = _MockCollection();
    when(() => firestore.collection(any())).thenReturn(collection);
    when(() => collection.doc(any())).thenReturn(document);
    when(() => document.get()).thenAnswer((_) async => snapshot);

    when(() => transaction.get<Map<String, dynamic>>(document)).thenAnswer((_) async => snapshot);
    when(() => transaction.update(document, any())).thenReturn(transaction);
    when(
      () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
    ).thenAnswer((invocation) async {
      final handler = invocation.positionalArguments.first as TransactionHandler<void>;
      await handler(transaction);
    });

    stubStored(const []);
  });

  group('without a mirror', () {
    test('writes the array and touches no subcollection', () async {
      final list = listWith();

      final result = await list.write(title, include: true);

      expect(result.isRight(), isTrue);
      expect(written().single['id'], 1);
      // The liked lists keep a document-per-title projection for the
      // recommendation service. Nothing reads one of these, so building one
      // would be a second thing to keep correct for no reader.
      verifyNever(() => document.collection(any()));
    });

    test('takes a title back out without touching one either', () async {
      final list = listWith();
      stubStored(const [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ]);

      await list.write(title, include: false);

      expect(written().map((entry) => entry['id']), [2]);
      verifyNever(() => document.collection(any()));
    });
  });

  group('with nothing to notify', () {
    test('a write succeeds with no onChanged configured', () async {
      final list = listWith();

      expect((await list.write(title, include: true)).isRight(), isTrue);
    });

    test('onChanged runs with the signed-in user when there is one', () async {
      String? notified;
      final list = listWith(onChanged: (userId) async => notified = userId);

      await list.write(title, include: true);

      expect(notified, 'uid-1');
    });

    test('onChanged is left alone when the write failed', () async {
      String? notified;
      final list = listWith(onChanged: (userId) async => notified = userId);
      when(
        () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
      ).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      await list.write(title, include: true);

      expect(notified, isNull);
    });
  });

  group('signed out', () {
    test('says what this list in particular needs an account for', () async {
      final list = listWith();
      when(() => auth.currentUser).thenReturn(null);

      final readFailure = (await list.read()).getLeft().toNullable();
      final writeFailure = (await list.write(title, include: true)).getLeft().toNullable();

      expect(readFailure, isA<AuthFailure>());
      expect(readFailure!.message, 'Sign in to keep a watchlist.');
      expect(writeFailure, isA<AuthFailure>());
      expect(writeFailure!.message, 'Sign in to keep a watchlist.');
    });
  });

  group('reading', () {
    test('maps the stored entries through fromJson', () async {
      final list = listWith();
      stubStored(const [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ]);

      final titles = (await list.read()).getRight().toNullable()!;

      expect(titles.map((title) => title.name), ['A', 'B']);
    });

    test('reads a list that was never written as empty', () async {
      final list = listWith();
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn(<String, dynamic>{});

      expect((await list.read()).getRight().toNullable(), isEmpty);
    });
  });
}
