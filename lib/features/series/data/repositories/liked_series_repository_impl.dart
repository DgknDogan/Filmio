import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/storage/firestore_title_list.dart';
import '../../../../core/storage/liked_titles_stamp.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/liked_series_repository.dart';
import '../models/series_model.dart';

/// The series an account has liked, stored beside the liked films on the same
/// user document and read through the same mechanism — see
/// [LikedMoviesRepositoryImpl] and [FirestoreTitleList].
class LikedSeriesRepositoryImpl extends LikedSeriesRepository {
  final FirestoreTitleList<SeriesEntity> _titles;

  LikedSeriesRepositoryImpl(FirebaseFirestore firestore, FirebaseAuth auth, LikedTitlesStamp likes)
      : _titles = FirestoreTitleList(
          firestore: firestore,
          auth: auth,
          // The films use `liked_movies`; renaming either orphans whatever is
          // already on the server.
          field: 'liked_series',
          mirrorCollection: likedSeriesCollection,
          idOf: (series) => series.id,
          toJson: (series) => SeriesModel.fromEntity(series).toJson(),
          fromJson: (json) => SeriesModel.fromJson(json).toEntity(),
          signedOutMessage: 'Sign in to keep the titles you like.',
          onChanged: likes.markChanged,
        );

  @override
  Future<Either<Failure, List<SeriesEntity>>> getLikedSeries() => _titles.read();

  @override
  Future<Either<Failure, Unit>> likeSeries({required SeriesEntity series}) => _titles.write(series, include: true);

  @override
  Future<Either<Failure, Unit>> dislikeSeries({required SeriesEntity series}) => _titles.write(series, include: false);
}
