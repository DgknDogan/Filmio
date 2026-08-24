import 'package:filmio/features/movie/data/models/movie_recommendation_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  test('reads the ids the recommendation service ranked, in its order', () {
    final response = MovieRecommendationResponse.fromJson(fixtureJson('movie_recommendations.json'));

    // Order is the service's ranking — the head of the tab shows the first.
    expect(response.movieIds, [11, 550, 912649]);
    expect(response.count, 3);
    expect(response.basedOn, 7);
    expect(response.strategy, 'liked_genres');
  });

  test('a response without ids parses instead of throwing', () {
    final response = MovieRecommendationResponse.fromJson(const {'count': 0, 'based_on': 0});

    expect(response.movieIds, isNull);
  });
}
