import 'package:filmio/features/series/data/models/series_model.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  test('fromJson reads every snake_case key TMDB sends', () {
    final model = SeriesModel.fromJson(fixtureJson('series.json'));

    expect(model.id, 94997);
    expect(model.name, 'House of the Dragon');
    expect(model.backdropPath, '/84XPpjGvxNyExjSuLQe0SzioErt.jpg');
    expect(model.firstAirDate, '2022-08-21');
    expect(model.genreIds, [10765, 18, 10759]);
    expect(model.originCountry, ['US']);
    expect(model.originalLanguage, 'en');
    expect(model.originalName, 'House of the Dragon');
    expect(model.popularity, 1587.44);
    expect(model.posterPath, '/7QMsOTMUswlwxJP0rTTZfmz2tX2.jpg');
    expect(model.voteCount, 4839);
  });

  test('keeps the full rating instead of truncating it to an int', () {
    // voteAverage used to be declared int?, so 8.418 arrived as 8 and the
    // details page rendered "8.0".
    final model = SeriesModel.fromJson(fixtureJson('series.json'));

    expect(model.voteAverage, 8.418);
    expect(model.toEntity().voteAverage, 8.418);
  });

  test('toEntity carries every field across the boundary', () {
    final entity = SeriesModel.fromJson(fixtureJson('series.json')).toEntity();

    expect(entity.id, 94997);
    expect(entity.name, 'House of the Dragon');
    expect(entity.originCountry, ['US']);
    expect(entity.overview, 'The Targaryen dynasty is at the absolute apex of its power.');
    expect(entity.posterPath, '/7QMsOTMUswlwxJP0rTTZfmz2tX2.jpg');
    expect(entity.voteCount, 4839);
  });

  test('fromEntity is the exact inverse of toEntity', () {
    // This round trip is what Firestore stores under `liked_series`: a series
    // read back out of the liked list has to be the one that was put in.
    final original = SeriesModel.fromJson(fixtureJson('series.json'));

    final roundTripped = SeriesModel.fromEntity(original.toEntity());

    expect(roundTripped.toJson(), original.toJson());
  });

  test('fromEntity writes the snake_case keys the liked list is stored under', () {
    const entity = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg', firstAirDate: '2019-01-01');

    final json = SeriesModel.fromEntity(entity).toJson();

    expect(json['poster_path'], '/a.jpg');
    expect(json['first_air_date'], '2019-01-01');
  });

  test('a row with almost every field missing parses instead of throwing', () {
    final model = SeriesModel.fromJson({'id': 1, 'name': 'X'});

    expect(model.id, 1);
    expect(model.posterPath, isNull);
    expect(model.genreIds, isNull);
  });
}
