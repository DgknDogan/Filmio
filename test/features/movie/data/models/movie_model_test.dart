import 'package:filmio/features/movie/data/models/movie_model.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test('reads every snake_case key TMDB sends', () {
      final model = MovieModel.fromJson(fixtureJson('movie.json'));

      expect(model.id, 912649);
      expect(model.title, 'Venom: The Last Dance');
      expect(model.adult, isFalse);
      expect(model.backdropPath, '/tZbcuNlMOOFEIeYIYJfKtSPYlKm.jpg');
      expect(model.genreIds, [28, 878, 12]);
      expect(model.originalLanguage, 'en');
      expect(model.originalTitle, 'Venom: The Last Dance');
      expect(model.overview, 'Eddie and Venom are on the run.');
      expect(model.popularity, 3985.539);
      expect(model.posterPath, '/aosm8NMQ3UyoBVpSxyimorCQykC.jpg');
      expect(model.releaseDate, '2024-10-22');
      expect(model.video, isFalse);
      expect(model.voteCount, 1587);
    });

    test('keeps the rating as a double rather than truncating it', () {
      final model = MovieModel.fromJson(fixtureJson('movie.json'));

      expect(model.voteAverage, 6.767);
    });

    test('a row with almost every field missing parses instead of throwing', () {
      final model = MovieModel.fromJson(fixtureJson('movie_sparse.json'));

      expect(model.id, 550);
      expect(model.title, 'Fight Club');
      expect(model.posterPath, isNull);
      expect(model.genreIds, isNull);
      expect(model.voteAverage, isNull);
    });
  });

  group('toEntity', () {
    test('carries every field across the boundary', () {
      final entity = MovieModel.fromJson(fixtureJson('movie.json')).toEntity();

      expect(entity.id, 912649);
      expect(entity.title, 'Venom: The Last Dance');
      expect(entity.adult, isFalse);
      expect(entity.backdropPath, '/tZbcuNlMOOFEIeYIYJfKtSPYlKm.jpg');
      expect(entity.genreIds, [28, 878, 12]);
      expect(entity.originalLanguage, 'en');
      expect(entity.originalTitle, 'Venom: The Last Dance');
      expect(entity.overview, 'Eddie and Venom are on the run.');
      expect(entity.popularity, 3985.539);
      expect(entity.posterPath, '/aosm8NMQ3UyoBVpSxyimorCQykC.jpg');
      expect(entity.releaseDate, '2024-10-22');
      expect(entity.video, isFalse);
      expect(entity.voteAverage, 6.767);
      expect(entity.voteCount, 1587);
    });

    test('produces an entity equal to one built by hand', () {
      final entity = MovieModel.fromJson(fixtureJson('movie_sparse.json')).toEntity();

      expect(entity, const MovieEntity(id: 550, title: 'Fight Club'));
    });
  });

  group('fromEntity', () {
    test('round-trips an entity back to the exact JSON Firestore already stores', () {
      // liked_movies documents were written with these keys. A rename here
      // silently orphans every row already on the server, and arrayRemove
      // stops matching, so this test guards the wire format, not the mapping.
      final original = fixtureJson('movie.json');
      final entity = MovieModel.fromJson(original).toEntity();

      expect(MovieModel.fromEntity(entity).toJson(), original);
    });

    test('a plain entity — not one that came from JSON — serialises fine', () {
      // The bug this replaced was `(movie as MovieModel)`, which threw here.
      const entity = MovieEntity(id: 1, title: 'A', posterPath: '/a.jpg');

      final json = MovieModel.fromEntity(entity).toJson();

      expect(json['id'], 1);
      expect(json['title'], 'A');
      expect(json['poster_path'], '/a.jpg');
    });
  });
}
