import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/cubit/load_more_state.dart';
import 'package:filmio/core/enums/discover_sort.dart';
import 'package:filmio/core/models/discover_filters.dart';
import 'package:filmio/core/models/paginated_list.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/domain/usecases/discover_series.dart';
import 'package:filmio/features/series/presentation/cubit/series_discover_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDiscoverSeriesUseCase discover;

  const first = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');
  const second = SeriesEntity(id: 2, name: 'B', posterPath: '/b.jpg');

  PaginatedList<SeriesEntity> page(
    List<SeriesEntity> items, {
    int page = 1,
    int totalPages = 1,
    int totalResults = 1,
  }) =>
      PaginatedList(items: items, page: page, totalPages: totalPages, totalResults: totalResults);

  void stub(Either<Failure, PaginatedList<SeriesEntity>> result) {
    when(() => discover.call(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  /// Answers each page with its own result, so an appending grid can be told
  /// apart from one that replaces what it has.
  void stubPerPage(Map<int, Either<Failure, PaginatedList<SeriesEntity>>> results) {
    when(() => discover.call(params: any(named: 'params'))).thenAnswer((invocation) async {
      final params = invocation.namedArguments[#params] as DiscoverSeriesParams;
      return results[params.page]!;
    });
  }

  /// `blocTest` runs `act` before `wait`, so a test that acts on a loaded grid
  /// has to let the first page — which the constructor asks for — land first.
  Future<void> firstPageLanded() => Future<void>.delayed(Duration.zero);

  setUpAll(registerCommonFallbacks);

  setUp(() {
    discover = MockDiscoverSeriesUseCase();
    stub(Right(page(const [first])));
  });

  SeriesDiscoverCubit build({DiscoverSort sort = DiscoverSort.popularity}) => SeriesDiscoverCubit(discover, sort: sort);

  group('the first page', () {
    test('is asked for as soon as the cubit exists, unfiltered', () async {
      final cubit = build();
      await firstPageLanded();

      verify(
        () => discover.call(
          params: const DiscoverSeriesParams(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 1),
        ),
      ).called(1);
      await cubit.close();
    });

    test('carries the order of the row it was opened from', () async {
      final cubit = build(sort: DiscoverSort.topRated);
      await firstPageLanded();

      verify(
        () => discover.call(
          params: const DiscoverSeriesParams(filters: DiscoverFilters.none, sort: DiscoverSort.topRated, page: 1),
        ),
      ).called(1);
      await cubit.close();
    });

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'lands as a loaded grid carrying the paging numbers',
      build: build,
      setUp: () => stub(Right(page(const [first], page: 1, totalPages: 9, totalResults: 170))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        final state = cubit.state as SeriesDiscoverLoaded;
        expect(state.series, const [first]);
        expect(state.totalResults, 170);
        expect(state.hasMore, isTrue);
        expect(state.more, const LoadMoreIdle());
      },
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'a failure is distinguishable from an empty catalogue',
      build: build,
      setUp: () => stub(const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state, isA<SeriesDiscoverFailure>()),
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'retrying after a failure asks again',
      build: build,
      setUp: () => stub(const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        stub(Right(page(const [first])));
        await cubit.loadFirstPage();
      },
      verify: (cubit) => expect((cubit.state as SeriesDiscoverLoaded).series, const [first]),
    );
  });

  group('paging', () {
    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
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
        final state = cubit.state as SeriesDiscoverLoaded;
        expect(state.series, const [first, second]);
        expect(state.page, 2);
        expect(state.hasMore, isFalse);
      },
    );

    // The grid asks on every frame it is near the end, so this guard is what
    // stands between one scroll and a dozen identical requests.
    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'asks once however many times the scroll asks while a page is in flight',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 5, totalResults: 90)),
        2: Right(page(const [second], page: 2, totalPages: 5, totalResults: 90)),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        final asks = [cubit.loadMore(), cubit.loadMore(), cubit.loadMore()];
        await Future.wait(asks);
      },
      verify: (_) {
        verify(
          () => discover.call(
            params: const DiscoverSeriesParams(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 2),
          ),
        ).called(1);
      },
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'does not ask for a page past the last one',
      build: build,
      setUp: () => stub(Right(page(const [first], page: 1, totalPages: 1, totalResults: 1))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
      },
      verify: (_) => verify(() => discover.call(params: any(named: 'params'))).called(1),
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'a failed page keeps what has been read and reports it at the foot',
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
        final state = cubit.state as SeriesDiscoverLoaded;
        expect(state.series, const [first]);
        expect(state.more, const LoadMoreFailure('offline'));
        // Still page one, so the retry asks for two again rather than three.
        expect(state.page, 1);
      },
    );
  });

  group('filters', () {
    const filtered = DiscoverFilters(genreIds: {18}, minRating: 7);

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'a new filter asks again from the first page',
      build: build,
      setUp: () => stub(Right(page(const [first], page: 1, totalPages: 3, totalResults: 50))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.applyFilters(filtered);
      },
      verify: (cubit) {
        verify(
          () => discover.call(
            params: const DiscoverSeriesParams(filters: filtered, sort: DiscoverSort.popularity, page: 1),
          ),
        ).called(1);
        expect(cubit.state.filters, filtered);
      },
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'a new filter replaces the pages already read rather than adding to them',
      build: build,
      setUp: () => stubPerPage({
        1: Right(page(const [first], page: 1, totalPages: 2, totalResults: 2)),
        2: Right(page(const [second], page: 2, totalPages: 2, totalResults: 2)),
      }),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.loadMore();
        stubPerPage({
          1: Right(page(const [second], page: 1, totalPages: 1, totalResults: 1))
        });
        await cubit.applyFilters(filtered);
      },
      verify: (cubit) => expect((cubit.state as SeriesDiscoverLoaded).series, const [second]),
    );

    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'applying the filters already in force changes nothing',
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.applyFilters(DiscoverFilters.none);
      },
      verify: (_) => verify(() => discover.call(params: any(named: 'params'))).called(1),
    );

    // The sheet has to open on what is in force even while the first page of a
    // new filter is still in the air.
    blocTest<SeriesDiscoverCubit, SeriesDiscoverState>(
      'the filters survive every phase, including loading and failure',
      build: build,
      setUp: () => stub(const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        await firstPageLanded();
        await cubit.applyFilters(filtered);
      },
      verify: (cubit) {
        expect(cubit.state, isA<SeriesDiscoverFailure>());
        expect(cubit.state.filters, filtered);
      },
    );
  });
}
