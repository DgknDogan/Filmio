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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late MockSeriesApiService api;
  late _MockAuth auth;
  late _MockUser user;
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

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'id-token');

    repository = SeriesRepositoryImpl(api, auth);
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

  group('getRecommendedSeriesIds', () {
    void stubRecommendations(SeriesRecommendationResponse body, {int statusCode = 200}) {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenAnswer((_) async => bodyWith(body, statusCode: statusCode));
    }

    test("sends the signed-in user's ID token as the bearer", () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732]));

      await repository.getRecommendedSeriesIds();

      // The service authenticates as the user, not as the app — a TMDB token
      // here would be both wrong and a token sent to somebody else's host.
      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: null)).called(1);
    });

    test('passes a limit through when the caller overrides the count', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732]));

      await repository.getRecommendedSeriesIds(limit: 5);

      verify(() => api.getRecommendations(authorization: 'Bearer id-token', limit: 5)).called(1);
    });

    test('returns the ids in the order the service ranked them', () async {
      stubRecommendations(const SeriesRecommendationResponse(seriesIds: [66732, 1399], count: 2));

      expect((await repository.getRecommendedSeriesIds()).getRight().toNullable(), [66732, 1399]);
    });

    test('an absent id list becomes an empty list, not a crash', () async {
      stubRecommendations(const SeriesRecommendationResponse());

      expect((await repository.getRecommendedSeriesIds()).getRight().toNullable(), isEmpty);
    });

    test('a guest gets no ids rather than a failure, and the service is never called', () async {
      when(() => auth.currentUser).thenReturn(null);

      // Browsing without an account is a supported way to use the app: the tab
      // falls back to a top-rated title rather than telling the reader off.
      expect((await repository.getRecommendedSeriesIds()).getRight().toNullable(), isEmpty);
      verifyNever(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')));
    });

    test('a session that yields no token is an AuthFailure', () async {
      when(() => user.getIdToken()).thenAnswer((_) async => null);

      expect((await repository.getRecommendedSeriesIds()).getLeft().toNullable(), isA<AuthFailure>());
    });

    test('a Firebase error while minting the token becomes a Failure rather than escaping', () async {
      when(() => user.getIdToken()).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      expect((await repository.getRecommendedSeriesIds()).getLeft().toNullable(), isA<Failure>());
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubRecommendations(const SeriesRecommendationResponse(), statusCode: 401);

      final failure = (await repository.getRecommendedSeriesIds()).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 401);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getRecommendations(authorization: any(named: 'authorization'), limit: any(named: 'limit')))
          .thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      expect((await repository.getRecommendedSeriesIds()).getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('discoverSeries', () {
    test('sends every filter under the name television gives it', () async {
      stubDiscover(page(const [SeriesModel(id: 1, name: 'A')]));

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
      stubDiscover(page(const [SeriesModel(id: 1, name: 'A')], page: 3, totalPages: 8, totalResults: 150));

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
