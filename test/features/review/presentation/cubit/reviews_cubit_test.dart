import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/cubit/load_more_state.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/models/paginated_list.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/review/domain/entities/review_entity.dart';
import 'package:filmio/features/review/domain/usecases/get_reviews.dart';
import 'package:filmio/features/review/presentation/cubit/reviews_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetReviewsUseCase getReviews;

  const first = ReviewEntity(id: 'r1', author: 'Cat', content: 'Good.');
  const second = ReviewEntity(id: 'r2', author: 'Sam', content: 'Better.');

  PaginatedList<ReviewEntity> page(
    List<ReviewEntity> items, {
    int page = 1,
    int totalPages = 1,
    int totalResults = 1,
  }) =>
      PaginatedList(items: items, page: page, totalPages: totalPages, totalResults: totalResults);

  void stub(Either<Failure, PaginatedList<ReviewEntity>> result) {
    when(() => getReviews.call(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  /// Answers each page with its own result, so an appending list can be told
  /// apart from one that replaces what it has.
  void stubPerPage(Map<int, Either<Failure, PaginatedList<ReviewEntity>>> results) {
    when(() => getReviews.call(params: any(named: 'params'))).thenAnswer((invocation) async {
      final params = invocation.namedArguments[#params] as GetReviewsParams;
      return results[params.page]!;
    });
  }

  /// `blocTest` runs `act` before `wait`, so a test that acts on a loaded list
  /// has to let the first page — which the constructor asks for — land first.
  Future<void> firstPageLanded() => Future<void>.delayed(Duration.zero);

  setUpAll(registerCommonFallbacks);

  setUp(() {
    getReviews = MockGetReviewsUseCase();
    stub(Right(page(const [first])));
  });

  ReviewsCubit build({int? mediaId = 550, MediaType mediaType = MediaType.movie}) => ReviewsCubit(getReviews, mediaId: mediaId, mediaType: mediaType);

  group('the first page', () {
    test('is asked for as soon as the cubit exists', () async {
      final cubit = build();
      await Future<void>.delayed(Duration.zero);

      verify(() => getReviews.call(
            params: const GetReviewsParams(mediaId: 550, mediaType: MediaType.movie, page: 1),
          )).called(1);
      await cubit.close();
    });

    test('asks against the series catalogue for a series', () async {
      final cubit = build(mediaId: 1399, mediaType: MediaType.series);
      await Future<void>.delayed(Duration.zero);

      verify(() => getReviews.call(
            params: const GetReviewsParams(mediaId: 1399, mediaType: MediaType.series, page: 1),
          )).called(1);
      await cubit.close();
    });

    blocTest<ReviewsCubit, ReviewsState>(
      'lands as a loaded list carrying the paging numbers',
      build: build,
      setUp: () => stub(Right(page(const [first], page: 1, totalPages: 3, totalResults: 42))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        final state = cubit.state as ReviewsLoaded;
        expect(state.reviews, const [first]);
        expect(state.totalResults, 42);
        expect(state.hasMore, isTrue);
        expect(state.more, const LoadMoreIdle());
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'a failure is distinguishable from an empty list',
      build: build,
      setUp: () => stub(const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state, const ReviewsFailure('offline')),
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'a title with no id is an empty list rather than a request',
      build: () => build(mediaId: null),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        expect(cubit.state, isA<ReviewsLoaded>());
        expect((cubit.state as ReviewsLoaded).reviews, isEmpty);
        verifyNever(() => getReviews.call(params: any(named: 'params')));
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'retrying after a failure asks again',
      build: build,
      setUp: () => stub(const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        stub(Right(page(const [first])));
        await cubit.loadFirstPage();
      },
      verify: (cubit) => expect((cubit.state as ReviewsLoaded).reviews, const [first]),
    );
  });

  group('loading more', () {
    blocTest<ReviewsCubit, ReviewsState>(
      'appends the next page instead of replacing what is on screen',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: Right(page(const [second], page: 2, totalPages: 2, totalResults: 2)),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
      },
      verify: (cubit) {
        final state = cubit.state as ReviewsLoaded;
        expect(state.reviews, const [first, second]);
        expect(state.page, 2);
        expect(state.hasMore, isFalse);
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'says it is fetching while the page is in flight',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: Right(page(const [second], page: 2, totalPages: 2, totalResults: 2)),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
      },
      expect: () => [
        isA<ReviewsLoaded>().having((state) => state.more, 'more', const LoadMoreIdle()),
        isA<ReviewsLoaded>().having((state) => state.more, 'more', const LoadMoreInProgress()),
        isA<ReviewsLoaded>().having((state) => state.reviews, 'reviews', const [first, second]),
      ],
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'does not ask for a page past the last one',
      build: build,
      setUp: () => stub(Right(page(const [first], page: 1, totalPages: 1, totalResults: 1))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
      },
      verify: (_) => verify(() => getReviews.call(params: any(named: 'params'))).called(1),
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'a second tap while a page is in flight does not ask twice',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 3, totalResults: 3)),
        2: Right(page(const [second], page: 2, totalPages: 3, totalResults: 3)),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        final firstTap = cubit.loadMore();
        await cubit.loadMore();
        await firstTap;
      },
      verify: (_) {
        verify(() => getReviews.call(
              params: const GetReviewsParams(mediaId: 550, mediaType: MediaType.movie, page: 2),
            )).called(1);
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'a failed page keeps the reviews already read and reports it at the foot',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: const Left(NetworkFailure('offline')),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
      },
      verify: (cubit) {
        final state = cubit.state as ReviewsLoaded;
        expect(state.reviews, const [first]);
        expect(state.more, const LoadMoreFailure('offline'));
        // Still page one, so the retry asks for two again rather than three.
        expect(state.page, 1);
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'retrying after a failed page asks for that same page again',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: const Left(NetworkFailure('offline')),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
        stubPerPage({
          2: Right(page(const [second], page: 2, totalPages: 2, totalResults: 2))
        });
        await cubit.loadMore();
      },
      verify: (cubit) => expect((cubit.state as ReviewsLoaded).reviews, const [first, second]),
    );
  });
}
