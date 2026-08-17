import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/domain/usecases/search_movies.dart';
import 'package:filmio/features/movie/presentation/pages/movie_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_di.dart';

/// Asserts what each state puts on screen and that typing reaches the cubit.
/// Deliberately says nothing about padding, colours, or font sizes.
void main() {
  late MockSearchMoviesUseCase searchMovies;

  const movie = MovieEntity(id: 1, title: 'The Matrix', posterPath: '/a.jpg');

  setUp(() {
    searchMovies = MockSearchMoviesUseCase();
    // The page builds its own SearchBloc from get_it, so the container has to
    // be standing before it is pumped.
    registerTestSingleton<SearchMoviesUseCase>(searchMovies);
  });

  tearDown(resetTestDependencies);

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpApp(const MovieSearchPage(heroTag: 'search', hintText: 'Search a movie'));
    // initState schedules the focus request 250ms out; leaving it pending fails
    // the test with "a Timer is still pending".
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Types, then lets the bloc's 300ms debounce elapse and the request settle.
  /// Pumping only a frame or two leaves the query sitting in the transformer.
  Future<void> type(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
  }

  testWidgets('starts with nothing but the search field', (tester) async {
    await pumpPage(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('typing reaches the bloc and renders the results', (tester) async {
    when(() => searchMovies.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([movie]));

    await pumpPage(tester);
    await type(tester, 'matrix');

    verify(() => searchMovies.call(params: 'matrix')).called(1);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('a query still being typed does not reach the API', (tester) async {
    when(() => searchMovies.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([movie]));

    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'mat');
    // Inside the debounce window: the keystroke has been reported but nothing
    // should have been asked for yet.
    await tester.pump(const Duration(milliseconds: 100));

    verifyNever(() => searchMovies.call(params: any(named: 'params')));

    // Let it settle so no Timer is left pending when the test ends.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
  });

  testWidgets('an empty result says so rather than showing a blank grid', (tester) async {
    when(() => searchMovies.call(params: any(named: 'params'))).thenAnswer((_) async => const Right(<MovieEntity>[]));

    await pumpPage(tester);
    await type(tester, 'zzzz');

    expect(find.text('No results found.'), findsOneWidget);
  });

  testWidgets('a failure shows the message and offers a retry', (tester) async {
    when(() => searchMovies.call(params: any(named: 'params')))
        .thenAnswer((_) async => const Left(NetworkFailure('No internet connection.')));

    await pumpPage(tester);
    await type(tester, 'matrix');

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('the retry button re-runs the same query without waiting out the debounce', (tester) async {
    when(() => searchMovies.call(params: any(named: 'params')))
        .thenAnswer((_) async => const Left(NetworkFailure('No internet connection.')));

    await pumpPage(tester);
    await type(tester, 'matrix');

    await tester.tap(find.text('Try again'));
    // No clock advance: a retry goes straight to the handler.
    await tester.pump();
    await tester.pump();

    verify(() => searchMovies.call(params: 'matrix')).called(2);
  });
}
