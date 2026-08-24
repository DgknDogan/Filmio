import 'package:filmio/features/movie/data/models/movie_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test('reads the fields the app shows and ignores the ones it does not', () {
      final model = MovieDetailModel.fromJson(fixtureJson('movie_detail.json'));

      expect(model.id, 11);
      expect(model.title, 'Star Wars');
      expect(model.adult, isFalse);
      expect(model.backdropPath, '/2w4xG178RpB4MDAIfTkqAuSJzec.jpg');
      expect(model.originalLanguage, 'en');
      expect(model.originalTitle, 'Star Wars');
      expect(model.overview, 'Princess Leia is captured and held hostage by the evil Imperial forces.');
      expect(model.popularity, 20.6912);
      expect(model.posterPath, '/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg');
      expect(model.releaseDate, '1977-05-25');
      expect(model.video, isFalse);
      expect(model.voteAverage, 8.2);
      expect(model.voteCount, 22061);
    });

    test('reads the named genres this endpoint sends in place of bare ids', () {
      final model = MovieDetailModel.fromJson(fixtureJson('movie_detail.json'));

      expect(model.genres?.map((genre) => genre.id), [12, 28, 878]);
      expect(model.genres?.map((genre) => genre.name), ['Adventure', 'Action', 'Science Fiction']);
    });

    test('a response with almost every field missing parses instead of throwing', () {
      final model = MovieDetailModel.fromJson(const {'id': 550, 'title': 'Fight Club'});

      expect(model.id, 550);
      expect(model.title, 'Fight Club');
      expect(model.genres, isNull);
      expect(model.posterPath, isNull);
    });
  });

  group('toEntity', () {
    test('turns the named genres back into the ids the entity carries', () {
      final entity = MovieDetailModel.fromJson(fixtureJson('movie_detail.json')).toEntity();

      // What the rest of the app reads: a title from this endpoint has to look
      // exactly like one that came out of a list endpoint.
      expect(entity.genreIds, [12, 28, 878]);
    });

    test('carries every other field across the boundary', () {
      final entity = MovieDetailModel.fromJson(fixtureJson('movie_detail.json')).toEntity();

      expect(entity.id, 11);
      expect(entity.title, 'Star Wars');
      expect(entity.adult, isFalse);
      expect(entity.backdropPath, '/2w4xG178RpB4MDAIfTkqAuSJzec.jpg');
      expect(entity.originalLanguage, 'en');
      expect(entity.originalTitle, 'Star Wars');
      expect(entity.overview, 'Princess Leia is captured and held hostage by the evil Imperial forces.');
      expect(entity.popularity, 20.6912);
      expect(entity.posterPath, '/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg');
      expect(entity.releaseDate, '1977-05-25');
      expect(entity.video, isFalse);
      expect(entity.voteAverage, 8.2);
      expect(entity.voteCount, 22061);
    });

    test('no genres at all is an absent list, not an empty one it invents', () {
      final entity = MovieDetailModel.fromJson(const {'id': 550}).toEntity();

      expect(entity.genreIds, isNull);
    });

    test('skips a genre that arrives without an id rather than dropping the title', () {
      final entity = MovieDetailModel.fromJson(const {
        'id': 550,
        'genres': [
          {'name': 'Drama'},
          {'id': 18, 'name': 'Drama'},
        ],
      }).toEntity();

      expect(entity.genreIds, [18]);
    });
  });
}
