import 'package:filmio/core/enums/discover_sort.dart';
import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/models/discover_filters.dart';
import 'package:filmio/core/network/discover_query.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one part of discover with rules in it: an unset filter has to become an
/// absent parameter, and a year has to become a date.
void main() {
  group('sortBy', () {
    test('names the order TMDB knows it by', () {
      expect(DiscoverQuery.sortBy(DiscoverSort.popularity), 'popularity.desc');
      expect(DiscoverQuery.sortBy(DiscoverSort.topRated), 'vote_average.desc');
    });
  });

  group('voteCountFloor', () {
    // Without it, sorting by rating returns titles with a single 10/10 vote.
    test('only the top-rated order asks for one', () {
      expect(DiscoverQuery.voteCountFloor(DiscoverSort.popularity, MediaType.movie), isNull);
      expect(DiscoverQuery.voteCountFloor(DiscoverSort.popularity, MediaType.series), isNull);
      expect(DiscoverQuery.voteCountFloor(DiscoverSort.topRated, MediaType.movie), isNotNull);
    });

    // Measured against TMDB's own top-rated lists: a series clears far fewer
    // votes than a film, and one floor for both buries television.
    test('television is held to a lower floor than film', () {
      final movies = DiscoverQuery.voteCountFloor(DiscoverSort.topRated, MediaType.movie)!;
      final series = DiscoverQuery.voteCountFloor(DiscoverSort.topRated, MediaType.series)!;

      expect(series, lessThan(movies));
      expect(movies, DiscoverQuery.movieVoteFloor);
      expect(series, DiscoverQuery.seriesVoteFloor);
    });
  });

  group('genres', () {
    test('no genre chosen is no parameter, not an empty one', () {
      expect(DiscoverQuery.genres(DiscoverFilters.none), isNull);
      expect(DiscoverQuery.genres(const DiscoverFilters(genreIds: {})), isNull);
    });

    test('one genre is sent on its own', () {
      expect(DiscoverQuery.genres(const DiscoverFilters(genreIds: {28})), '28');
    });

    // A pipe is TMDB's OR. A comma would mean "action *and* comedy", which is
    // almost nothing.
    test('several genres are joined as any-of rather than all-of', () {
      final query = DiscoverQuery.genres(const DiscoverFilters(genreIds: {28, 35}));

      expect(query, anyOf('28|35', '35|28'));
      expect(query, isNot(contains(',')));
    });
  });

  group('years', () {
    test('a year becomes the range of days it covers', () {
      expect(DiscoverQuery.fromYear(1999), '1999-01-01');
      // The last day, so the year asked for is included rather than cut off.
      expect(DiscoverQuery.toYear(1999), '1999-12-31');
    });

    test('no year is no parameter', () {
      expect(DiscoverQuery.fromYear(null), isNull);
      expect(DiscoverQuery.toYear(null), isNull);
    });
  });
}
