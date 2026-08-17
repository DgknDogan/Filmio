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

  DocumentReference<Map<String, dynamic>> get _userDoc => _firestore.userDoc(_auth.currentUser!.uid);

  @override
  Future<Either<Failure, List<MovieEntity>>> getLikedMovies() async {
    try {
      final userDoc = await _userDoc.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return const Left(ServerFailure('That record no longer exists.'));
      }

      final List<dynamic> likedMoviesDynamic = userDoc.data()!["liked_movies"] ?? const [];
      final likedMovies =
          likedMoviesDynamic.map((movie) => MovieModel.fromJson(Map<String, dynamic>.from(movie)).toEntity()).toList();

      return Right(likedMovies);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeMovie({required MovieEntity movie}) async {
    try {
      await _userDoc.update({
        "liked_movies": FieldValue.arrayUnion([MovieModel.fromEntity(movie).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> dislikeMovie({required MovieEntity movie}) async {
    try {
      await _userDoc.update({
        "liked_movies": FieldValue.arrayRemove([MovieModel.fromEntity(movie).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }
}
