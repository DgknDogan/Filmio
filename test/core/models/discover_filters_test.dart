import 'package:filmio/core/models/discover_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isEmpty', () {
    test('nothing set is the unfiltered catalogue', () {
      expect(DiscoverFilters.none.isEmpty, isTrue);
      expect(const DiscoverFilters().isEmpty, isTrue);
    });

    test('any one of the three makes it a filter', () {
      expect(const DiscoverFilters(genreIds: {28}).isEmpty, isFalse);
      expect(const DiscoverFilters(minRating: 7).isEmpty, isFalse);
      expect(const DiscoverFilters(maxYear: 1999).isEmpty, isFalse);
    });
  });

  group('activeCount', () {
    // What the filter control says out loud, so the reader knows why the list
    // is short. A range counts once however many of its bounds are set.
    test('counts the questions answered, not the fields set', () {
      expect(DiscoverFilters.none.activeCount, 0);
      expect(const DiscoverFilters(genreIds: {28}).activeCount, 1);
      expect(const DiscoverFilters(minRating: 7, maxRating: 9).activeCount, 1);
      expect(const DiscoverFilters(minRating: 7, minYear: 1990).activeCount, 2);
      expect(const DiscoverFilters(genreIds: {28}, minRating: 7, maxYear: 2000).activeCount, 3);
    });
  });

  group('copyWith', () {
    test('leaves what it is not given alone', () {
      const filters = DiscoverFilters(genreIds: {28}, minRating: 7, minYear: 1990);

      final updated = filters.copyWith(minRating: 8);

      expect(updated.minRating, 8);
      expect(updated.genreIds, {28});
      expect(updated.minYear, 1990);
    });

    // Clearing a bound is as ordinary as setting one, and `??` cannot express
    // it — hence the flags.
    test('clears a bound when asked, rather than keeping the old value', () {
      const filters = DiscoverFilters(minRating: 7, maxRating: 9, minYear: 1990, maxYear: 2000);

      final cleared = filters.copyWith(
        clearMinRating: true,
        clearMaxRating: true,
        clearMinYear: true,
        clearMaxYear: true,
      );

      expect(cleared.minRating, isNull);
      expect(cleared.maxRating, isNull);
      expect(cleared.minYear, isNull);
      expect(cleared.maxYear, isNull);
      expect(cleared.isEmpty, isTrue);
    });
  });
}
