import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/extensions/firebase_firestore_extension.dart';

import '../../../../core/models/movie.dart';
import '../../../movie/domain/entities/movie.dart';

part '../states/liked_movies_state.dart';

class LikedMoviesCubit extends Cubit<LikedMoviesState> {
  LikedMoviesCubit() : super(LikedMoviesState(list: [])) {
    _init();
  }

  void _init() async {
    await getLikedMovies();
  }

  Future<void> getLikedMovies() async {
    final userDocumentRef = FirebaseFirestore.instance.getUserDocRef();
    final userDocumentSnapshot = await userDocumentRef.get();
    final List<dynamic> list = userDocumentSnapshot.data()!["liked_movies"];
    final List<MovieEntity> moviesList = [];
    for (Map<String, dynamic> movieData in list) {
      moviesList.add(MovieModel.fromJson(movieData));
    }
    emit(LikedMoviesState(list: moviesList));
  }
}
