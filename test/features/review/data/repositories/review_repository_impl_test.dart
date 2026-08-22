import 'package:dio/dio.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/review/data/models/review_api_response.dart';
import 'package:filmio/features/review/data/models/review_model.dart';
import 'package:filmio/features/review/data/repositories/review_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockReviewApiService api;
  late ReviewRepositoryImpl repository;

  final requestOptions = RequestOptions(path: '/movie/1/reviews');

  HttpResponse<ReviewApiResponse> responseWith(ReviewApiResponse body, {int statusCode = 200}) =>
      HttpResponse(body, Response(requestOptions: requestOptions, statusCode: statusCode, data: body));

  ReviewApiResponse envelope({
    List<ReviewModel>? results,
    int? page = 1,
    int? totalPages = 1,
    int? totalResults = 0,
  }) =>
      ReviewApiResponse(id: 1, page: page, results: results, totalPages: totalPages, totalResults: totalResults);

  const review = ReviewModel(
    id: 'r1',
    author: 'Cat',
    content: 'Good.',
    authorDetails: ReviewAuthorDetailsModel(name: 'Cat Ellington', username: 'Cat', rating: 8),
  );

  void stubMovie(HttpResponse<ReviewApiResponse> response) {
    when(() => api.getMovieReviews(
        movieId: any(named: 'movieId'),
        language: any(named: 'language'),
        page: any(named: 'page'))).thenAnswer((_) async => response);
  }

  void stubSeries(HttpResponse<ReviewApiResponse> response) {
    when(() => api.getSeriesReviews(
        seriesId: any(named: 'seriesId'),
        language: any(named: 'language'),
        page: any(named: 'page'))).thenAnswer((_) async => response);
  }

  setUp(() {
    api = MockReviewApiService();
    repository = ReviewRepositoryImpl(api);
  });

  group('endpoint', () {
    // The whole reason one repository serves both features: the media type is
    // what picks the path, and nothing above data/ knows a path exists.
    test('a film is asked for on the movie endpoint', () async {
      stubMovie(responseWith(envelope(results: const [review], totalResults: 1)));

      await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 2);

      verify(() => api.getMovieReviews(movieId: 550, language: 'en-US', page: 2)).called(1);
      verifyNever(() => api.getSeriesReviews(
            seriesId: any(named: 'seriesId'),
            language: any(named: 'language'),
            page: any(named: 'page'),
          ));
    });

    test('a series is asked for on the tv endpoint', () async {
      stubSeries(responseWith(envelope(results: const [review], totalResults: 1)));

      await repository.getReviews(mediaId: 1399, mediaType: MediaType.series, page: 1);

      verify(() => api.getSeriesReviews(seriesId: 1399, language: 'en-US', page: 1)).called(1);
      verifyNever(() => api.getMovieReviews(
            movieId: any(named: 'movieId'),
            language: any(named: 'language'),
            page: any(named: 'page'),
          ));
    });
  });

  group('getReviews', () {
    test('maps the response models to entities and keeps the paging numbers', () async {
      stubMovie(responseWith(envelope(results: const [review], page: 2, totalPages: 5, totalResults: 42)));

      final result = await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 2);

      final reviews = result.getRight().toNullable()!;
      expect(reviews.items.single.id, 'r1');
      expect(reviews.items.single.authorName, 'Cat Ellington');
      // The boundary hands back entities, never models.
      expect(reviews.items.single, isNot(isA<ReviewModel>()));
      expect(reviews.page, 2);
      expect(reviews.totalPages, 5);
      expect(reviews.totalResults, 42);
      expect(reviews.hasMore, isTrue);
    });

    test('the last page reports that there is nothing more to ask for', () async {
      stubMovie(responseWith(envelope(results: const [review], page: 3, totalPages: 3, totalResults: 42)));

      final reviews =
          (await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 3)).getRight().toNullable()!;

      expect(reviews.hasMore, isFalse);
    });

    test('a null results array becomes an empty page, not a crash', () async {
      stubMovie(responseWith(envelope(results: null)));

      final reviews =
          (await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 1)).getRight().toNullable()!;

      expect(reviews.items, isEmpty);
      expect(reviews.totalResults, 0);
    });

    test('an envelope without paging numbers falls back to the page asked for', () async {
      // Left at zero, `page < totalPages` would hold for ever and the list
      // would keep asking for a next page that does not exist.
      stubMovie(responseWith(envelope(results: const [review], page: null, totalPages: null, totalResults: null)));

      final reviews =
          (await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 4)).getRight().toNullable()!;

      expect(reviews.page, 4);
      expect(reviews.totalPages, 4);
      expect(reviews.totalResults, 1);
      expect(reviews.hasMore, isFalse);
    });

    test('a non-200 becomes a ServerFailure carrying the code', () async {
      stubMovie(responseWith(envelope(results: const []), statusCode: 404));

      final failure =
          (await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 1)).getLeft().toNullable();

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });

    test('a thrown DioException becomes a Failure rather than escaping', () async {
      when(() => api.getMovieReviews(
            movieId: any(named: 'movieId'),
            language: any(named: 'language'),
            page: any(named: 'page'),
          )).thenThrow(DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError));

      final result = await repository.getReviews(mediaId: 550, mediaType: MediaType.movie, page: 1);

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });
}
