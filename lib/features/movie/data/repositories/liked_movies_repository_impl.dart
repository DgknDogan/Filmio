import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/storage/liked_titles_stamp.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../models/movie_model.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/liked_movies_repository.dart';

/// The titles an account has liked, as an array on its user document.
///
/// A title is its TMDB id here, and nothing else. That is the whole reason
/// this class does its own reading and writing instead of leaving it to
/// `arrayUnion` and `arrayRemove`: those compare whole maps, and the same film
/// does not arrive as the same map twice. A list entry carries bare genre ids
/// where the detail endpoint names them in full, and `popularity`, `vote_
/// average` and `vote_count` all drift between one visit and the next. So the
/// same film liked from a row and from its own screen used to land in the list
/// twice, and un-liking it — which asks `arrayRemove` to match a map it no
/// longer has — used to quietly do nothing.
class LikedMoviesRepositoryImpl extends LikedMoviesRepository {
  /// The array on the user document. Also the JSON shape [MovieModel] reads
  /// and writes, so renaming one of its fields rewrites data already on the
  /// server.
  static const _field = 'liked_movies';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Marked on every change, because the recommendation each tab opens on is
  /// derived from this list and a cached one written before the change is
  /// answering an out-of-date question.
  final LikedTitlesStamp _likes;

  LikedMoviesRepositoryImpl(this._firestore, this._auth, this._likes);

  /// The signed-in user's document, or null when nobody is signed in.
  ///
  /// Nullable rather than a bang: a guest reaches these screens with no
  /// Firebase user at all, and a list that cannot be read is a failure to
  /// report, not a crash.
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.userDoc(uid);
  }

  static const _signedOut = AuthFailure('Sign in to keep the titles you like.');

  @override
  Future<Either<Failure, List<MovieEntity>>> getLikedMovies() async {
    final doc = _userDoc;
    if (doc == null) return const Left(_signedOut);

    try {
      final userDoc = await doc.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return const Left(ServerFailure('That record no longer exists.'));
      }

      return Right(_readList(userDoc.data()).map((movie) => movie.toEntity()).toList());
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeMovie({required MovieEntity movie}) {
    // Liking a film already in the list replaces the entry rather than adding
    // a second one, which also refreshes what the list holds about it.
    return _rewrite(movie, liked: true);
  }

  @override
  Future<Either<Failure, Unit>> dislikeMovie({required MovieEntity movie}) {
    return _rewrite(movie, liked: false);
  }

  /// Rewrites the list without [movie] in it, adding it back when [liked],
  /// and mirrors the result into `LikedMovies/{id}` in the same transaction.
  ///
  /// In a transaction because the list is read before it is written: two
  /// screens liking at once would otherwise each write a list that does not
  /// know about the other's.
  Future<Either<Failure, Unit>> _rewrite(MovieEntity movie, {required bool liked}) async {
    // The user id rather than the document, because the stamp below is keyed
    // by it too.
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Left(_signedOut);

    final doc = _firestore.userDoc(uid);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(doc);
        // A title with no id cannot be told from another one, so nothing is
        // dropped for it — better a stray entry than somebody else's gone.
        final kept = [
          for (final entry in _rawList(snapshot.data()))
            if (movie.id == null || entry['id'] != movie.id) entry,
        ];

        transaction.update(doc, {
          _field: [...kept, if (liked) MovieModel.fromEntity(movie).toJson()],
        });

        final id = movie.id;
        if (id != null) {
          final likedDoc = doc.collection(likedMoviesCollection).doc('$id');
          if (liked) {
            transaction.set(likedDoc, {'id': id});
          } else {
            transaction.delete(likedDoc);
          }
        }
      });

      await _likes.markChanged(uid);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  /// The array as it is stored, entry by entry.
  static List<Map<String, dynamic>> _rawList(Map<String, dynamic>? data) {
    final stored = data?[_field];
    if (stored is! List) return [];

    return [for (final entry in stored) Map<String, dynamic>.from(entry as Map)];
  }

  /// The array as titles, with any id that appears more than once kept only
  /// the first time.
  ///
  /// Duplicates should not reach this after the rewrite above, but accounts
  /// that collected them under the old behaviour still carry them, and a list
  /// showing the same film twice is the bug the reader actually sees.
  static List<MovieModel> _readList(Map<String, dynamic>? data) {
    final seen = <Object?>{};

    return [
      for (final entry in _rawList(data))
        if (entry['id'] == null || seen.add(entry['id'])) MovieModel.fromJson(entry),
    ];
  }
}
