import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/models/movie.dart';
import '../../domain/entities/movie.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../domain/repository/firebase_repository.dart';

class FirebaseRepositoryImpl extends FirebaseRepository {
  FirebaseRepositoryImpl();
  @override
  Future<FirebaseState<List<MovieEntity>>> getLikedMovies() async {
    try {
      final userDocumentRef = FirebaseFirestore.instance.getUserDocRef();
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
      final userDocumentRef = FirebaseFirestore.instance.getUserDocRef();
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
      final userDocumentRef = FirebaseFirestore.instance.getUserDocRef();
      await userDocumentRef.update({
        "liked_movies": FieldValue.arrayRemove([(movie as MovieModel).toJson()]),
      });
      return FirebaseSuccess(data: true);
    } on FirebaseException catch (e) {
      return FirebaseError(error: e);
    }
  }
}
