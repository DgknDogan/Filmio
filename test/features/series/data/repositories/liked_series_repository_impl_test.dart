import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/data/repositories/liked_series_repository_impl.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/core/storage/liked_titles_stamp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _MockTransaction extends Mock implements Transaction {}

/// Typed so the fallback mocktail registers is the handler's own type, not the
/// closure literal's.
Future<void> _noopHandler(Transaction transaction) async {}

void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockDocument document;
  late _MockSnapshot snapshot;
  late _MockTransaction transaction;
  late LikedTitlesStamp likes;
  late LikedSeriesRepositoryImpl repository;

  const series = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');

  /// The same series as the list endpoint described it a week ago: same id,
  /// different everything else. This is what used to defeat `arrayUnion` and
  /// `arrayRemove`, and is the reason the id is what counts.
  const staleEntry = {'id': 1, 'name': 'A', 'poster_path': '/a.jpg', 'popularity': 44.1, 'vote_count': 900};
  const otherEntry = {'id': 2, 'name': 'B', 'poster_path': '/b.jpg'};

  /// What the array was rewritten to, whichever call did the rewriting.
  List<Map<String, dynamic>> written() {
    final update = verify(() => transaction.update(document, captureAny())).captured.single as Map<Object, Object?>;
    expect(update.keys.single, 'liked_series');

    return [for (final entry in update['liked_series'] as List) Map<String, dynamic>.from(entry as Map)];
  }

  void stubStored(List<Map<String, dynamic>> entries) {
    when(() => snapshot.exists).thenReturn(true);
    when(snapshot.data).thenReturn({'liked_series': entries});
  }

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Duration.zero);
    registerFallbackValue(_noopHandler);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    likes = LikedTitlesStamp(await SharedPreferences.getInstance());

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

    // The list is read and written in one transaction, so the handler is run
    // here against a transaction that reads the stubbed snapshot.
    when(() => transaction.get<Map<String, dynamic>>(document)).thenAnswer((_) async => snapshot);
    when(() => transaction.update(document, any())).thenReturn(transaction);
    when(
      () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
    ).thenAnswer((invocation) async {
      final handler = invocation.positionalArguments.first as TransactionHandler<void>;
      await handler(transaction);
    });

    stubStored(const []);

    repository = LikedSeriesRepositoryImpl(firestore, auth, likes);
  });

  group('getLikedSeries', () {
    test('maps stored documents to entities', () async {
      stubStored(const [
        {'id': 1, 'name': 'A', 'poster_path': '/a.jpg'},
      ]);

      final shows = (await repository.getLikedSeries()).getRight().toNullable()!;

      expect(shows.single.id, 1);
      expect(shows.single.posterPath, '/a.jpg');
    });

    test('a series stored twice under different details is listed once', () async {
      // Accounts collected these while liking added a second entry rather than
      // replacing the first, and they are still on the server.
      stubStored(const [
        staleEntry,
        otherEntry,
        {'id': 1, 'name': 'A', 'poster_path': '/a.jpg', 'popularity': 51.7}
      ]);

      final shows = (await repository.getLikedSeries()).getRight().toNullable()!;

      expect(shows.map((show) => show.id), [1, 2]);
      // The first of the two is the one kept, details and all.
      expect(shows.first.popularity, 44.1);
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
    test('adds the series to the list', () async {
      final result = await repository.likeSeries(series: series);

      expect(result.isRight(), isTrue);
      expect(written().single['id'], 1);
    });

    test('leaves the seriess already liked where they are', () async {
      stubStored(const [otherEntry]);

      await repository.likeSeries(series: series);

      expect(written().map((entry) => entry['id']), [2, 1]);
    });

    test('replaces an entry for the same series rather than adding a second', () async {
      stubStored(const [staleEntry]);

      // The bug a tester saw as the same series twice in the liked list.
      await repository.likeSeries(series: series);

      final entries = written();
      expect(entries, hasLength(1));
      // And the entry that survives is the one just liked, not the stale one.
      expect(entries.single['popularity'], isNull);
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(
        () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
      ).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect((await repository.likeSeries(series: series)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('dislikeSeries', () {
    test('takes the series out of the list', () async {
      stubStored(const [staleEntry, otherEntry]);

      // By id: the stored entry is not the map this entity would produce, and
      // `arrayRemove` used to match nothing and quietly leave the series liked.
      await repository.dislikeSeries(series: series);

      expect(written().map((entry) => entry['id']), [2]);
    });

    test('leaves the list alone when the series was not in it', () async {
      stubStored(const [otherEntry]);

      await repository.dislikeSeries(series: series);

      expect(written().map((entry) => entry['id']), [2]);
    });
  });

  test('a guest is told to sign in rather than reaching Firestore', () async {
    when(() => auth.currentUser).thenReturn(null);

    expect((await repository.likeSeries(series: series)).getLeft().toNullable(), isA<AuthFailure>());
    verifyNever(() => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')));
  });

  group('the recommendation', () {
    test('is marked out of date by a like, so the next launch asks the service again', () async {
      // The tab's opening title is derived from this list. Without the mark,
      // a reader who liked three seriess this morning would keep seeing what
      // the service made of the list before them until the cache aged out.
      expect(likes.changedAt('uid-1'), isNull);

      await repository.likeSeries(series: series);

      expect(likes.changedAt('uid-1'), isNotNull);
    });

    test('is marked out of date by an un-like too', () async {
      await repository.dislikeSeries(series: series);

      expect(likes.changedAt('uid-1'), isNotNull);
    });

    test('is left alone when the write failed', () async {
      when(
        () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
      ).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      await repository.likeSeries(series: series);

      // Nothing changed on the server, so nothing about the picks is stale.
      expect(likes.changedAt('uid-1'), isNull);
    });
  });
}
