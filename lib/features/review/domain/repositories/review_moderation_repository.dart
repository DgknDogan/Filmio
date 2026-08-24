import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../entities/review_report.dart';

/// What the app does about a review somebody objects to.
///
/// App Review guideline 1.2 asks an app showing user-generated content for
/// three things beyond a way to filter it: a mechanism to report content, a
/// way to block abusive users, and a timely answer to what comes in. This is
/// the first two; the third is a person reading the reports.
abstract class ReviewModerationRepository {
  /// Files [report] and hides the review on this device straight away — the
  /// person who reported it should not have to look at it again while it is
  /// being dealt with.
  Future<Either<Failure, Unit>> report(ReviewReport report);

  /// Hides every review by [author], now and in future pages.
  Future<Either<Failure, Unit>> blockAuthor(String author);

  /// The handles blocked on this device.
  Set<String> get blockedAuthors;

  /// The reviews already reported from this device.
  Set<String> get hiddenReviewIds;
}
