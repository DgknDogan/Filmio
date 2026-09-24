import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/models/watched_title_model.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/repositories/watched_movies_repository.dart';

class WatchedMoviesRepositoryImpl extends WatchedMoviesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WatchedMoviesRepositoryImpl(this._firestore, this._auth);

  /// The signed-in user's watched films, or null when nobody is signed in —
  /// a guest reaches the details screen with no Firebase user at all.
  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.watchedMovies(uid);
  }

  static const _signedOut = AuthFailure('Sign in to keep the titles you have watched.');

  @override
  Future<Either<Failure, List<int>>> getWatchedMovieIds() async {
    final collection = _collection;
    if (collection == null) return const Left(_signedOut);

    try {
      final snapshot = await collection.orderBy(WatchedTitleModel.timestampField, descending: true).get();

      final ids = snapshot.docs.map((doc) => WatchedTitleModel.fromFirestore(doc.id, doc.data())?.id).nonNulls.toList();

      return Right(ids);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isMovieWatched({required int movieId}) async {
    final collection = _collection;
    if (collection == null) return const Left(_signedOut);

    try {
      final doc = await collection.doc('$movieId').get();
      return Right(doc.exists);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> addWatchedMovie({required int movieId}) async {
    final collection = _collection;
    if (collection == null) return const Left(_signedOut);

    try {
      await collection.doc('$movieId').set(WatchedTitleModel(id: movieId).toFirestore());
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeWatchedMovie({required int movieId}) async {
    final collection = _collection;
    if (collection == null) return const Left(_signedOut);

    try {
      await collection.doc('$movieId').delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }
}
