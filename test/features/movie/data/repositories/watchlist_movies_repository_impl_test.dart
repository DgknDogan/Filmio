import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/features/movie/data/repositories/watchlist_movies_repository_impl.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore_for_file: subtype_of_sealed_class
// cloud_firestore seals its reference types; see the liked-movies test.

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}

class _MockDocument extends Mock implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockTransaction extends Mock implements Transaction {}

Future<void> _noopHandler(Transaction transaction) async {}

/// How the array is read and rewritten is [FirestoreTitleList]'s behaviour and
/// is tested there. What is this repository's own is the three things it
/// configures, and all three are the kind of mistake nothing else would catch:
/// the field it writes to, that add and remove are not the wrong way round,
/// and that it keeps no mirror subcollection.
void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockDocument document;
  late _MockSnapshot snapshot;
  late _MockTransaction transaction;
  late WatchlistMoviesRepositoryImpl repository;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

  Map<Object, Object?> written() {
    return verify(() => transaction.update(document, captureAny())).captured.single as Map<Object, Object?>;
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

    when(() => snapshot.exists).thenReturn(true);
    when(snapshot.data).thenReturn({
      'liked_movies': const [
        {'id': 9, 'title': 'Liked', 'poster_path': '/l.jpg'},
      ],
    });

    repository = WatchlistMoviesRepositoryImpl(firestore, auth);
  });

  test('writes to watchlist_movies, leaving the liked list untouched', () async {
    await repository.addToWatchlist(movie: movie);

    // The whole update, so a write that also touched `liked_movies` would
    // fail here rather than quietly rewriting somebody's likes.
    expect(written().keys, ['watchlist_movies']);
  });

  test('reads watchlist_movies rather than the liked list beside it', () async {
    when(snapshot.data).thenReturn({
      'liked_movies': const [
        {'id': 9, 'title': 'Liked', 'poster_path': '/l.jpg'},
      ],
      'watchlist_movies': const [
        {'id': 1, 'title': 'A', 'poster_path': '/a.jpg'},
      ],
    });

    final movies = (await repository.getWatchlistMovies()).getRight().toNullable()!;

    expect(movies.map((movie) => movie.id), [1]);
  });

  test('adding puts the film in the list', () async {
    await repository.addToWatchlist(movie: movie);

    expect((written()['watchlist_movies'] as List), hasLength(1));
  });

  test('removing takes it out again', () async {
    when(snapshot.data).thenReturn({
      'watchlist_movies': const [
        {'id': 1, 'title': 'A', 'poster_path': '/a.jpg'},
        {'id': 2, 'title': 'B', 'poster_path': '/b.jpg'},
      ],
    });

    await repository.removeFromWatchlist(movie: movie);

    final entries = written()['watchlist_movies'] as List;
    expect(entries.map((entry) => (entry as Map)['id']), [2]);
  });

  test('keeps no mirror subcollection, because nothing reads one', () async {
    await repository.addToWatchlist(movie: movie);
    await repository.removeFromWatchlist(movie: movie);

    verifyNever(() => document.collection(any()));
  });
}
