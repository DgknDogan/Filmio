import 'package:filmio/features/account/domain/entities/taste_profile.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// TMDB genre ids, by the names the app gives them.
const action = 28;
const drama = 18;
const horror = 27;
const comedy = 35;

/// Television keeps its own ids. `10765` is TMDB's Sci-Fi & Fantasy, which no
/// film carries — the app names it from its own enum — and `18` is Drama in
/// both lists.
const seriesScifi = 10765;

MovieEntity movie({List<int>? genreIds, String? releaseDate, int id = 1}) {
  return MovieEntity(id: id, title: 'A', posterPath: '/a.jpg', genreIds: genreIds, releaseDate: releaseDate);
}

SeriesEntity series({List<int>? genreIds, String? firstAirDate, int id = 1}) {
  return SeriesEntity(id: id, name: 'A', posterPath: '/a.jpg', genreIds: genreIds, firstAirDate: firstAirDate);
}

TasteProfile profileOf({
  List<MovieEntity> likedMovies = const [],
  List<SeriesEntity> likedSeries = const [],
  List<MovieEntity> watchlistMovies = const [],
  List<SeriesEntity> watchlistSeries = const [],
}) {
  return TasteProfile.from(
    likedMovies: likedMovies,
    likedSeries: likedSeries,
    watchlistMovies: watchlistMovies,
    watchlistSeries: watchlistSeries,
  );
}

void main() {
  group('counts', () {
    test('are the length of each of the four lists', () {
      final profile = profileOf(
        likedMovies: [movie(), movie(id: 2)],
        likedSeries: [series()],
        watchlistMovies: [movie(id: 3), movie(id: 4), movie(id: 5)],
        watchlistSeries: [series(id: 2), series(id: 3)],
      );

      expect(profile.likedMovies, 2);
      expect(profile.likedSeries, 1);
      expect(profile.watchlistMovies, 3);
      expect(profile.watchlistSeries, 2);
      expect(profile.watchlistTotal, 5);
    });

    test('empty lists are an empty profile with nothing to say', () {
      final profile = profileOf();

      expect(profile.isEmpty, isTrue);
      expect(profile.hasNoTaste, isTrue);
      expect(profile.topGenres, isEmpty);
      expect(profile.favouriteDecade, isNull);
    });

    test('a watchlist alone is not empty, but says nothing about taste', () {
      final profile = profileOf(watchlistMovies: [
        movie(genreIds: const [horror])
      ]);

      expect(profile.isEmpty, isFalse);
      expect(profile.hasNoTaste, isTrue);
      // What is on the watchlist has not been watched, so it cannot be a
      // favourite genre.
      expect(profile.topGenres, isEmpty);
    });
  });

  group('top genres', () {
    test('are the most frequent across the liked titles, most first', () {
      final profile = profileOf(
        likedMovies: [
          movie(genreIds: const [drama, action]),
          movie(id: 2, genreIds: const [drama]),
          movie(id: 3, genreIds: const [drama, horror]),
          movie(id: 4, genreIds: const [action]),
        ],
      );

      expect(profile.topGenres, ['Drama', 'Action', 'Horror']);
    });

    test('count a genre once per title that carries it', () {
      final profile = profileOf(likedMovies: [
        movie(genreIds: const [horror, horror])
      ]);

      // Two ids on one title is TMDB's doing, not two films.
      expect(profile.topGenres, ['Horror']);
    });

    test('stop at three, however many there are', () {
      final profile = profileOf(
        likedMovies: [
          movie(genreIds: const [drama, action, horror, comedy])
        ],
      );

      expect(profile.topGenres, hasLength(3));
    });

    test('merge a film genre with the series genre of the same name', () {
      // The point of counting by name: 18 is Drama in both id lists, and
      // somebody who likes dramatic films and dramatic series likes drama.
      final profile = profileOf(
        likedMovies: [
          movie(genreIds: const [drama])
        ],
        likedSeries: [
          series(genreIds: const [drama])
        ],
      );

      expect(profile.topGenres, ['Drama']);
    });

    test('read a television id out of the television list', () {
      final profile = profileOf(likedSeries: [
        series(genreIds: const [seriesScifi])
      ]);

      // The name is the app's own, from `SeriesType` — not TMDB's wording.
      expect(profile.topGenres, ['Scifi']);
    });

    test('skip an id the app has no name for', () {
      // TMDB adds genres, and an unknown one is not worth a crash.
      final profile = profileOf(likedMovies: [
        movie(genreIds: const [drama, 999999])
      ]);

      expect(profile.topGenres, ['Drama']);
    });

    test('survive a title with no genres at all', () {
      final profile = profileOf(likedMovies: [movie(), movie(id: 2, genreIds: const [])]);

      expect(profile.topGenres, isEmpty);
    });
  });

  group('favourite decade', () {
    test('is the decade most liked titles came out in', () {
      final profile = profileOf(
        likedMovies: [
          movie(releaseDate: '1994-09-10'),
          movie(id: 2, releaseDate: '1999-03-31'),
          movie(id: 3, releaseDate: '2014-11-07'),
        ],
      );

      expect(profile.favouriteDecade, '1990s');
    });

    test('counts series by the year they first aired', () {
      final profile = profileOf(
        likedSeries: [
          series(firstAirDate: '2008-01-20'),
          series(id: 2, firstAirDate: '2009-09-13'),
          series(id: 3, firstAirDate: '2019-04-14'),
        ],
      );

      expect(profile.favouriteDecade, '2000s');
    });

    test('gives a tie to the later decade', () {
      final profile = profileOf(
        likedMovies: [movie(releaseDate: '1985-07-03'), movie(id: 2, releaseDate: '1995-07-03')],
      );

      // The one a reader is likelier to recognise as theirs, and a fixed
      // answer rather than whichever came back first.
      expect(profile.favouriteDecade, '1990s');
    });

    test('ignores a title with no date and one with an unparseable one', () {
      final profile = profileOf(
        likedMovies: [
          movie(releaseDate: '1994-09-10'),
          movie(id: 2),
          movie(id: 3, releaseDate: ''),
          movie(id: 4, releaseDate: 'soon'),
        ],
      );

      expect(profile.favouriteDecade, '1990s');
    });
  });
}
