import 'package:dio/dio.dart';
import 'package:filmio/core/enums/discover_sort.dart';
import 'package:filmio/core/models/genre_model.dart';
import 'package:filmio/core/models/discover_filters.dart';
import 'package:filmio/core/network/discover_query.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/data/models/movie_api_response.dart';
import 'package:filmio/features/movie/data/models/movie_detail_model.dart';
import 'package:filmio/features/movie/data/models/movie_model.dart';
import 'package:filmio/features/movie/data/models/movie_recommendation_response.dart';
import 'package:filmio/features/movie/data/repositories/movie_repository_impl.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  setUpAll(registerCommonFallbacks);

  late MockMovieApiService api;
  late _MockAuth auth;
  late _MockUser user;
  late MockMovieRecommendationCache cache;
  late MovieRepositoryImpl repository;

  final requestOptions = RequestOptions(path: '/movie/popular');

  HttpResponse<MovieApiResponse> responseWith(MovieApiResponse body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  HttpResponse<T> bodyWith<T>(T body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  MovieApiResponse page(List<MovieModel>? results) => MovieApiResponse(page: 1, results: results, totalPages: 1, totalResults: results?.length ?? 0);

  setUp(() {
    api = MockMovieApiService();
    auth = _MockAuth();
    user = _MockUser();

    cache = MockMovieRecommendationCache();

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid');
    when(() => user.getIdToken()).thenAnswer((_) async => 'id-token');

    // Nothing cached unless a test says otherwise.
    when(() => cache.read('uid')).thenReturn(null);
    when(() => cache.read('uid', ignoreAge: true)).thenReturn(null);
    when(() => cache.write('uid', any())).thenAnswer((_) async {});

    repository = MovieRepositoryImpl(api, auth, cache);
  });

  group('getPopularMovies', () {
    test('maps the response models to entities', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page')))
          .thenAnswer((_) async => responseWith(page([const MovieModel(id: 1, title: 'A', posterPath: '/a.jpg', overview: 'A.')])));

      final result = await repository.getPopularMovies();

      final movies = result.getRight().toNullable()!;
      expect(movies.single.id, 1);
      expect(movies.single.title, 'A');
      // The boundary hands back entities, never models.
      expect(movies.single, isNot(isA<MovieModel>()));
    });

    test('drops a title the app has nothing to draw', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page'))).thenAnswer(
        (_) async => responseWith(
          page(const [
            MovieModel(id: 1, title: 'A', posterPath: '/a.jpg', overview: 'A.'),
            // TMDB's catalogue is crowd-maintained: an entry can arrive with
            // no artwork, or with nothing written about it.
            MovieModel(id: 2, title: 'B', overview: 'B.'),
            MovieModel(id: 3, title: 'C', posterPath: '/c.jpg'),
            MovieModel(id: 4, title: 'D', posterPath: '/d.jpg', overview: '   '),
          ]),
        ),
      );

      final movies = (await repository.getPopularMovies()).getRight().toNullable();

      expect(movies?.map((movie) => movie.id), [1]);
    });

    test('a null results array becomes an empty list, not a crash', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page'))).thenAnswer((_) async => responseWith(page(null)));

      final result = await repository.getPopularMovies();

      expect(result.getRight().toNullable(), isEmpty);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page')))
          .thenAnswer((_) async => responseWith(page(const []), statusCode: 401));

      final failure = (await repository.getPopularMovies()).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 401);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      final result = await repository.getPopularMovies();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  test('searchMoviesByTitle forwards the query and excludes adult results', () async {
    when(
      () => api.searchMoviesByTitle(
        query: any(named: 'query'),
        language: any(named: 'language'),
        includeAdult: any(named: 'includeAdult'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => responseWith(page(const [])));

    await repository.searchMoviesByTitle(query: 'matrix');

    verify(
      () => api.searchMoviesByTitle(query: 'matrix', language: 'en-US', includeAdult: false, page: 1),
    ).called(1);
  });

  test('getSimilarMovies forwards the movie id', () async {
    when(() => api.getSimilarMovies(movieId: any(named: 'movieId'), language: any(named: 'language'), page: any(named: 'page')))
        .thenAnswer((_) async => responseWith(page(const [])));

    await repository.getSimilarMovies(movieId: 42);

    verify(() => api.getSimilarMovies(movieId: 42, language: 'en-US', page: 1)).called(1);
  });

  group('getMovieDetails', () {
    void stubDetails(MovieDetailModel body, {int statusCode = 200}) {
      when(() => api.getMovieDetails(movieId: any(named: 'movieId'), language: any(named: 'language')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    test('forwards the movie id and maps the detail response to an entity', () async {
      stubDetails(const MovieDetailModel(id: 11, title: 'Star Wars', genres: [GenreModel(id: 12, name: 'Adventure')]));

      final movie = (await repository.getMovieDetails(movieId: 11)).getRight().toNullable()!;

      verify(() => api.getMovieDetails(movieId: 11, language: 'en-US')).called(1);
      expect(movie.id, 11);
      expect(movie.title, 'Star Wars');
      expect(movie.genreIds, [12]);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubDetails(const MovieDetailModel(id: 11), statusCode: 404);

      final failure = (await repository.getMovieDetails(movieId: 11)).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getMovieDetails(movieId: any(named: 'movieId'), language: any(named: 'language')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      final result = await repository.getMovieDetails(movieId: 11);

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('getRecommendedMovies', () {
    const starWars = MovieDetailModel(id: 11, title: 'Star Wars', posterPath: '/sw.jpg', overview: 'Star Wars.');
    const fightClub = MovieDetailModel(id: 550, title: 'Fight Club', posterPath: '/fc.jpg', overview: 'Fight Club.');
    const venom = MovieDetailModel(id: 912649, title: 'Venom', posterPath: '/v.jpg', overview: 'Venom.');

    const titlesById = {11: starWars, 550: fightClub, 912649: venom};

    void stubRecommendations(MovieRecommendationResponse body, {int statusCode = 200}) {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    /// [failing] names the ids TMDB cannot answer for; every other id resolves
    /// to its own title, so a test can tell which were fetched and in what
    /// order they were kept.
    void stubTitles({Map<int, int> failing = const {}, Map<int, MovieDetailModel> extra = const {}}) {
      when(() => api.getMovieDetails(movieId: any(named: 'movieId'), language: any(named: 'language'))).thenAnswer((invocation) async {
        final id = invocation.namedArguments[#movieId] as int;
        final body = extra[id] ?? titlesById[id] ?? const MovieDetailModel();

        return bodyWith(body, statusCode: failing[id] ?? 200);
      });
    }

    setUp(() {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11]));
      stubTitles();
    });

    test("sends the signed-in user's ID token as the bearer", () async {
      await repository.getRecommendedMovies();

      // The service authenticates as the user, not as the app — a TMDB token
      // here would be both wrong and a token sent to somebody else's host.
      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: null)).called(1);
    });

    test('passes a limit through when the caller overrides the count', () async {
      await repository.getRecommendedMovies(limit: 5);

      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: 5)).called(1);
    });

    test('turns every id the service ranked into a title, in its order', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11, 550, 912649], count: 3));

      final movies = (await repository.getRecommendedMovies()).getRight().toNullable();

      expect(movies?.map((movie) => movie.id), [11, 550, 912649]);
    });

    test('leaves out a title TMDB cannot answer for rather than failing the rest', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11, 550, 912649]));
      stubTitles(failing: const {550: 404});

      final movies = (await repository.getRecommendedMovies()).getRight().toNullable();

      expect(movies?.map((movie) => movie.id), [11, 912649]);
    });

    test('leaves out a title with nothing to draw', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11, 550]));
      // A recommendation with no artwork would open the tab on a blank
      // rectangle, and one with no description on an empty screen.
      stubTitles(extra: const {550: MovieDetailModel(id: 550, title: 'Fight Club')});

      final movies = (await repository.getRecommendedMovies()).getRight().toNullable();

      expect(movies?.map((movie) => movie.id), [11]);
    });

    test('no title that can be fetched fails with the best-ranked one\'s reason', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11, 550]));
      stubTitles(failing: const {11: 404, 550: 500});

      final failure = (await repository.getRecommendedMovies()).getLeft().toNullable();

      expect((failure as ServerFailure).statusCode, 404);
    });

    test('an absent id list becomes an empty list, not a crash', () async {
      stubRecommendations(const MovieRecommendationResponse());

      expect((await repository.getRecommendedMovies()).getRight().toNullable(), isEmpty);
    });

    test('a guest gets nothing rather than a failure, and the service is never called', () async {
      when(() => auth.currentUser).thenReturn(null);

      // Browsing without an account is a supported way to use the app: the tab
      // falls back to a top-rated title rather than telling the reader off.
      expect((await repository.getRecommendedMovies()).getRight().toNullable(), isEmpty);
      verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
    });

    test('a session that yields no token is an AuthFailure', () async {
      when(() => user.getIdToken()).thenAnswer((_) async => null);

      expect((await repository.getRecommendedMovies()).getLeft().toNullable(), isA<AuthFailure>());
    });

    test('a Firebase error while minting the token becomes a Failure rather than escaping', () async {
      when(() => user.getIdToken()).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      expect((await repository.getRecommendedMovies()).getLeft().toNullable(), isA<Failure>());
    });

    test('a non-200 from the service becomes a ServerFailure carrying the code', () async {
      stubRecommendations(const MovieRecommendationResponse(), statusCode: 401);

      final failure = (await repository.getRecommendedMovies()).getLeft().toNullable();

      expect((failure as ServerFailure).statusCode, 401);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      expect((await repository.getRecommendedMovies()).getLeft().toNullable(), isA<NetworkFailure>());
    });

    group('the cache', () {
      const cached = MovieEntity(id: 99, title: 'Cached', posterPath: '/c.jpg', overview: 'Cached.');

      test('is answered from instead of the service when it has something recent', () async {
        when(() => cache.read('uid')).thenReturn(const [cached]);

        expect((await repository.getRecommendedMovies()).getRight().toNullable(), const [cached]);
        // The whole point: neither service is touched.
        verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
        verifyNever(() => api.getMovieDetails(movieId: any(named: 'movieId'), language: any(named: 'language')));
      });

      test('is written with what the service answered', () async {
        await repository.getRecommendedMovies();

        final written = verify(() => cache.write('uid', captureAny())).captured.single as List<MovieEntity>;
        expect(written.single.id, 11);
      });

      test('remembers an empty answer too, so the next launch does not ask again', () async {
        stubRecommendations(const MovieRecommendationResponse(movieIds: []));

        await repository.getRecommendedMovies();

        verify(() => cache.write('uid', const [])).called(1);
      });

      test('is served stale rather than failing when the service cannot be reached', () async {
        when(() => cache.read('uid', ignoreAge: true)).thenReturn(const [cached]);
        stubRecommendations(const MovieRecommendationResponse(), statusCode: 503);

        // A yesterday's recommendation reads better than an error where the
        // tab's opening title should be.
        expect((await repository.getRecommendedMovies()).getRight().toNullable(), const [cached]);
      });

      test('fails as usual when the service cannot be reached and nothing was ever cached', () async {
        stubRecommendations(const MovieRecommendationResponse(), statusCode: 503);

        expect((await repository.getRecommendedMovies()).getLeft().toNullable(), isA<ServerFailure>());
      });
    });
  });

  group('discoverMovies', () {
    void stubDiscover(MovieApiResponse body, {int statusCode = 200}) {
      when(
        () => api.discoverMovies(
          sortBy: any(named: 'sortBy'),
          withGenres: any(named: 'withGenres'),
          voteAverageGte: any(named: 'voteAverageGte'),
          voteAverageLte: any(named: 'voteAverageLte'),
          voteCountGte: any(named: 'voteCountGte'),
          releaseDateGte: any(named: 'releaseDateGte'),
          releaseDateLte: any(named: 'releaseDateLte'),
          includeAdult: any(named: 'includeAdult'),
          language: any(named: 'language'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => responseWith(body, statusCode: statusCode));
    }

    test('sends every filter under the name TMDB gives it', () async {
      stubDiscover(page(const [MovieModel(id: 1, title: 'A', posterPath: '/a.jpg', overview: 'A.')]));

      await repository.discoverMovies(
        filters: const DiscoverFilters(genreIds: {28}, minRating: 7, maxRating: 9, minYear: 1990, maxYear: 1999),
        sort: DiscoverSort.popularity,
        page: 2,
      );

      verify(
        () => api.discoverMovies(
          sortBy: 'popularity.desc',
          withGenres: '28',
          voteAverageGte: 7,
          voteAverageLte: 9,
          voteCountGte: null,
          // A film's date on TMDB is its primary release date.
          releaseDateGte: '1990-01-01',
          releaseDateLte: '1999-12-31',
          includeAdult: false,
          language: 'en-US',
          page: 2,
        ),
      ).called(1);
    });

    test('an unfiltered browse sends no filter parameters at all', () async {
      stubDiscover(page(const []));

      await repository.discoverMovies(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 1);

      verify(
        () => api.discoverMovies(
          sortBy: 'popularity.desc',
          withGenres: null,
          voteAverageGte: null,
          voteAverageLte: null,
          voteCountGte: null,
          releaseDateGte: null,
          releaseDateLte: null,
          includeAdult: false,
          language: 'en-US',
          page: 1,
        ),
      ).called(1);
    });

    test('the top-rated order carries a vote floor with it', () async {
      stubDiscover(page(const []));

      await repository.discoverMovies(filters: DiscoverFilters.none, sort: DiscoverSort.topRated, page: 1);

      verify(
        () => api.discoverMovies(
          sortBy: 'vote_average.desc',
          withGenres: null,
          voteAverageGte: null,
          voteAverageLte: null,
          voteCountGte: DiscoverQuery.movieVoteFloor,
          releaseDateGte: null,
          releaseDateLte: null,
          includeAdult: false,
          language: 'en-US',
          page: 1,
        ),
      ).called(1);
    });

    test('maps the response to entities and keeps the paging numbers', () async {
      stubDiscover(
        MovieApiResponse(
          page: 2,
          results: const [MovieModel(id: 1, title: 'A', posterPath: '/a.jpg', overview: 'A.')],
          totalPages: 5,
          totalResults: 97,
        ),
      );

      final result = await repository.discoverMovies(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 2,
      );

      final movies = result.getRight().toNullable()!;
      expect(movies.items.single.title, 'A');
      expect(movies.page, 2);
      expect(movies.totalPages, 5);
      expect(movies.totalResults, 97);
      expect(movies.hasMore, isTrue);
    });

    test('an envelope without paging numbers falls back to the page asked for', () async {
      // Left at zero, `page < totalPages` would hold for ever and the grid
      // would keep asking for a next page that does not exist.
      stubDiscover(MovieApiResponse(page: null, results: const [], totalPages: null, totalResults: null));

      final movies = (await repository.discoverMovies(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 4,
      ))
          .getRight()
          .toNullable()!;

      expect(movies.page, 4);
      expect(movies.hasMore, isFalse);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubDiscover(page(const []), statusCode: 422);

      final failure = (await repository.discoverMovies(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 1,
      ))
          .getLeft()
          .toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 422);
    });
  });
}
