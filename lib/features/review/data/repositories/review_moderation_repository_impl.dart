import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/resource/failure.dart';
import '../../../../core/resource/failure_mapper.dart';
import '../../domain/entities/review_report.dart';
import '../../domain/repositories/review_moderation_repository.dart';
import '../datasources/review_moderation_local_datasource.dart';

class ReviewModerationRepositoryImpl extends ReviewModerationRepository {
  /// How much of the review travels with a report. Enough to see what was
  /// being complained about without copying an essay into every document.
  static const _excerptLimit = 500;

  final ReviewModerationLocalDataSource _localDataSource;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewModerationRepositoryImpl(this._localDataSource, this._firestore, this._auth);

  @override
  Set<String> get blockedAuthors => _localDataSource.blockedAuthors;

  @override
  Set<String> get hiddenReviewIds => _localDataSource.hiddenReviewIds;

  @override
  Future<Either<Failure, Unit>> report(ReviewReport report) async {
    try {
      await _firestore.collection(reviewReportCollection).add({
        'review_id': report.reviewId,
        'author': report.author,
        'media_id': report.mediaId,
        'media_type': report.mediaType.name,
        'reason': report.reason.name,
        'excerpt': report.excerpt.length > _excerptLimit ? report.excerpt.substring(0, _excerptLimit) : report.excerpt,
        'reported_by': _auth.currentUser?.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Only after the report is filed: hiding it locally first would leave a
      // reader thinking they had reported something they had not.
      await _localDataSource.hideReview(report.reviewId);

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(failureFromFirebase(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> blockAuthor(String author) async {
    try {
      await _localDataSource.blockAuthor(author);
      return const Right(unit);
    } on Exception {
      return const Left(CacheFailure('Could not save that. Try again.'));
    }
  }
}
