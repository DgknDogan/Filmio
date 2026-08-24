import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../models/movie_model.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/liked_movies_repository.dart';

class LikedMoviesRepositoryImpl extends LikedMoviesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LikedMoviesRepositoryImpl(this._firestore, this._auth);

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

      final List<dynamic> likedMoviesDynamic = userDoc.data()!["liked_movies"] ?? const [];
      final likedMovies = likedMoviesDynamic.map((movie) => MovieModel.fromJson(Map<String, dynamic>.from(movie)).toEntity()).toList();

      return Right(likedMovies);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeMovie({required MovieEntity movie}) async {
    final doc = _userDoc;
    if (doc == null) return const Left(_signedOut);

    try {
      await doc.update({
        "liked_movies": FieldValue.arrayUnion([MovieModel.fromEntity(movie).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> dislikeMovie({required MovieEntity movie}) async {
    final doc = _userDoc;
    if (doc == null) return const Left(_signedOut);

    try {
      await doc.update({
        "liked_movies": FieldValue.arrayRemove([MovieModel.fromEntity(movie).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }
}
