import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../film/models/film_model.dart';

final class UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<FilmModel>> getLikedMoviesList() async {
    List<FilmModel> likedMoviesList = [];
    try {
      final userDocument = await _db.collection("User").doc(_auth.currentUser!.uid).get();
      final data = userDocument.data();

      final likedMoviesData = data!["liked_movies"];
      for (var movieData in likedMoviesData) {
        likedMoviesList.add(FilmModel.fromJson(movieData));
      }
      return likedMoviesList;
    } catch (e) {
      log(e.toString());
    }
    return likedMoviesList;
  }

  Future<void> updateLikedMoviesList({required List<FilmModel> likedFilmList}) async {
    final likedMovieList = [];
    for (var film in likedFilmList) {
      likedMovieList.add(film.toJson());
    }
    try {
      final userDocument = _db.collection("User").doc(_auth.currentUser!.uid);
      await userDocument.update({"liked_movies": likedMovieList});
    } catch (e) {
      log(e.toString());
    }
  }
}
