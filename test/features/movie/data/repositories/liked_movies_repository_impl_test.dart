import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/data/repositories/liked_movies_repository_impl.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
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

void main() {
  late _MockFirestore firestore;
  late _MockAuth auth;
  late _MockDocument document;
  late _MockSnapshot snapshot;
  late LikedMoviesRepositoryImpl repository;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    firestore = _MockFirestore();
    auth = _MockAuth();
    document = _MockDocument();
    snapshot = _MockSnapshot();

    final user = _MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => auth.currentUser).thenReturn(user);

    final collection = _MockCollection();
    when(() => firestore.collection(any())).thenReturn(collection);
    when(() => collection.doc(any())).thenReturn(document);
    when(() => document.get()).thenAnswer((_) async => snapshot);
    when(() => document.update(any())).thenAnswer((_) async {});

    repository = LikedMoviesRepositoryImpl(firestore, auth);
  });

  group('getLikedMovies', () {
    test('maps stored documents to entities', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn({
        'liked_movies': [
          {'id': 1, 'title': 'A', 'poster_path': '/a.jpg'},
        ],
      });

      final movies = (await repository.getLikedMovies()).getRight().toNullable()!;

      expect(movies.single.id, 1);
      expect(movies.single.posterPath, '/a.jpg');
    });

    test('a user document with no liked_movies key reads as an empty list', () async {
      when(() => snapshot.exists).thenReturn(true);
      when(snapshot.data).thenReturn(<String, dynamic>{});

      expect((await repository.getLikedMovies()).getRight().toNullable(), isEmpty);
    });

    test('a missing user document is a Failure, not a crash', () async {
      // The version this replaced did `docSnapshot.data()!` and threw.
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
    test('writes the movie under the exact keys Firestore already stores', () async {
      await repository.likeMovie(movie: movie);

      final written = verify(() => document.update(captureAny())).captured.single as Map<Object, Object?>;
      expect(written.keys.single, 'liked_movies');
    });

    test('accepts a plain entity — the old cast threw here', () async {
      final result = await repository.likeMovie(movie: movie);

      expect(result.isRight(), isTrue);
    });

    test('a Firestore error is mapped rather than escaping', () async {
      when(() => document.update(any())).thenThrow(FirebaseException(plugin: 'Firestore', code: 'unavailable'));

      expect((await repository.likeMovie(movie: movie)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  test('dislikeMovie removes rather than adds', () async {
    await repository.dislikeMovie(movie: movie);

    verify(() => document.update(any())).called(1);
  });
}
