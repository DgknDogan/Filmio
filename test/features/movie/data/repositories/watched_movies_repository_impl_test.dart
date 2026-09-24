import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/data/repositories/watched_movies_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore_for_file: subtype_of_sealed_class
// cloud_firestore seals its reference types, but mocking them is the only way
// to test a repository without a live Firestore. This is the pattern the
// FlutterFire test suite itself uses.

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}

class _MockDocument extends Mock implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDocument extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

_MockQueryDocument _stored(String id, Map<String, dynamic> data) {
  final doc = _MockQueryDocument();
  when(() => doc.id).thenReturn(id);
  when(doc.data).thenReturn(data);
  return doc;
}

void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockCollection users;
  late _MockDocument userDoc;
  late _MockCollection watched;
  late _MockDocument entry;
  late _MockQuery ordered;
  late WatchedMoviesRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    firestore = _MockFirestore();
    auth = _MockAuth();
    users = _MockCollection();
    userDoc = _MockDocument();
    watched = _MockCollection();
    entry = _MockDocument();
    ordered = _MockQuery();

    final user = _MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => auth.currentUser).thenReturn(user);

    when(() => firestore.collection('User')).thenReturn(users);
    when(() => users.doc('uid-1')).thenReturn(userDoc);
    when(() => userDoc.collection('WatchedMovies')).thenReturn(watched);
    when(() => watched.doc(any())).thenReturn(entry);
    when(() => watched.orderBy(any(), descending: any(named: 'descending'))).thenReturn(ordered);
    when(() => entry.set(any())).thenAnswer((_) async {});
    when(() => entry.delete()).thenAnswer((_) async {});

    repository = WatchedMoviesRepositoryImpl(firestore, auth);
  });

  group('getWatchedMovieIds', () {
    test('reads the ids newest first, as the query returns them', () async {
      final snapshot = _MockQuerySnapshot();
      when(() => ordered.get()).thenAnswer((_) async => snapshot);
      final docs = [
        _stored('3', {'id': 3}),
        _stored('1', {'id': 1})
      ];
      when(() => snapshot.docs).thenReturn(docs);

      final ids = (await repository.getWatchedMovieIds()).getRight().toNullable();

      expect(ids, [3, 1]);
      verify(() => watched.orderBy('timestamp', descending: true)).called(1);
    });

    test('skips a record that carries no usable id', () async {
      final snapshot = _MockQuerySnapshot();
      when(() => ordered.get()).thenAnswer((_) async => snapshot);
      final docs = [
        _stored('junk', const {}),
        _stored('2', {'id': 2})
      ];
      when(() => snapshot.docs).thenReturn(docs);

      expect((await repository.getWatchedMovieIds()).getRight().toNullable(), [2]);
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => ordered.get()).thenThrow(FirebaseException(plugin: 'Firestore', code: 'permission-denied'));

      expect((await repository.getWatchedMovieIds()).getLeft().toNullable(), isA<AuthFailure>());
    });
  });

  group('isMovieWatched', () {
    test('is true exactly when the record exists', () async {
      final snapshot = _MockSnapshot();
      when(() => entry.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.exists).thenReturn(true);

      expect((await repository.isMovieWatched(movieId: 42)).getRight().toNullable(), isTrue);
      verify(() => watched.doc('42')).called(1);
    });

    test('is false when there is no record', () async {
      final snapshot = _MockSnapshot();
      when(() => entry.get()).thenAnswer((_) async => snapshot);
      when(() => snapshot.exists).thenReturn(false);

      expect((await repository.isMovieWatched(movieId: 42)).getRight().toNullable(), isFalse);
    });
  });

  group('addWatchedMovie', () {
    test('writes the id and a server timestamp under the id itself', () async {
      final result = await repository.addWatchedMovie(movieId: 42);

      expect(result.isRight(), isTrue);
      verify(() => watched.doc('42')).called(1);
      final written = verify(() => entry.set(captureAny())).captured.single as Map<String, dynamic>;
      expect(written['id'], 42);
      expect(written['timestamp'], FieldValue.serverTimestamp());
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => entry.set(any())).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect((await repository.addWatchedMovie(movieId: 42)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  test('removeWatchedMovie deletes the record under the id', () async {
    final result = await repository.removeWatchedMovie(movieId: 42);

    expect(result.isRight(), isTrue);
    verify(() => watched.doc('42')).called(1);
    verify(() => entry.delete()).called(1);
  });

  test('with nobody signed in every call fails without touching Firestore', () async {
    when(() => auth.currentUser).thenReturn(null);

    expect((await repository.getWatchedMovieIds()).getLeft().toNullable(), isA<AuthFailure>());
    expect((await repository.isMovieWatched(movieId: 1)).getLeft().toNullable(), isA<AuthFailure>());
    expect((await repository.addWatchedMovie(movieId: 1)).getLeft().toNullable(), isA<AuthFailure>());
    expect((await repository.removeWatchedMovie(movieId: 1)).getLeft().toNullable(), isA<AuthFailure>());
    verifyNever(() => firestore.collection(any()));
  });
}
