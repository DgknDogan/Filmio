import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/data/repositories/liked_series_repository_impl.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
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

class _MockBatch extends Mock implements WriteBatch {}

void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockDocument document;
  late _MockSnapshot snapshot;
  late _MockDocument likedDoc;
  late _MockBatch batch;
  late LikedSeriesRepositoryImpl repository;

  const series = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_MockDocument());
  });

  setUp(() {
    firestore = _MockFirestore();
    auth = _MockAuth();
    document = _MockDocument();
    snapshot = _MockSnapshot();
    likedDoc = _MockDocument();
    batch = _MockBatch();

    final user = _MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => auth.currentUser).thenReturn(user);

    final collection = _MockCollection();
    when(() => firestore.collection(any())).thenReturn(collection);
    when(() => collection.doc(any())).thenReturn(document);
    when(() => document.get()).thenAnswer((_) async => snapshot);
    when(() => document.update(any())).thenAnswer((_) async {});

    final likedCollection = _MockCollection();
    when(() => document.collection('LikedSeries')).thenReturn(likedCollection);
    when(() => likedCollection.doc(any())).thenReturn(likedDoc);
    when(() => firestore.batch()).thenReturn(batch);
    when(() => batch.commit()).thenAnswer((_) async {});

    repository = LikedSeriesRepositoryImpl(firestore, auth);
  });

  group('getLikedSeries', () {
    test('maps stored documents to entities', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn({
        'liked_series': [
          {'id': 1, 'name': 'A', 'poster_path': '/a.jpg', 'first_air_date': '2019-01-01'},
        ],
      });

      final liked = (await repository.getLikedSeries()).getRight().toNullable()!;

      expect(liked.single.id, 1);
      expect(liked.single.name, 'A');
      expect(liked.single.posterPath, '/a.jpg');
      expect(liked.single.firstAirDate, '2019-01-01');
    });

    test('reads liked_series, not the films the same document also carries', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn({
        'liked_movies': [
          {'id': 9, 'title': 'A film'},
        ],
        'liked_series': [
          {'id': 1, 'name': 'A series'},
        ],
      });

      final liked = (await repository.getLikedSeries()).getRight().toNullable()!;

      expect(liked.single.name, 'A series');
    });

    test('a user document with no liked_series key reads as an empty list', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn(<String, dynamic>{});

      expect((await repository.getLikedSeries()).getRight().toNullable(), isEmpty);
    });

    test('a missing user document is a Failure, not a crash', () async {
      when(() => snapshot.exists).thenReturn(false);
      when(snapshot.data).thenReturn(null);

      expect((await repository.getLikedSeries()).getLeft().toNullable(), isA<ServerFailure>());
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => document.get()).thenThrow(FirebaseException(plugin: 'Firestore', code: 'permission-denied'));

      expect((await repository.getLikedSeries()).getLeft().toNullable(), isA<AuthFailure>());
    });
  });

  group('likeSeries', () {
    test('writes under liked_series, leaving the films field alone', () async {
      await repository.likeSeries(series: series);

      final written = verify(() => batch.update(document, captureAny())).captured.single as Map<Object, Object?>;
      expect(written.keys.single, 'liked_series');
    });

    test('also writes LikedSeries/{id} holding only the id, in the same commit', () async {
      await repository.likeSeries(series: series);

      final collection = document.collection('LikedSeries');
      verify(() => collection.doc('1')).called(1);
      final written = verify(() => batch.set<Map<String, dynamic>>(likedDoc, captureAny())).captured.single;
      expect(written, {'id': 1});
      verify(() => batch.commit()).called(1);
      verifyNever(() => document.update(any()));
    });

    test('accepts a plain entity', () async {
      expect((await repository.likeSeries(series: series)).isRight(), isTrue);
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => batch.commit()).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect((await repository.likeSeries(series: series)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  test('dislikeSeries removes from the array and deletes LikedSeries/{id} in one commit', () async {
    await repository.dislikeSeries(series: series);

    verify(() => batch.update(document, any())).called(1);
    verify(() => batch.delete(likedDoc)).called(1);
    verify(() => batch.commit()).called(1);
  });
}
