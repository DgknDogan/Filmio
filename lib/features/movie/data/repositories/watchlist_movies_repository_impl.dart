import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/storage/firestore_title_list.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/watchlist_movies_repository.dart';
import '../models/movie_model.dart';

/// The films an account means to watch, as an array on its user document —
/// the same mechanism the liked list uses, described in [FirestoreTitleList].
///
/// Two things it does not have, and both are deliberate. There is no mirror
/// subcollection: that projection exists for the recommendation service, and
/// the service is not asked about a watchlist. And there is no
/// [LikedTitlesStamp] to mark, because no recommendation is derived from this
/// list, so adding to it cannot make a cached one wrong.
class WatchlistMoviesRepositoryImpl extends WatchlistMoviesRepository {
  final FirestoreTitleList<MovieEntity> _titles;

  WatchlistMoviesRepositoryImpl(FirebaseFirestore firestore, FirebaseAuth auth)
      : _titles = FirestoreTitleList(
          firestore: firestore,
          auth: auth,
          field: 'watchlist_movies',
          idOf: (movie) => movie.id,
          toJson: (movie) => MovieModel.fromEntity(movie).toJson(),
          fromJson: (json) => MovieModel.fromJson(json).toEntity(),
          signedOutMessage: 'Sign in to keep a watchlist.',
        );

  @override
  Future<Either<Failure, List<MovieEntity>>> getWatchlistMovies() => _titles.read();

  @override
  Future<Either<Failure, Unit>> addToWatchlist({required MovieEntity movie}) => _titles.write(movie, include: true);

  @override
  Future<Either<Failure, Unit>> removeFromWatchlist({required MovieEntity movie}) => _titles.write(movie, include: false);
}
