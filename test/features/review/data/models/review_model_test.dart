import 'package:filmio/features/review/data/models/review_api_response.dart';
import 'package:filmio/features/review/data/models/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  ReviewApiResponse page() => ReviewApiResponse.fromJson(fixtureJson('review_page.json'));

  group('fromJson', () {
    test('reads every key TMDB sends, including the nested author', () {
      final review = page().results!.first;

      expect(review.id, '60d5f1a4b0a1e5002dabc123');
      expect(review.author, 'Cat Ellington');
      expect(review.content, 'A masterclass in restraint.');
      expect(review.createdAt, '2021-06-25T14:31:00.123Z');
      expect(review.updatedAt, '2021-06-26T09:02:11.456Z');
      expect(review.url, 'https://www.themoviedb.org/review/60d5f1a4b0a1e5002dabc123');
      expect(review.authorDetails?.name, 'Cat Ellington');
      expect(review.authorDetails?.username, 'CatEllington');
      expect(review.authorDetails?.avatarPath, '/xNs0Iz3JBOgOJVUOZOF6dPX5Cxg.jpg');
    });

    test('a review left without a score parses instead of throwing', () {
      final review = page().results!.last;

      expect(review.authorDetails?.rating, isNull);
    });

    test('a review with almost every field missing parses', () {
      final review = ReviewModel.fromJson(fixtureJson('review_sparse.json'));

      expect(review.id, '60d5f1a4b0a1e5002dabc123');
      expect(review.author, 'anonymous');
      expect(review.authorDetails, isNull);
      expect(review.createdAt, isNull);
    });

    test('the envelope carries where the page sits in the whole', () {
      final response = page();

      expect(response.page, 1);
      expect(response.totalPages, 3);
      expect(response.totalResults, 42);
      expect(response.results, hasLength(2));
    });
  });

  group('rating', () {
    // TMDB documents the score as a string and sends it as a number, so the
    // model is written to survive being told either.
    test('a numeric score becomes a double', () {
      expect(page().results!.first.authorDetails?.rating, 8.0);

      final asInt = ReviewAuthorDetailsModel.fromJson(const {'rating': 7});
      expect(asInt.rating, 7.0);
    });

    test('a score sent as a string is parsed rather than dropped', () {
      final model = ReviewAuthorDetailsModel.fromJson(const {'rating': '6.5'});

      expect(model.rating, 6.5);
    });

    test('anything unparseable becomes null instead of throwing', () {
      expect(ReviewAuthorDetailsModel.fromJson(const {'rating': 'n/a'}).rating, isNull);
      expect(ReviewAuthorDetailsModel.fromJson(const {'rating': null}).rating, isNull);
      expect(ReviewAuthorDetailsModel.fromJson(const {}).rating, isNull);
    });
  });

  group('toEntity', () {
    test('flattens the author onto the review', () {
      final entity = page().results!.first.toEntity();

      expect(entity.id, '60d5f1a4b0a1e5002dabc123');
      expect(entity.author, 'Cat Ellington');
      expect(entity.authorName, 'Cat Ellington');
      expect(entity.authorUsername, 'CatEllington');
      expect(entity.avatarPath, '/xNs0Iz3JBOgOJVUOZOF6dPX5Cxg.jpg');
      expect(entity.rating, 8.0);
      expect(entity.content, 'A masterclass in restraint.');
      expect(entity.createdAt, '2021-06-25T14:31:00.123Z');
      expect(entity.url, 'https://www.themoviedb.org/review/60d5f1a4b0a1e5002dabc123');
    });

    test('a missing author block leaves the name fields empty rather than throwing', () {
      final entity = ReviewModel.fromJson(fixtureJson('review_sparse.json')).toEntity();

      expect(entity.authorName, isNull);
      expect(entity.rating, isNull);
      // The handle is still there, which is what the card ends up crediting.
      expect(entity.displayName, 'anonymous');
    });

    test('an empty display name falls back to the handle', () {
      final entity = page().results!.last.toEntity();

      expect(entity.authorName, '');
      expect(entity.displayName, 'gravatarUser');
    });
  });
}
