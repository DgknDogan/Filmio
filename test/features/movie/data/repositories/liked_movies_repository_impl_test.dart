import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/data/repositories/liked_movies_repository_impl.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
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
  late LikedMoviesRepositoryImpl repository;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

  /// The same film as the list endpoint described it a week ago: same id,
  /// different everything else. This is what used to defeat `arrayUnion` and
  /// `arrayRemove`, and is the reason the id is what counts.
  const staleEntry = {'id': 1, 'title': 'A', 'poster_path': '/a.jpg', 'popularity': 44.1, 'vote_count': 900};
  const otherEntry = {'id': 2, 'title': 'B', 'poster_path': '/b.jpg'};

  /// What the array was rewritten to, whichever call did the rewriting.
  List<Map<String, dynamic>> written() {
    final update = verify(() => transaction.update(document, captureAny())).captured.single as Map<Object, Object?>;
    expect(update.keys.single, 'liked_movies');

    return [for (final entry in update['liked_movies'] as List) Map<String, dynamic>.from(entry as Map)];
  }

  void stubStored(List<Map<String, dynamic>> entries) {
    when(() => snapshot.exists).thenReturn(true);
    when(snapshot.data).thenReturn({'liked_movies': entries});
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

    repository = LikedMoviesRepositoryImpl(firestore, auth, likes);
  });

  group('getLikedMovies', () {
    test('maps stored documents to entities', () async {
      stubStored(const [
        {'id': 1, 'title': 'A', 'poster_path': '/a.jpg'},
      ]);

      final movies = (await repository.getLikedMovies()).getRight().toNullable()!;

      expect(movies.single.id, 1);
      expect(movies.single.posterPath, '/a.jpg');
    });

    test('a film stored twice under different details is listed once', () async {
      // Accounts collected these while liking added a second entry rather than
      // replacing the first, and they are still on the server.
      stubStored(const [
        staleEntry,
        otherEntry,
        {'id': 1, 'title': 'A', 'poster_path': '/a.jpg', 'popularity': 51.7}
      ]);

      final movies = (await repository.getLikedMovies()).getRight().toNullable()!;

      expect(movies.map((movie) => movie.id), [1, 2]);
      // The first of the two is the one kept, details and all.
      expect(movies.first.popularity, 44.1);
    });

    test('a user document with no liked_movies key reads as an empty list', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn(<String, dynamic>{});

      expect((await repository.getLikedMovies()).getRight().toNullable(), isEmpty);
    });

    test('a missing user document is a Failure, not a crash', () async {
      when(() => snapshot.exists).thenReturn(false);
      when(snapshot.data).thenReturn(null);

      expect((await repository.getLikedMovies()).getLeft().toNullable(), isA<ServerFailure>());
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => document.get()).thenThrow(FirebaseException(plugin: 'Firestore', code: 'permission-denied'));

      expect((await repository.getLikedMovies()).getLeft().toNullable(), isA<AuthFailure>());
    });
  });

  group('likeMovie', () {
    test('adds the film to the list', () async {
      final result = await repository.likeMovie(movie: movie);

      expect(result.isRight(), isTrue);
      expect(written().single['id'], 1);
    });

    test('leaves the films already liked where they are', () async {
      stubStored(const [otherEntry]);

      await repository.likeMovie(movie: movie);

      expect(written().map((entry) => entry['id']), [2, 1]);
    });

    test('replaces an entry for the same film rather than adding a second', () async {
      stubStored(const [staleEntry]);

      // The bug a tester saw as the same film twice in the liked list.
      await repository.likeMovie(movie: movie);

      final entries = written();
      expect(entries, hasLength(1));
      // And the entry that survives is the one just liked, not the stale one.
      expect(entries.single['popularity'], isNull);
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(
        () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
      ).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect((await repository.likeMovie(movie: movie)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('dislikeMovie', () {
    test('takes the film out of the list', () async {
      stubStored(const [staleEntry, otherEntry]);

      // By id: the stored entry is not the map this entity would produce, and
      // `arrayRemove` used to match nothing and quietly leave the film liked.
      await repository.dislikeMovie(movie: movie);

      expect(written().map((entry) => entry['id']), [2]);
    });

    test('leaves the list alone when the film was not in it', () async {
      stubStored(const [otherEntry]);

      await repository.dislikeMovie(movie: movie);

      expect(written().map((entry) => entry['id']), [2]);
    });
  });

  test('a guest is told to sign in rather than reaching Firestore', () async {
    when(() => auth.currentUser).thenReturn(null);

    expect((await repository.likeMovie(movie: movie)).getLeft().toNullable(), isA<AuthFailure>());
    verifyNever(() => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')));
  });

  group('the recommendation', () {
    test('is marked out of date by a like, so the next launch asks the service again', () async {
      // The tab's opening title is derived from this list. Without the mark,
      // a reader who liked three films this morning would keep seeing what
      // the service made of the list before them until the cache aged out.
      expect(likes.changedAt('uid-1'), isNull);

      await repository.likeMovie(movie: movie);

      expect(likes.changedAt('uid-1'), isNotNull);
    });

    test('is marked out of date by an un-like too', () async {
      await repository.dislikeMovie(movie: movie);

      expect(likes.changedAt('uid-1'), isNotNull);
    });

    test('is left alone when the write failed', () async {
      when(
        () => firestore.runTransaction<void>(any(), timeout: any(named: 'timeout'), maxAttempts: any(named: 'maxAttempts')),
      ).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      await repository.likeMovie(movie: movie);

      // Nothing changed on the server, so nothing about the picks is stale.
      expect(likes.changedAt('uid-1'), isNull);
    });
  });
}
