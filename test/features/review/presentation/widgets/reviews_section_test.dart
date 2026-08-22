import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/models/paginated_list.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/review/domain/entities/review_entity.dart';
import 'package:filmio/features/review/domain/usecases/get_reviews.dart';
import 'package:filmio/features/review/presentation/cubit/reviews_cubit.dart';
import 'package:filmio/features/review/presentation/widgets/review_card.dart';
import 'package:filmio/features/review/presentation/widgets/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

/// Asserts what each state puts on screen and that the paging controls reach
/// the cubit. Deliberately says nothing about padding, colours, or font sizes.
void main() {
  late MockGetReviewsUseCase getReviews;

  const first = ReviewEntity(id: 'r1', author: 'Cat', content: 'Good.', rating: 8);
  const second = ReviewEntity(id: 'r2', author: 'Sam', content: 'Better.');

  PaginatedList<ReviewEntity> page(
    List<ReviewEntity> items, {
    int page = 1,
    int totalPages = 1,
    int totalResults = 1,
  }) =>
      PaginatedList(items: items, page: page, totalPages: totalPages, totalResults: totalResults);

  void stubPerPage(Map<int, Either<Failure, PaginatedList<ReviewEntity>>> results) {
    when(() => getReviews.call(params: any(named: 'params'))).thenAnswer((invocation) async {
      final params = invocation.namedArguments[#params] as GetReviewsParams;
      return results[params.page]!;
    });
  }

  setUpAll(registerCommonFallbacks);

  setUp(() {
    getReviews = MockGetReviewsUseCase();
    stubPerPage({
      1: Right(page(const [first]))
    });
  });

  /// The section is one block of a details sheet, so a test gives it the
  /// scroll the sheet would have provided.
  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpApp(
      const Scaffold(body: SingleChildScrollView(child: ReviewsSection())),
      providers: [
        BlocProvider<ReviewsCubit>(
          create: (context) => ReviewsCubit(getReviews, mediaId: 550, mediaType: MediaType.movie),
        ),
      ],
    );
  }

  testWidgets('shows a spinner while the first page is in flight', (tester) async {
    await pumpSection(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('renders a card per review and how many there are in total', (tester) async {
    stubPerPage({
      1: Right(page(const [first, second], totalResults: 42))
    });

    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.byType(ReviewCard), findsNWidgets(2));
    expect(find.text('Good.'), findsOneWidget);
    expect(find.text('42 reviews'), findsOneWidget);
  });

  testWidgets('a title nobody has reviewed renders nothing at all', (tester) async {
    stubPerPage({1: Right(page(const [], totalResults: 0))});

    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.byType(ReviewCard), findsNothing);
    expect(find.text('Reviews'), findsNothing);
  });

  group('paging', () {
    testWidgets('offers the next page only while there is one', (tester) async {
      stubPerPage({
        1: Right(page(const [first], totalPages: 1))
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('Load more reviews'), findsNothing);
    });

    testWidgets('tapping load more appends the next page under the first', (tester) async {
      stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: Right(page(const [second], page: 2, totalPages: 2, totalResults: 2)),
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('Load more reviews'), findsOneWidget);
      await tester.tap(find.text('Load more reviews'));
      await tester.pumpAndSettle();

      verify(() => getReviews.call(
            params: const GetReviewsParams(mediaId: 550, mediaType: MediaType.movie, page: 2),
          )).called(1);
      // The first page is still there — the second was added to it.
      expect(find.byType(ReviewCard), findsNWidgets(2));
      expect(find.text('Good.'), findsOneWidget);
      expect(find.text('Better.'), findsOneWidget);
      // Nothing left to ask for.
      expect(find.text('Load more reviews'), findsNothing);
    });

    testWidgets('a failed next page keeps the reviews already on screen', (tester) async {
      stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: const Left(NetworkFailure('offline')),
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load more reviews'));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewCard), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('a failed first page', () {
    testWidgets('reports the failure instead of an empty block', (tester) async {
      stubPerPage({1: const Left(NetworkFailure('offline'))});

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('offline'), findsOneWidget);
      expect(find.byType(ReviewCard), findsNothing);
    });

    testWidgets('retrying asks for the first page again', (tester) async {
      stubPerPage({1: const Left(NetworkFailure('offline'))});

      await pumpSection(tester);
      await tester.pumpAndSettle();

      stubPerPage({
        1: Right(page(const [first]))
      });
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewCard), findsOneWidget);
    });
  });

  group('a review too long to show whole', () {
    // Long enough to be cut off after five lines, short enough that the open
    // form still fits the test viewport.
    final longReview = ReviewEntity(id: 'r3', author: 'Cat', content: 'Long. ' * 40);

    testWidgets('opens on a tap and closes again', (tester) async {
      stubPerPage({
        1: Right(page([longReview]))
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);

      await tester.ensureVisible(find.text('Show less'));
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('a review short enough to fit is not offered one', (tester) async {
      stubPerPage({
        1: Right(page(const [first]))
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsNothing);
    });
  });
}
