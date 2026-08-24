import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmio/core/constants/constants.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/features/review/data/repositories/review_moderation_repository_impl.dart';
import 'package:filmio/features/review/domain/entities/review_report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockReviewModerationLocalDataSource localDataSource;
  late MockFirebaseFirestore firestore;
  late MockCollectionReference reports;
  late MockFirebaseAuth auth;
  late MockUser user;
  late ReviewModerationRepositoryImpl repository;

  const report = ReviewReport(
    reviewId: 'r1',
    author: 'Cat',
    mediaId: 550,
    mediaType: MediaType.movie,
    reason: ReportReason.offensiveLanguage,
    excerpt: 'Good.',
  );

  setUpAll(registerCommonFallbacks);

  setUp(() {
    localDataSource = MockReviewModerationLocalDataSource();
    firestore = MockFirebaseFirestore();
    reports = MockCollectionReference();
    auth = MockFirebaseAuth();
    user = MockUser();
    repository = ReviewModerationRepositoryImpl(localDataSource, firestore, auth);

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid-1');
    when(() => firestore.collection(reviewReportCollection)).thenReturn(reports);
    when(() => reports.add(any())).thenAnswer((_) async => MockDocumentReference());
    when(() => localDataSource.hideReview(any())).thenAnswer((_) async {});
    when(() => localDataSource.blockAuthor(any())).thenAnswer((_) async {});
  });

  group('report', () {
    test('files the report with what a moderator needs to act on it', () async {
      final result = await repository.report(report);

      expect(result.isRight(), isTrue);

      final filed = verify(() => reports.add(captureAny())).captured.single as Map<String, dynamic>;
      expect(filed['review_id'], 'r1');
      expect(filed['author'], 'Cat');
      expect(filed['media_id'], 550);
      expect(filed['media_type'], 'movie');
      expect(filed['reason'], 'offensiveLanguage');
      expect(filed['excerpt'], 'Good.');
      expect(filed['reported_by'], 'uid-1');
    });

    test('hides the review only once the report is filed', () async {
      await repository.report(report);

      verifyInOrder([
        () => reports.add(any()),
        () => localDataSource.hideReview('r1'),
      ]);
    });

    test('leaves the review visible when Firestore refuses the write', () async {
      when(() => reports.add(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      final result = await repository.report(report);

      expect(result.isLeft(), isTrue);
      verifyNever(() => localDataSource.hideReview(any()));
    });

    test('truncates an essay so one report cannot carry a whole review', () async {
      final long = ReviewReport(
        reviewId: 'r2',
        author: 'Sam',
        mediaId: 550,
        mediaType: MediaType.movie,
        reason: ReportReason.spam,
        excerpt: 'x' * 900,
      );

      await repository.report(long);

      final filed = verify(() => reports.add(captureAny())).captured.single as Map<String, dynamic>;
      expect((filed['excerpt'] as String).length, 500);
    });
  });

  group('blockAuthor', () {
    test('writes the author to the local store', () async {
      final result = await repository.blockAuthor('Cat');

      expect(result.isRight(), isTrue);
      verify(() => localDataSource.blockAuthor('Cat')).called(1);
    });
  });
}
