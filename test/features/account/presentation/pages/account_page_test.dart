import 'package:filmio/core/cubit/session_cubit.dart';
import 'package:filmio/core/custom/custom_button.dart';
import 'package:filmio/core/custom/poster_card.dart';
import 'package:filmio/features/account/presentation/cubit/account_cubit.dart';
import 'package:filmio/features/account/presentation/pages/account_page.dart';
import 'package:filmio/features/account/presentation/widgets/taste_profile_card.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/domain/usecases/get_liked_movies.dart';
import 'package:filmio/features/movie/domain/usecases/get_watchlist_movies.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/domain/usecases/get_liked_series.dart';
import 'package:filmio/features/series/domain/usecases/get_watchlist_series.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_di.dart';

/// Asserts what the tab puts in front of an account and in front of a guest,
/// and that the rows survive a list that could not be read. Deliberately says
/// nothing about padding, colours, or font sizes.
void main() {
  late MockGetLikedMoviesUseCase getLikedMovies;
  late MockGetLikedSeriesUseCase getLikedSeries;
  late MockGetWatchlistMoviesUseCase getWatchlistMovies;
  late MockGetWatchlistSeriesUseCase getWatchlistSeries;
  late MockGetProfileUseCase getProfile;
  late MockIsGuestUseCase isGuest;

  const movie = MovieEntity(id: 1, title: 'Film', posterPath: '/a.jpg', genreIds: [18], releaseDate: '1994-09-10', voteAverage: 9);
  const series = SeriesEntity(id: 2, name: 'Show', posterPath: '/b.jpg', genreIds: [18], firstAirDate: '1998-01-20', voteAverage: 8);

  setUp(() {
    getLikedMovies = MockGetLikedMoviesUseCase();
    getLikedSeries = MockGetLikedSeriesUseCase();
    getWatchlistMovies = MockGetWatchlistMoviesUseCase();
    getWatchlistSeries = MockGetWatchlistSeriesUseCase();
    getProfile = MockGetProfileUseCase();
    isGuest = MockIsGuestUseCase();

    when(() => getLikedMovies.call()).thenAnswer((_) async => const Right([movie]));
    when(() => getLikedSeries.call()).thenAnswer((_) async => const Right([series]));
    when(() => getWatchlistMovies.call()).thenAnswer((_) async => const Right([movie]));
    when(() => getWatchlistSeries.call()).thenAnswer((_) async => const Right(<SeriesEntity>[]));
    when(() => getProfile.call()).thenAnswer((_) async => (name: 'Ada', email: 'ada@example.com', photoUrl: null));
    when(() => isGuest.call()).thenAnswer((_) async => false);

    registerTestSingleton<GetLikedMoviesUseCase>(getLikedMovies);
    registerTestSingleton<GetLikedSeriesUseCase>(getLikedSeries);
    registerTestSingleton<GetWatchlistMoviesUseCase>(getWatchlistMovies);
    registerTestSingleton<GetWatchlistSeriesUseCase>(getWatchlistSeries);
  });

  tearDown(resetTestDependencies);

  Future<void> pumpTab(WidgetTester tester) async {
    await tester.pumpApp(
      const AccountPage(),
      providers: [
        BlocProvider<SessionCubit>(
          create: (context) => SessionCubit(isGuest, MockContinueAsGuestUseCase(), MockEndGuestSessionUseCase()),
        ),
        BlocProvider<AccountCubit>(create: (context) => AccountCubit(getProfile)),
      ],
    );

    // Not `pumpAndSettle`: a cover's placeholder is a shimmer, and a shimmer
    // never settles. These pumps are long enough for the cubits to answer.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('with an account', () {
    testWidgets('shows who is signed in', (tester) async {
      await pumpTab(tester);

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
    });

    testWidgets('opens all four lists', (tester) async {
      await pumpTab(tester);

      expect(find.text('Liked Movies'), findsOneWidget);
      expect(find.text('Liked Series'), findsOneWidget);
      expect(find.text('Films to Watch'), findsOneWidget);
      expect(find.text('Series to Watch'), findsOneWidget);
    });

    testWidgets('says what the lists add up to', (tester) async {
      await pumpTab(tester);

      expect(find.byType(TasteProfileCard), findsOneWidget);
      // One liked film and one liked series, both Drama.
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('counts each list on the row that opens it', (tester) async {
      await pumpTab(tester);

      // Three lists hold one title and the fourth is empty.
      expect(find.text('1 title'), findsNWidgets(3));
      expect(find.text('No titles'), findsOneWidget);
    });

    testWidgets('previews the covers of the lists that have any', (tester) async {
      await pumpTab(tester);

      // One cover each for the three non-empty lists; the empty one shows
      // none rather than a placeholder.
      expect(find.byType(PosterCard), findsNWidgets(3));
    });
  });

  group('when a list cannot be read', () {
    setUp(() => when(() => getLikedSeries.call()).thenAnswer((_) async => const Left(NetworkFailure('offline'))));

    testWidgets('the rows still open, without the detail', (tester) async {
      await pumpTab(tester);

      // The tab's job is getting to the lists, and the screen behind each row
      // is where a failure is reported properly.
      expect(find.text('Liked Movies'), findsOneWidget);
      expect(find.text('Series to Watch'), findsOneWidget);

      // No figures it cannot stand behind, and no covers.
      expect(find.byType(TasteProfileCard), findsNothing);
      expect(find.byType(PosterCard), findsNothing);
      expect(find.text('1 title'), findsNothing);
    });
  });

  group('as a guest', () {
    setUp(() => when(() => isGuest.call()).thenAnswer((_) async => true));

    testWidgets('is invited to create an account instead of shown empty lists', (tester) async {
      await pumpTab(tester);

      expect(find.byType(CustomButton), findsOneWidget);
      expect(find.text('Liked Movies'), findsNothing);
      expect(find.byType(TasteProfileCard), findsNothing);
    });
  });
}
