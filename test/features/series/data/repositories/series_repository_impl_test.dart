import 'package:dio/dio.dart';
import 'package:filmio/core/enums/discover_sort.dart';
import 'package:filmio/core/models/discover_filters.dart';
import 'package:filmio/core/models/genre_model.dart';
import 'package:filmio/core/network/discover_query.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/data/models/series_api_response.dart';
import 'package:filmio/features/series/data/models/series_detail_model.dart';
import 'package:filmio/features/series/data/models/series_model.dart';
import 'package:filmio/features/series/data/models/series_recommendation_response.dart';
import 'package:filmio/features/series/data/repositories/series_repository_impl.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  setUpAll(registerCommonFallbacks);

  late MockSeriesApiService api;
  late _MockAuth auth;
  late _MockUser user;
  late MockSeriesRecommendationCache cache;
  late SeriesRepositoryImpl repository;

  final requestOptions = RequestOptions(path: '/discover/tv');

  HttpResponse<SeriesApiResponse> responseWith(SeriesApiResponse body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  HttpResponse<T> bodyWith<T>(T body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  SeriesApiResponse page(List<SeriesModel>? results, {int? page = 1, int? totalPages = 1, int? totalResults = 0}) =>
      SeriesApiResponse(page: page, results: results, totalPages: totalPages, totalResults: totalResults);

  void stubDiscover(SeriesApiResponse body, {int statusCode = 200}) {
    when(
      () => api.discoverSeries(
        sortBy: any(named: 'sortBy'),
        withGenres: any(named: 'withGenres'),
        voteAverageGte: any(named: 'voteAverageGte'),
        voteAverageLte: any(named: 'voteAverageLte'),
        voteCountGte: any(named: 'voteCountGte'),
        firstAirDateGte: any(named: 'firstAirDateGte'),
        firstAirDateLte: any(named: 'firstAirDateLte'),
        includeAdult: any(named: 'includeAdult'),
        language: any(named: 'language'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => responseWith(body, statusCode: statusCode));
  }

  setUp(() {
    api = MockSeriesApiService();
    auth = _MockAuth();
    user = _MockUser();

    cache = MockSeriesRecommendationCache();

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid');
    when(() => user.getIdToken()).thenAnswer((_) async => 'id-token');

    // Nothing cached unless a test says otherwise.
    when(() => cache.read('uid')).thenReturn(null);
    when(() => cache.read('uid', ignoreAge: true)).thenReturn(null);
    when(() => cache.write('uid', any())).thenAnswer((_) async {});

    repository = SeriesRepositoryImpl(api, auth, cache);
  });

  test('drops a title the app has nothing to draw', () async {
    stubDiscover(
      page(const [
        SeriesModel(id: 1, name: 'A', posterPath: '/a.jpg', overview: 'A.'),
        // TMDB's catalogue is crowd-maintained: an entry can arrive with no
        // artwork, or with nothing written about it.
        SeriesModel(id: 2, name: 'B', overview: 'B.'),
        SeriesModel(id: 3, name: 'C', posterPath: '/c.jpg'),
        SeriesModel(id: 4, name: 'D', posterPath: '/d.jpg', overview: '   '),
      ]),
    );

    final result = await repository.discoverSeries(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 1);

    expect(result.getRight().toNullable()?.items.map((series) => series.id), [1]);
  });

  group('getSeriesDetails', () {
    void stubDetails(SeriesDetailModel body, {int statusCode = 200}) {
      when(() => api.getSeriesDetails(seriesId: any(named: 'seriesId'), language: any(named: 'language')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    test('forwards the series id and maps the detail response to an entity', () async {
      stubDetails(const SeriesDetailModel(id: 66732, name: 'Stranger Things', genres: [GenreModel(id: 18, name: 'Drama')]));

      final series = (await repository.getSeriesDetails(seriesId: 66732)).getRight().toNullable()!;

      verify(() => api.getSeriesDetails(seriesId: 66732, language: 'en-US')).called(1);
      expect(series.id, 66732);
      expect(series.name, 'Stranger Things');
      expect(series.genreIds, [18]);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubDetails(const SeriesDetailModel(id: 66732), statusCode: 404);

      final failure = (await repository.getSeriesDetails(seriesId: 66732)).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getSeriesDetails(seriesId: any(named: 'seriesId'), language: any(named: 'language')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      expect((await repository.getSeriesDetails(seriesId: 66732)).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('getRecommendedSeries', () {
    const strangerThings = SeriesDetailModel(id: 66732, name: 'Stranger Things', posterPath: '/st.jpg', overview: 'Stranger Things.');
    const thrones = SeriesDetailModel(id: 1399, name: 'Game of Thrones', posterPath: '/got.jpg', overview: 'Game of Thrones.');
    const mandalorian = SeriesDetailModel(id: 82856, name: 'The Mandalorian', posterPath: '/tm.jpg', overview: 'The Mandalorian.');

    const titlesById = {66732: strangerThings, 1399: thrones, 82856: mandalorian};

    void stubRecommendations(SeriesRecommendationResponse body, {int statusCode = 200}) {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    /// [failing] names the ids TMDB cannot answer for; every other id resolves
    /// to its own title, so a test can tell which were fetched and in what
    /// order they were kept.
    void stubTitles({Map<int, int> failing = const {}, Map<int, SeriesDetailModel> extra = const {}}) {
      when(() => api.getSeriesDetails(seriesId: any(named: 'seriesId'), language: any(named: 'language'))).thenAnswer((invocation) async {
        final id = invocation.namedArguments[#seriesId] as int;
        final body = extra[id] ?? titlesById[id] ?? const SeriesDetailModel();

        return bodyWith(body, statusCode: failing[id] ?? 200);
      });
    }

    setUp(() {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732]));
      stubTitles();
    });

    test("sends the signed-in user's ID token as the bearer", () async {
      await repository.getRecommendedSeries();

      // The service authenticates as the user, not as the app — a TMDB token
      // here would be both wrong and a token sent to somebody else's host.
      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: null)).called(1);
    });

    test('passes a limit through when the caller overrides the count', () async {
      await repository.getRecommendedSeries(limit: 5);

      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: 5)).called(1);
    });

    test('turns every id the service ranked into a title, in its order', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732, 1399, 82856], count: 3));

      final series = (await repository.getRecommendedSeries()).getRight().toNullable();

      expect(series?.map((entry) => entry.id), [66732, 1399, 82856]);
    });

    test('leaves out a title TMDB cannot answer for rather than failing the rest', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732, 1399, 82856]));
      stubTitles(failing: const {1399: 404});

      final series = (await repository.getRecommendedSeries()).getRight().toNullable();

      expect(series?.map((entry) => entry.id), [66732, 82856]);
    });

    test('leaves out a title with nothing to draw', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732, 1399]));
      // A recommendation with no artwork would open the tab on a blank
      // rectangle, and one with no description on an empty screen.
      stubTitles(extra: const {1399: SeriesDetailModel(id: 1399, name: 'Game of Thrones')});

      final series = (await repository.getRecommendedSeries()).getRight().toNullable();

      expect(series?.map((entry) => entry.id), [66732]);
    });

    test('no title that can be fetched fails with the best-ranked one\'s reason', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732, 1399]));
      stubTitles(failing: const {66732: 404, 1399: 500});

      final failure = (await repository.getRecommendedSeries()).getLeft().toNullable();

      expect((failure as ServerFailure).statusCode, 404);
    });

    test('an absent id list becomes an empty list, not a crash', () async {
      stubRecommendations(const SeriesRecommendationResponse());

      expect((await repository.getRecommendedSeries()).getRight().toNullable(), isEmpty);
    });

    test('a guest gets nothing rather than a failure, and the service is never called', () async {
      when(() => auth.currentUser).thenReturn(null);

      // Browsing without an account is a supported way to use the app: the tab
      // falls back to a top-rated title rather than telling the reader off.
      expect((await repository.getRecommendedSeries()).getRight().toNullable(), isEmpty);
      verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
    });

    test('a session that yields no token is an AuthFailure', () async {
      when(() => user.getIdToken()).thenAnswer((_) async => null);

      expect((await repository.getRecommendedSeries()).getLeft().toNullable(), isA<AuthFailure>());
    });

    test('a Firebase error while minting the token becomes a Failure rather than escaping', () async {
      when(() => user.getIdToken()).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      expect((await repository.getRecommendedSeries()).getLeft().toNullable(), isA<Failure>());
    });

    test('a non-200 from the service becomes a ServerFailure carrying the code', () async {
      stubRecommendations(const SeriesRecommendationResponse(), statusCode: 401);

      final failure = (await repository.getRecommendedSeries()).getLeft().toNullable();

      expect((failure as ServerFailure).statusCode, 401);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      expect((await repository.getRecommendedSeries()).getLeft().toNullable(), isA<NetworkFailure>());
    });

    group('the cache', () {
      const cached = SeriesEntity(id: 99, name: 'Cached', posterPath: '/c.jpg', overview: 'Cached.');

      test('is answered from instead of the service when it has something recent', () async {
        when(() => cache.read('uid')).thenReturn(const [cached]);

        expect((await repository.getRecommendedSeries()).getRight().toNullable(), const [cached]);
        // The whole point: neither service is touched.
        verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
        verifyNever(() => api.getSeriesDetails(seriesId: any(named: 'seriesId'), language: any(named: 'language')));
      });

      test('is written with what the service answered', () async {
        await repository.getRecommendedSeries();

        final written = verify(() => cache.write('uid', captureAny())).captured.single as List<SeriesEntity>;
        expect(written.single.id, 66732);
      });

      test('remembers an empty answer too, so the next launch does not ask again', () async {
        stubRecommendations(const SeriesRecommendationResponse(seriesIds: []));

        await repository.getRecommendedSeries();

        verify(() => cache.write('uid', const [])).called(1);
      });

      test('is served stale rather than failing when the service cannot be reached', () async {
        when(() => cache.read('uid', ignoreAge: true)).thenReturn(const [cached]);
        stubRecommendations(const SeriesRecommendationResponse(), statusCode: 503);

        // A yesterday's recommendation reads better than an error where the
        // tab's opening title should be.
        expect((await repository.getRecommendedSeries()).getRight().toNullable(), const [cached]);
      });

      test('fails as usual when the service cannot be reached and nothing was ever cached', () async {
        stubRecommendations(const SeriesRecommendationResponse(), statusCode: 503);

        expect((await repository.getRecommendedSeries()).getLeft().toNullable(), isA<ServerFailure>());
      });
    });
  });

  group('discoverSeries', () {
    test('sends every filter under the name television gives it', () async {
      stubDiscover(page(const [SeriesModel(id: 1, name: 'A', posterPath: '/a.jpg', overview: 'A.')]));

      await repository.discoverSeries(
        filters: const DiscoverFilters(genreIds: {18}, minRating: 7, maxRating: 9, minYear: 1990, maxYear: 1999),
        sort: DiscoverSort.popularity,
        page: 2,
      );

      verify(
        () => api.discoverSeries(
          sortBy: 'popularity.desc',
          withGenres: '18',
          voteAverageGte: 7,
          voteAverageLte: 9,
          voteCountGte: null,
          // Television has no release date — it has a first air date.
          firstAirDateGte: '1990-01-01',
          firstAirDateLte: '1999-12-31',
          includeAdult: false,
          language: 'en-US',
          page: 2,
        ),
      ).called(1);
    });

    test('an unfiltered browse sends no filter parameters at all', () async {
      stubDiscover(page(const []));

      await repository.discoverSeries(filters: DiscoverFilters.none, sort: DiscoverSort.popularity, page: 1);

      verify(
        () => api.discoverSeries(
          sortBy: 'popularity.desc',
          withGenres: null,
          voteAverageGte: null,
          voteAverageLte: null,
          voteCountGte: null,
          firstAirDateGte: null,
          firstAirDateLte: null,
          includeAdult: false,
          language: 'en-US',
          page: 1,
        ),
      ).called(1);
    });

    test('the top-rated order carries a vote floor with it', () async {
      stubDiscover(page(const []));

      await repository.discoverSeries(filters: DiscoverFilters.none, sort: DiscoverSort.topRated, page: 1);

      verify(
        () => api.discoverSeries(
          sortBy: 'vote_average.desc',
          withGenres: null,
          voteAverageGte: null,
          voteAverageLte: null,
          voteCountGte: DiscoverQuery.seriesVoteFloor,
          firstAirDateGte: null,
          firstAirDateLte: null,
          includeAdult: false,
          language: 'en-US',
          page: 1,
        ),
      ).called(1);
    });

    test('maps the response to entities and keeps the paging numbers', () async {
      stubDiscover(page(const [SeriesModel(id: 1, name: 'A', posterPath: '/a.jpg', overview: 'A.')], page: 3, totalPages: 8, totalResults: 150));

      final series = (await repository.discoverSeries(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 3,
      ))
          .getRight()
          .toNullable()!;

      expect(series.items.single.name, 'A');
      expect(series.items.single, isNot(isA<SeriesModel>()));
      expect(series.page, 3);
      expect(series.totalPages, 8);
      expect(series.totalResults, 150);
      expect(series.hasMore, isTrue);
    });

    test('a null results array becomes an empty page, not a crash', () async {
      stubDiscover(page(null));

      final series = (await repository.discoverSeries(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 1,
      ))
          .getRight()
          .toNullable()!;

      expect(series.items, isEmpty);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(
        () => api.discoverSeries(
          sortBy: any(named: 'sortBy'),
          withGenres: any(named: 'withGenres'),
          voteAverageGte: any(named: 'voteAverageGte'),
          voteAverageLte: any(named: 'voteAverageLte'),
          voteCountGte: any(named: 'voteCountGte'),
          firstAirDateGte: any(named: 'firstAirDateGte'),
          firstAirDateLte: any(named: 'firstAirDateLte'),
          includeAdult: any(named: 'includeAdult'),
          language: any(named: 'language'),
          page: any(named: 'page'),
        ),
      ).thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      final result = await repository.discoverSeries(
        filters: DiscoverFilters.none,
        sort: DiscoverSort.popularity,
        page: 1,
      );

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });
}
