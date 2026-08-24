import 'package:filmio/features/series/data/models/series_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test('reads the fields the app shows and ignores the ones it does not', () {
      final model = SeriesDetailModel.fromJson(fixtureJson('series_detail.json'));

      expect(model.id, 66732);
      expect(model.name, 'Stranger Things');
      expect(model.backdropPath, '/uGYCFvHOxOSLFLzTlMDIcTiWL0o.jpg');
      expect(model.firstAirDate, '2016-07-15');
      expect(model.originCountry, ['US']);
      expect(model.originalLanguage, 'en');
      expect(model.originalName, 'Stranger Things');
      expect(model.overview, 'When a young boy vanishes, a small town uncovers a mystery.');
      expect(model.popularity, 213.4193);
      expect(model.posterPath, '/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg');
      expect(model.voteAverage, 8.6);
      expect(model.voteCount, 18327);
    });

    test('reads the named genres this endpoint sends in place of bare ids', () {
      final model = SeriesDetailModel.fromJson(fixtureJson('series_detail.json'));

      expect(model.genres?.map((genre) => genre.id), [18, 10765, 9648]);
      expect(model.genres?.map((genre) => genre.name), ['Drama', 'Sci-Fi & Fantasy', 'Mystery']);
    });

    test('a response with almost every field missing parses instead of throwing', () {
      final model = SeriesDetailModel.fromJson(const {'id': 1399, 'name': 'Game of Thrones'});

      expect(model.id, 1399);
      expect(model.name, 'Game of Thrones');
      expect(model.genres, isNull);
      expect(model.posterPath, isNull);
    });
  });

  group('toEntity', () {
    test('turns the named genres back into the ids the entity carries', () {
      final entity = SeriesDetailModel.fromJson(fixtureJson('series_detail.json')).toEntity();

      // What the rest of the app reads: a series from this endpoint has to look
      // exactly like one that came out of a list endpoint.
      expect(entity.genreIds, [18, 10765, 9648]);
    });

    test('carries every other field across the boundary', () {
      final entity = SeriesDetailModel.fromJson(fixtureJson('series_detail.json')).toEntity();

      expect(entity.id, 66732);
      expect(entity.name, 'Stranger Things');
      expect(entity.backdropPath, '/uGYCFvHOxOSLFLzTlMDIcTiWL0o.jpg');
      expect(entity.firstAirDate, '2016-07-15');
      expect(entity.originCountry, ['US']);
      expect(entity.originalLanguage, 'en');
      expect(entity.originalName, 'Stranger Things');
      expect(entity.overview, 'When a young boy vanishes, a small town uncovers a mystery.');
      expect(entity.popularity, 213.4193);
      expect(entity.posterPath, '/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg');
      expect(entity.voteAverage, 8.6);
      expect(entity.voteCount, 18327);
    });

    test('no genres at all is an absent list, not an empty one it invents', () {
      expect(SeriesDetailModel.fromJson(const {'id': 1399}).toEntity().genreIds, isNull);
    });

    test('skips a genre that arrives without an id rather than dropping the series', () {
      final entity = SeriesDetailModel.fromJson(const {
        'id': 1399,
        'genres': [
          {'name': 'Drama'},
          {'id': 18, 'name': 'Drama'},
        ],
      }).toEntity();

      expect(entity.genreIds, [18]);
    });
  });
}
