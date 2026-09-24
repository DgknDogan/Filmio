import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/storage/liked_titles_stamp.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/extensions/firebase_firestore_extension.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/liked_series_repository.dart';
import '../models/series_model.dart';

/// The liked series, stored beside the liked films on the same user document.
///
/// Same shape as `LikedMoviesRepositoryImpl` — one array field per kind, the
/// stored objects being the model's own JSON, a title identified by its TMDB
/// id alone — so the two lists read and write identically and a change to one
/// has an obvious counterpart in the other. That file explains why the id is
/// what counts rather than the whole stored map.
class LikedSeriesRepositoryImpl extends LikedSeriesRepository {
  /// The field on the user document. The films use `liked_movies`; renaming
  /// either orphans whatever is already on the server.
  static const _field = 'liked_series';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Marked on every change, because the recommendation each tab opens on is
  /// derived from this list and a cached one written before the change is
  /// answering an out-of-date question.
  final LikedTitlesStamp _likes;

  LikedSeriesRepositoryImpl(this._firestore, this._auth, this._likes);

  /// The signed-in user's document, or null when nobody is signed in.
  ///
  /// Nullable rather than a bang: a guest reaches these screens with no
  /// Firebase user at all, and a list that cannot be read is a failure to
  /// report, not a crash.
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.userDoc(uid);
  }

  static const _signedOut = AuthFailure('Sign in to keep the titles you like.');

  @override
  Future<Either<Failure, List<SeriesEntity>>> getLikedSeries() async {
    final doc = _userDoc;
    if (doc == null) return const Left(_signedOut);

    try {
      final userDoc = await doc.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return const Left(ServerFailure('That record no longer exists.'));
      }

      return Right(_readList(userDoc.data()).map((series) => series.toEntity()).toList());
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeSeries({required SeriesEntity series}) {
    // Liking a series already in the list replaces the entry rather than
    // adding a second one, which also refreshes what the list holds about it.
    return _rewrite(series, liked: true);
  }

  @override
  Future<Either<Failure, Unit>> dislikeSeries({required SeriesEntity series}) {
    return _rewrite(series, liked: false);
  }

  /// Rewrites the list without [series] in it, adding it back when [liked],
  /// and mirrors the result into `LikedSeries/{id}` in the same transaction.
  ///
  /// In a transaction because the list is read before it is written: two
  /// screens liking at once would otherwise each write a list that does not
  /// know about the other's.
  Future<Either<Failure, Unit>> _rewrite(SeriesEntity series, {required bool liked}) async {
    // The user id rather than the document, because the stamp below is keyed
    // by it too.
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Left(_signedOut);

    final doc = _firestore.userDoc(uid);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(doc);
        // A title with no id cannot be told from another one, so nothing is
        // dropped for it — better a stray entry than somebody else's gone.
        final kept = [
          for (final entry in _rawList(snapshot.data()))
            if (series.id == null || entry['id'] != series.id) entry,
        ];

        transaction.update(doc, {
          _field: [...kept, if (liked) SeriesModel.fromEntity(series).toJson()],
        });

        final id = series.id;
        if (id != null) {
          final likedDoc = doc.collection(likedSeriesCollection).doc('$id');
          if (liked) {
            transaction.set(likedDoc, {'id': id});
          } else {
            transaction.delete(likedDoc);
          }
        }
      });

      await _likes.markChanged(uid);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  /// The array as it is stored, entry by entry. An account that has never
  /// liked a series has no field at all, which is an empty list rather than a
  /// failure.
  static List<Map<String, dynamic>> _rawList(Map<String, dynamic>? data) {
    final stored = data?[_field];
    if (stored is! List) return [];

    return [for (final entry in stored) Map<String, dynamic>.from(entry as Map)];
  }

  /// The array as titles, with any id that appears more than once kept only
  /// the first time — accounts that collected duplicates under the old
  /// behaviour still carry them.
  static List<SeriesModel> _readList(Map<String, dynamic>? data) {
    final seen = <Object?>{};

    return [
      for (final entry in _rawList(data))
        if (entry['id'] == null || seen.add(entry['id'])) SeriesModel.fromJson(entry),
    ];
  }
}
