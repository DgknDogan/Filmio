import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/liked_series_repository.dart';
import '../models/series_model.dart';

/// The liked series, stored beside the liked films on the same user document.
///
/// Same shape as `LikedMoviesRepositoryImpl` — one array field per kind, the
/// stored objects being the model's own JSON — so the two lists read and write
/// identically and a change to one has an obvious counterpart in the other.
class LikedSeriesRepositoryImpl extends LikedSeriesRepository {
  /// The field on the user document. The films use `liked_movies`; renaming
  /// either orphans whatever is already on the server.
  static const _field = 'liked_series';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LikedSeriesRepositoryImpl(this._firestore, this._auth);

  DocumentReference<Map<String, dynamic>> get _userDoc => _firestore.userDoc(_auth.currentUser!.uid);

  @override
  Future<Either<Failure, List<SeriesEntity>>> getLikedSeries() async {
    try {
      final userDoc = await _userDoc.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return const Left(ServerFailure('That record no longer exists.'));
      }

      // An account that has never liked a series has no field at all, which is
      // an empty list rather than a failure.
      final List<dynamic> likedSeriesDynamic = userDoc.data()![_field] ?? const [];
      final likedSeries = likedSeriesDynamic.map((series) => SeriesModel.fromJson(Map<String, dynamic>.from(series)).toEntity()).toList();

      return Right(likedSeries);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeSeries({required SeriesEntity series}) async {
    try {
      await _userDoc.update({
        _field: FieldValue.arrayUnion([SeriesModel.fromEntity(series).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> dislikeSeries({required SeriesEntity series}) async {
    try {
      await _userDoc.update({
        _field: FieldValue.arrayRemove([SeriesModel.fromEntity(series).toJson()]),
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }
}
