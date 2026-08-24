import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/review/domain/entities/review_entity.dart';
import 'package:filmio/features/review/domain/entities/review_report.dart';
import 'package:filmio/features/review/presentation/cubit/review_moderation_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockReportReviewUseCase reportReview;
  late MockBlockReviewAuthorUseCase blockAuthor;
  late MockGetModerationUseCase getModeration;

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
    reportReview = MockReportReviewUseCase();
    blockAuthor = MockBlockReviewAuthorUseCase();
    getModeration = MockGetModerationUseCase();

    when(() => getModeration.call()).thenAnswer((_) async => (blockedAuthors: <String>{}, hiddenReviewIds: <String>{}));
    when(() => reportReview.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
    when(() => blockAuthor.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(unit));
  });

  ReviewModerationCubit build() => ReviewModerationCubit(reportReview, blockAuthor, getModeration);

  group('on creation', () {
    blocTest<ReviewModerationCubit, ReviewModerationState>(
      'picks up what was already hidden on this device',
      setUp: () => when(() => getModeration.call()).thenAnswer((_) async => (blockedAuthors: {'Sam'}, hiddenReviewIds: {'r9'})),
      build: build,
      expect: () => const [
        ReviewModerationState(blockedAuthors: {'Sam'}, hiddenReviewIds: {'r9'}),
      ],
    );
  });

  group('report', () {
    blocTest<ReviewModerationCubit, ReviewModerationState>(
      'hides the review it filed a report about',
      build: build,
      act: (cubit) => cubit.report(report),
      skip: 1,
      expect: () => const [
        ReviewModerationState(hiddenReviewIds: {'r1'}),
      ],
    );

    test('says whether the report was filed', () async {
      final cubit = build();
      expect(await cubit.report(report), isTrue);

      when(() => reportReview.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      expect(await cubit.report(report), isFalse);
    });

    blocTest<ReviewModerationCubit, ReviewModerationState>(
      'leaves the review on screen when the report could not be filed',
      setUp: () => when(() => reportReview.call(params: any(named: 'params'))).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      build: build,
      act: (cubit) => cubit.report(report),
      skip: 1,
      expect: () => const <ReviewModerationState>[],
    );
  });

  group('blockAuthor', () {
    blocTest<ReviewModerationCubit, ReviewModerationState>(
      'adds the author to the blocked set',
      build: build,
      act: (cubit) => cubit.blockAuthor('Cat'),
      skip: 1,
      expect: () => const [
        ReviewModerationState(blockedAuthors: {'Cat'}),
      ],
    );
  });

  group('visible', () {
    const cat = ReviewEntity(id: 'r1', authorName: 'Cat', content: 'Good.');
    const sam = ReviewEntity(id: 'r2', authorName: 'Sam', content: 'Better.');

    test('keeps everything when nothing is hidden', () {
      expect(const ReviewModerationState().visible(const [cat, sam]), const [cat, sam]);
    });

    test('drops a reported review by its id', () {
      const state = ReviewModerationState(hiddenReviewIds: {'r1'});

      expect(state.visible(const [cat, sam]), const [sam]);
    });

    test('drops every review by a blocked author', () {
      const state = ReviewModerationState(blockedAuthors: {'Cat'});

      expect(state.visible(const [cat, sam]), const [sam]);
    });
  });
}
