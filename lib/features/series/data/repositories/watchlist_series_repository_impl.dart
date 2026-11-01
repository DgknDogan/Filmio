import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/storage/firestore_title_list.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/watchlist_series_repository.dart';
import '../models/series_model.dart';

/// The series an account means to watch, stored beside the films' watchlist on
/// the same user document — see [WatchlistMoviesRepositoryImpl] for why this
/// list has neither a mirror subcollection nor a recommendation stamp.
class WatchlistSeriesRepositoryImpl extends WatchlistSeriesRepository {
  final FirestoreTitleList<SeriesEntity> _titles;

  WatchlistSeriesRepositoryImpl(FirebaseFirestore firestore, FirebaseAuth auth)
      : _titles = FirestoreTitleList(
          firestore: firestore,
          auth: auth,
          field: 'watchlist_series',
          idOf: (series) => series.id,
          toJson: (series) => SeriesModel.fromEntity(series).toJson(),
          fromJson: (json) => SeriesModel.fromJson(json).toEntity(),
          signedOutMessage: 'Sign in to keep a watchlist.',
        );

  @override
  Future<Either<Failure, List<SeriesEntity>>> getWatchlistSeries() => _titles.read();

  @override
  Future<Either<Failure, Unit>> addToWatchlist({required SeriesEntity series}) => _titles.write(series, include: true);

  @override
  Future<Either<Failure, Unit>> removeFromWatchlist({required SeriesEntity series}) => _titles.write(series, include: false);
}
