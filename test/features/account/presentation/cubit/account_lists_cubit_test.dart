import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/account/presentation/cubit/account_lists_cubit.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetLikedMoviesUseCase getLikedMovies;
  late MockGetLikedSeriesUseCase getLikedSeries;
  late MockGetWatchlistMoviesUseCase getWatchlistMovies;
  late MockGetWatchlistSeriesUseCase getWatchlistSeries;

  const movie = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg', genreIds: [18], releaseDate: '1994-09-10', voteAverage: 9);
  const series = SeriesEntity(id: 2, name: 'B', posterPath: '/b.jpg', genreIds: [18], firstAirDate: '2008-01-20', voteAverage: 9);

  setUp(() {
    getLikedMovies = MockGetLikedMoviesUseCase();
    getLikedSeries = MockGetLikedSeriesUseCase();
    getWatchlistMovies = MockGetWatchlistMoviesUseCase();
    getWatchlistSeries = MockGetWatchlistSeriesUseCase();

    when(() => getLikedMovies.call()).thenAnswer((_) async => const Right([movie]));
    when(() => getLikedSeries.call()).thenAnswer((_) async => const Right([series]));
    when(() => getWatchlistMovies.call()).thenAnswer((_) async => const Right([movie]));
    when(() => getWatchlistSeries.call()).thenAnswer((_) async => const Right([series]));
  });

  AccountListsCubit build() {
    return AccountListsCubit(getLikedMovies, getLikedSeries, getWatchlistMovies, getWatchlistSeries);
  }

  blocTest<AccountListsCubit, AccountListsState>(
    'reads all four lists on construction',
    build: build,
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      verify(() => getLikedMovies.call()).called(1);
      verify(() => getLikedSeries.call()).called(1);
      verify(() => getWatchlistMovies.call()).called(1);
      verify(() => getWatchlistSeries.call()).called(1);
    },
  );

  blocTest<AccountListsCubit, AccountListsState>(
    'carries the lists and the profile they add up to',
    build: build,
    wait: const Duration(milliseconds: 10),
    verify: (cubit) {
      final state = cubit.state as AccountListsLoaded;

      expect(state.likedMovies, const [movie]);
      expect(state.watchlistSeries, const [series]);
      // Derived from the lists just read, so the two cannot disagree. The
      // film and the series are a decade each, and a tie goes to the later
      // one — which `TasteProfile`'s own test is where that is pinned down.
      expect(state.profile.likedMovies, 1);
      expect(state.profile.likedSeries, 1);
      expect(state.profile.topGenres, ['Drama']);
      expect(state.profile.favouriteDecade, '2000s');
    },
  );

  blocTest<AccountListsCubit, AccountListsState>(
    'empty lists are a loaded state with an empty profile',
    build: build,
    setUp: () {
      when(() => getLikedMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[]));
      when(() => getLikedSeries.call()).thenAnswer((_) async => const Right(<SeriesEntity>[]));
      when(() => getWatchlistMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[]));
      when(() => getWatchlistSeries.call()).thenAnswer((_) async => const Right(<SeriesEntity>[]));
    },
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect((cubit.state as AccountListsLoaded).profile.isEmpty, isTrue),
  );

  group('when a read fails', () {
    /// The figures would be wrong rather than missing: a profile saying "no
    /// series liked" because one read did not come back describes somebody
    /// else. So the tab drops the detail rather than printing a number it
    /// cannot stand behind.
    blocTest<AccountListsCubit, AccountListsState>(
      'the lists are unavailable rather than partly right',
      build: build,
      setUp: () => when(() => getLikedSeries.call()).thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state, const AccountListsUnavailable()),
    );

    blocTest<AccountListsCubit, AccountListsState>(
      'a guest, who has no lists at all, is the same case',
      build: build,
      setUp: () {
        const signedOut = Left<Failure, List<Never>>(AuthFailure('Sign in to keep the titles you like.'));
        when(() => getLikedMovies.call()).thenAnswer((_) async => signedOut);
        when(() => getLikedSeries.call()).thenAnswer((_) async => signedOut);
        when(() => getWatchlistMovies.call()).thenAnswer((_) async => signedOut);
        when(() => getWatchlistSeries.call()).thenAnswer((_) async => signedOut);
      },
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state, const AccountListsUnavailable()),
    );
  });

  blocTest<AccountListsCubit, AccountListsState>(
    'load reads again, so coming back from a list screen picks up a change',
    build: build,
    act: (cubit) async {
      when(() => getLikedMovies.call()).thenAnswer((_) async => const Right(<MovieEntity>[]));
      await cubit.load();
    },
    wait: const Duration(milliseconds: 10),
    verify: (cubit) => expect((cubit.state as AccountListsLoaded).profile.likedMovies, 0),
  );
}
