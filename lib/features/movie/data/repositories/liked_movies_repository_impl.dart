import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/storage/firestore_title_list.dart';
import '../../../../core/storage/liked_titles_stamp.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/liked_movies_repository.dart';
import '../models/movie_model.dart';

/// The films an account has liked, as an array on its user document.
///
/// [FirestoreTitleList] is the whole of how that array is read and rewritten,
/// and its documentation is where to look for why a title is its id here. What
/// belongs to this list in particular is the three things configured below:
/// the field it lives in, the subcollection the recommendation service reads
/// it through, and the mark that tells the recommendation caches they are out
/// of date.
class LikedMoviesRepositoryImpl extends LikedMoviesRepository {
  final FirestoreTitleList<MovieEntity> _titles;

  /// [likes] is marked on every change, because the recommendation each tab
  /// opens on is derived from this list and a cached one written before the
  /// change is answering an out-of-date question.
  LikedMoviesRepositoryImpl(FirebaseFirestore firestore, FirebaseAuth auth, LikedTitlesStamp likes)
      : _titles = FirestoreTitleList(
          firestore: firestore,
          auth: auth,
          field: 'liked_movies',
          mirrorCollection: likedMoviesCollection,
          idOf: (movie) => movie.id,
          toJson: (movie) => MovieModel.fromEntity(movie).toJson(),
          fromJson: (json) => MovieModel.fromJson(json).toEntity(),
          signedOutMessage: 'Sign in to keep the titles you like.',
          onChanged: likes.markChanged,
        );

  @override
  Future<Either<Failure, List<MovieEntity>>> getLikedMovies() => _titles.read();

  @override
  Future<Either<Failure, Unit>> likeMovie({required MovieEntity movie}) => _titles.write(movie, include: true);

  @override
  Future<Either<Failure, Unit>> dislikeMovie({required MovieEntity movie}) => _titles.write(movie, include: false);
}
