import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/features/movie/data/models/movie.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../domain/repository/firebase_repository.dart';
import '../data_sources/firebase/firebase_service.dart';

class FirebaseRepositoryImpl extends FirebaseRepository {
  final FirebaseService _firebaseService;

  FirebaseRepositoryImpl(this._firebaseService);
  @override
  Future<FirebaseState<List<MovieEntity>>> getLikedMovies() async {
    try {
      final uid = _firebaseService.getUserId();
      if (uid == null) {
        return FirebaseError(
          error: FirebaseException(
            plugin: "FirebaseAuth",
            code: 'user-not-logged-in',
            message: 'User not logged in',
          ),
        );
      }
      final userDocumentRef = _firebaseService.getUserDocumentRef(uid: uid);
      final userDoc = await userDocumentRef.get();
      if (userDoc.exists && userDoc.data() != null) {
        final List<MovieEntity> likedMoviesList = [];
        final List<dynamic> likedMoviesDynamic = userDoc.data()!["liked_movies"];
        final List<Map<String, dynamic>> likedMoviesData = likedMoviesDynamic.map((movie) => Map<String, dynamic>.from(movie)).toList();

        for (var json in likedMoviesData) {
          likedMoviesList.add(MovieModel.fromJson(json));
        }

        return FirebaseSuccess(data: likedMoviesList);
      } else {
        return FirebaseError(
          error: FirebaseException(
            plugin: "Firestore",
            code: 'user-document-not-found',
            message: 'User document not found',
          ),
        );
      }
    } on FirebaseException catch (e) {
      return FirebaseError(error: e);
    }
  }

  @override
  Future<FirebaseState<bool>> likeMovie({required MovieEntity movie}) async {
    try {
      final uid = _firebaseService.getUserId();
      if (uid == null) {
        return FirebaseError(
          error: FirebaseException(
            plugin: "FirebaseAuth",
            code: 'user-not-logged-in',
            message: 'User not logged in',
          ),
        );
      }
      final userDocumentRef = _firebaseService.getUserDocumentRef(uid: uid);
      await userDocumentRef.update({
        "liked_movies": FieldValue.arrayUnion([(movie as MovieModel).toJson()]),
      });
      return FirebaseSuccess(data: true);
    } on FirebaseException catch (e) {
      return FirebaseError(error: e);
    }
  }

  @override
  Future<FirebaseState<bool>> dislikeMovie({required MovieEntity movie}) async {
    try {
      final uid = _firebaseService.getUserId();
      if (uid == null) {
        return FirebaseError(
          error: FirebaseException(
            plugin: "FirebaseAuth",
            code: 'user-not-logged-in',
            message: 'User not logged in',
          ),
        );
      }
      final userDocumentRef = _firebaseService.getUserDocumentRef(uid: uid);
      await userDocumentRef.update({
        "liked_movies": FieldValue.arrayRemove([(movie as MovieModel).toJson()]),
      });
      return FirebaseSuccess(data: true);
    } on FirebaseException catch (e) {
      return FirebaseError(error: e);
    }
  }
}
