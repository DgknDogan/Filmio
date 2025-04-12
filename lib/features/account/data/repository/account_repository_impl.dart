import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/models/movie.dart';
import '../../domain/repository/account_repository.dart';

class AccountRepositoryImpl extends AccountRepository {
  @override
  Future<List<MovieModel>> getLikedMovies() async {
    final userDocumentRef = FirebaseFirestore.instance.getUserDocRef();
    final docSnapshot = await userDocumentRef.get();
    final likedMoviesDataList = docSnapshot.data()!["liked_movies"] as List<Map<String, dynamic>>;
    final List<MovieModel> likedMovieList = [];
    for (var movieData in likedMoviesDataList) {
      likedMovieList.add(MovieModel.fromJson(movieData));
    }
    return likedMovieList;
  }
}
