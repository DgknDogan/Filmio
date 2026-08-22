import 'package:filmio/core/custom/poster_card.dart';
import 'package:filmio/core/enums/discover_sort.dart';
import 'package:filmio/core/models/discover_filters.dart';
import 'package:filmio/core/models/paginated_list.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/domain/usecases/discover_movies.dart';
import 'package:filmio/features/movie/presentation/pages/movie_discover_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_di.dart';

/// Asserts what each state puts on screen, that the filter sheet reaches the
/// cubit, and that scrolling to the end asks for the next page. Deliberately
/// says nothing about padding, colours, or font sizes.
void main() {
  late MockDiscoverMoviesUseCase discover;

  List<MovieEntity> titles(int count, {int from = 0}) => [
        for (var index = from; index < from + count; index++) MovieEntity(id: index, title: 'Film $index', posterPath: '/$index.jpg'),
      ];

  PaginatedList<MovieEntity> page(
    List<MovieEntity> items, {
    int page = 1,
    int totalPages = 1,
    int totalResults = 1,
  }) =>
      PaginatedList(items: items, page: page, totalPages: totalPages, totalResults: totalResults);

  void stub(Either<Failure, PaginatedList<MovieEntity>> result) {
    when(() => discover.call(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  void stubPerPage(Map<int, Either<Failure, PaginatedList<MovieEntity>>> results) {
    when(() => discover.call(params: any(named: 'params'))).thenAnswer((invocation) async {
      final params = invocation.namedArguments[#params] as DiscoverMoviesParams;
      return results[params.page]!;
    });
  }

  setUpAll(registerCommonFallbacks);

  setUp(() {
    discover = MockDiscoverMoviesUseCase();
    stub(Right(page(titles(6), totalResults: 6)));
    // The page builds its own cubit from get_it, so the container has to be
    // standing before it is pumped.
    registerTestSingleton<DiscoverMoviesUseCase>(discover);
  });

  tearDown(resetTestDependencies);

  /// The posters are remote images and `AppNetworkImage` shimmers while they
  /// load — a placeholder that animates for ever — so this settles the state
  /// change by hand rather than waiting for a tree that never stops.
  Future<void> settle(WidgetTester tester) => tester.pump(const Duration(milliseconds: 50));

  /// The sheet's own open and close animation. `pumpAndSettle` cannot be used
  /// anywhere on this screen for the same reason as above.
  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pumpPage(WidgetTester tester, {DiscoverSort sort = DiscoverSort.popularity}) async {
    await tester.pumpApp(MovieDiscoverPage(title: 'Popular Movies', sort: sort));
    await settle(tester);
  }

  testWidgets('opens on the row it continues, and says how many titles there are', (tester) async {
    await pumpPage(tester);

    expect(find.text('Popular Movies'), findsOneWidget);
    expect(find.text('6 TITLES'), findsOneWidget);
  });

  testWidgets('a failed first page can be retried', (tester) async {
    stub(const Left(NetworkFailure('offline')));

    await pumpPage(tester);
    expect(find.text('offline'), findsOneWidget);

    stub(Right(page(titles(3), totalResults: 3)));
    await tester.tap(find.text('Try again'));
    await settle(tester);

    // The poster carries no text of its own, so the grid is counted rather
    // than read.
    expect(find.byType(PosterCard), findsNWidgets(3));
  });

  testWidgets('filters that match nothing say so rather than showing an empty grid', (tester) async {
    stub(Right(page(const [], totalResults: 0)));

    await pumpPage(tester);

    expect(find.text('Nothing matches these filters.'), findsOneWidget);
  });

  group('the filter sheet', () {
    testWidgets('opens on the filter control and applies what was chosen', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('FILTER'));
      await settleSheet(tester);

      expect(find.text('Filters'), findsOneWidget);
      // The sheet's own headings, which `SheetSectionLabel` upper-cases.
      expect(find.text('GENRE'), findsOneWidget);
      expect(find.text('RATING'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);

      // Action is the first film genre TMDB lists.
      await tester.tap(find.text('Action'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await settleSheet(tester);
      await settle(tester);

      verify(
        () => discover.call(
          params: const DiscoverMoviesParams(
            filters: DiscoverFilters(genreIds: {28}),
            sort: DiscoverSort.popularity,
            page: 1,
          ),
        ),
      ).called(1);
      // The control says how many filters are in force.
      expect(find.text('FILTER (1)'), findsOneWidget);
    });

    testWidgets('backing out of the sheet leaves the filters alone', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('FILTER'));
      await settleSheet(tester);
      // Dismissed rather than applied.
      Navigator.of(tester.element(find.text('Filters'))).pop();
      await settleSheet(tester);

      verify(() => discover.call(params: any(named: 'params'))).called(1);
      expect(find.text('FILTER'), findsOneWidget);
    });
  });

  testWidgets('scrolling to the end of the grid asks for the next page', (tester) async {
    stubPerPage({
      1: Right(page(titles(20), page: 1, totalPages: 3, totalResults: 60)),
      2: Right(page(titles(20, from: 20), page: 2, totalPages: 3, totalResults: 60)),
      // One long drag can carry the reader through more than one page.
      3: Right(page(titles(20, from: 40), page: 3, totalPages: 3, totalResults: 60)),
    });

    await pumpPage(tester);
    expect(find.byType(PosterCard), findsWidgets);

    // The grid is a `SliverGrid` in a `CustomScrollView`, not a `GridView`.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await settle(tester);

    verify(
      () => discover.call(
        params: const DiscoverMoviesParams(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 2),
      ),
    ).called(1);
  });
}
