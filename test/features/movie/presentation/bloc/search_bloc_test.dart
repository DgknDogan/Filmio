import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/movie/presentation/bloc/search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// Everything here has to outlast the 300ms debounce, so each case gives
/// `blocTest` a `wait` longer than it.
void main() {
  late MockSearchMoviesUseCase useCase;

  const withPoster = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');
  const withoutPoster = MovieEntity(id: 2, title: 'B');

  /// Comfortably past the debounce, so a settled bloc has finished its work.
  const settle = Duration(milliseconds: 450);

  setUp(() => useCase = MockSearchMoviesUseCase());

  SearchBloc build() => SearchBloc(useCase);

  group('debounce', () {
    blocTest<SearchBloc, SearchState>(
      'a burst of keystrokes becomes one request, for the last of them',
      build: build,
      setUp: () =>
          when(() => useCase.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([withPoster])),
      act: (bloc) async {
        // "matr" typed quickly — four events, well inside the window.
        for (final query in ['m', 'ma', 'mat', 'matr']) {
          bloc.add(SearchQueryChanged(query));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      },
      wait: settle,
      verify: (bloc) {
        verify(() => useCase.call(params: 'matr')).called(1);
        verifyNever(() => useCase.call(params: 'm'));
        verifyNever(() => useCase.call(params: 'ma'));
        verifyNever(() => useCase.call(params: 'mat'));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'typing that pauses long enough searches twice',
      build: build,
      setUp: () =>
          when(() => useCase.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([withPoster])),
      act: (bloc) async {
        bloc.add(const SearchQueryChanged('first'));
        await Future<void>.delayed(settle);
        bloc.add(const SearchQueryChanged('second'));
      },
      wait: settle,
      verify: (bloc) {
        verify(() => useCase.call(params: 'first')).called(1);
        verify(() => useCase.call(params: 'second')).called(1);
      },
    );
  });

  blocTest<SearchBloc, SearchState>(
    'clearing the query resets to empty without asking the API',
    build: build,
    act: (bloc) => bloc.add(const SearchQueryChanged('')),
    wait: settle,
    // bloc lets the very first emit through even when it equals the initial
    // state, so this records one SearchInitial rather than nothing.
    expect: () => const [SearchInitial()],
    verify: (bloc) => verifyNever(() => useCase.call(params: any(named: 'params'))),
  );

  blocTest<SearchBloc, SearchState>(
    'emits loading then results, dropping titles with no poster',
    build: build,
    setUp: () => when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => const Right([withPoster, withoutPoster])),
    act: (bloc) => bloc.add(const SearchQueryChanged('matrix')),
    wait: settle,
    expect: () => const [
      SearchLoading(),
      SearchLoaded([withPoster]),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'surfaces the failure message instead of silently keeping the old results',
    build: build,
    setUp: () => when(() => useCase.call(params: any(named: 'params')))
        .thenAnswer((_) async => const Left(NetworkFailure('offline'))),
    act: (bloc) => bloc.add(const SearchQueryChanged('matrix')),
    wait: settle,
    expect: () => const [
      SearchLoading(),
      SearchFailure('offline'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'a slow earlier response cannot overwrite a faster later one',
    build: build,
    setUp: () {
      when(() => useCase.call(params: 'slow')).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 300), () => const Right([withPoster])),
      );
      when(() => useCase.call(params: 'fast')).thenAnswer((_) async => const Right(<MovieEntity>[]));
    },
    act: (bloc) async {
      // Both get past the debounce, so it is `switchMap` that has to discard
      // the first one's answer.
      bloc.add(const SearchQueryChanged('slow'));
      await Future<void>.delayed(settle);
      bloc.add(const SearchQueryChanged('fast'));
    },
    wait: const Duration(milliseconds: 900),
    verify: (bloc) {
      expect(bloc.state, const SearchLoaded(<MovieEntity>[]), reason: 'the stale response must be discarded');
    },
  );

  blocTest<SearchBloc, SearchState>(
    'a retry skips the debounce — the reader already waited once',
    build: build,
    setUp: () =>
        when(() => useCase.call(params: any(named: 'params'))).thenAnswer((_) async => const Right([withPoster])),
    act: (bloc) => bloc.add(const SearchRetried('matrix')),
    // Far shorter than the debounce: if the retry went through the transformer
    // nothing would have happened yet.
    wait: const Duration(milliseconds: 60),
    verify: (bloc) => verify(() => useCase.call(params: 'matrix')).called(1),
  );
}
