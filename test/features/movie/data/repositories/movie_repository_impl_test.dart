import 'package:dio/dio.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/movie/data/models/movie_api_response.dart';
import 'package:filmio/features/movie/data/models/movie_model.dart';
import 'package:filmio/features/movie/data/repositories/movie_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockMovieApiService api;
  late MovieRepositoryImpl repository;

  final requestOptions = RequestOptions(path: '/movie/popular');

  HttpResponse<MovieApiResponse> responseWith(MovieApiResponse body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  MovieApiResponse page(List<MovieModel>? results) =>
      MovieApiResponse(page: 1, results: results, totalPages: 1, totalResults: results?.length ?? 0);

  setUp(() {
    api = MockMovieApiService();
    repository = MovieRepositoryImpl(api);
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
      when(() => api.getPopularMovies(language: any(named: 'language'), page: any(named: 'page')))
          .thenAnswer((_) async => responseWith(page(null)));

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
    when(() => api.getSimilarMovies(
        movieId: any(named: 'movieId'),
        language: any(named: 'language'),
        page: any(named: 'page'))).thenAnswer((_) async => responseWith(page(const [])));

    await repository.getSimilarMovies(movieId: 42);

    verify(() => api.getSimilarMovies(movieId: 42, language: 'en-US', page: 1)).called(1);
  });
}
