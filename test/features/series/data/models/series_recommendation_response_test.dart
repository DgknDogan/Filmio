import 'package:filmio/features/series/data/models/series_recommendation_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  test('reads the ids the recommendation service ranked, in its order', () {
    final response = SeriesRecommendationResponse.fromJson(fixtureJson('series_recommendations.json'));

    // Order is the service's ranking — the head of the tab shows the first.
    expect(response.seriesIds, [66732, 1399, 82856]);
    expect(response.count, 3);
    expect(response.basedOn, 5);
    expect(response.strategy, 'personalized');
  });

  test('a response without ids parses instead of throwing', () {
    final response = SeriesRecommendationResponse.fromJson(const {'count': 0, 'based_on': 0});

    expect(response.seriesIds, isNull);
  });
}
