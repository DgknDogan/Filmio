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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late MockMovieApiService api;
  late _MockAuth auth;
  late _MockUser user;
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

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'id-token');

    repository = MovieRepositoryImpl(api, auth);
  });

  group('getPopularMovies', () {
    test('maps the response models to entities', () async {
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page')))
          .thenAnswer((_) async => responseWith(page([const MovieModel(id: 1, title: 'A')])));

      final result = await repository.getPopularMovies();

      final movies = result.getRight().toNullable()!;
      expect(movies.single.id, 1);
      expect(movies.single.title, 'A');
      // The boundary hands back entities, never models.
      expect(movies.single, isNot(isA<MovieModel>()));
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

  group('getRecommendedMovieIds', () {
    void stubRecommendations(MovieRecommendationResponse body, {int statusCode = 200}) {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    test('sends the signed-in user\'s ID token as the bearer', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11]));

      await repository.getRecommendedMovieIds();

      // The service authenticates as the user, not as the app — a TMDB token
      // here would be both wrong and a token sent to somebody else's host.
      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: null)).called(1);
    });

    test('passes a limit through when the caller overrides the count', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11]));

      await repository.getRecommendedMovieIds(limit: 5);

      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: 5)).called(1);
    });

    test('returns the ids in the order the service ranked them', () async {
      stubRecommendations(const MovieRecommendationResponse(movieIds: [11, 550, 912649], count: 3));

      final ids = (await repository.getRecommendedMovieIds()).getRight().toNullable();

      expect(ids, [11, 550, 912649]);
    });

    test('an absent id list becomes an empty list, not a crash', () async {
      stubRecommendations(const MovieRecommendationResponse());

      expect((await repository.getRecommendedMovieIds()).getRight().toNullable(), isEmpty);
    });

    test('a guest gets no ids rather than a failure, and the service is never called', () async {
      when(() => auth.currentUser).thenReturn(null);

      // Browsing without an account is a supported way to use the app: the tab
      // falls back to a top-rated title rather than telling the reader off.
      expect((await repository.getRecommendedMovieIds()).getRight().toNullable(), isEmpty);
      verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
    });

    test('a session that yields no token is an AuthFailure', () async {
      when(() => user.getIdToken()).thenAnswer((_) async => null);

      expect((await repository.getRecommendedMovieIds()).getLeft().toNullable(), isA<AuthFailure>());
    });

    test('a Firebase error while minting the token becomes a Failure rather than escaping', () async {
      when(() => user.getIdToken()).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      final failure = (await repository.getRecommendedMovieIds()).getLeft().toNullable();

      expect(failure, isA<Failure>());
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubRecommendations(const MovieRecommendationResponse(), statusCode: 401);

      final failure = (await repository.getRecommendedMovieIds()).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 401);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      expect((await repository.getRecommendedMovieIds()).getLeft().toNullable(), isA<NetworkFailure>());
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
      stubDiscover(page(const [MovieModel(id: 1, title: 'A')]));

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
          results: const [MovieModel(id: 1, title: 'A')],
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
