import 'dart:convert';
import 'dart:io';

import 'package:filmio/features/movie/data/datasources/movie_recommendation_local_datasource.dart';
import 'package:filmio/features/movie/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmio/core/storage/liked_titles_stamp.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the cache actually decides: whether an entry is still young enough to
/// serve, whether a title survives the round trip through JSON, and what
/// happens to an entry it can no longer read.
///
/// Against a real box in a temporary directory rather than a mocked one —
/// half of what this class does is the encoding, and a mock box would hand
/// back whatever the test put in.
void main() {
  late Directory directory;
  late Box<String> box;
  late LikedTitlesStamp likes;
  late MovieRecommendationLocalDataSource cache;

  const starWars = MovieEntity(id: 11, title: 'Star Wars', posterPath: '/sw.jpg', overview: 'Star Wars.');
  const fightClub = MovieEntity(id: 550, title: 'Fight Club', posterPath: '/fc.jpg', overview: 'Fight Club.');

  /// Writes an entry by hand, so a test can date it.
  Future<void> writeAged(Duration age) {
    return box.put(
      'uid',
      jsonEncode({
        'cached_at': DateTime.now().subtract(age).toIso8601String(),
        'movies': [
          {'id': 11, 'title': 'Star Wars'},
        ],
      }),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    likes = LikedTitlesStamp(await SharedPreferences.getInstance());

    directory = await Directory.systemTemp.createTemp('filmio_cache_test');
    Hive.init(directory.path);
    box = await Hive.openBox<String>(MovieRecommendationLocalDataSource.boxName);
    cache = MovieRecommendationLocalDataSource(box, likes);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await directory.delete(recursive: true);
  });

  test('reads back what it wrote, in order and with its details', () async {
    await cache.write('uid', const [starWars, fightClub]);

    final movies = cache.read('uid');

    expect(movies?.map((movie) => movie.id), [11, 550]);
    expect(movies?.first.overview, 'Star Wars.');
  });

  test('remembers an empty answer as an empty list, not as nothing cached', () async {
    // Otherwise every launch asks the service again to be told the same thing.
    await cache.write('uid', const []);

    expect(cache.read('uid'), isEmpty);
  });

  test('has nothing for a user it has never written for', () {
    expect(cache.read('somebody-else'), isNull);
  });

  test('keeps one account out of another', () async {
    await cache.write('uid', const [starWars]);

    expect(cache.read('other-uid'), isNull);
  });

  test('serves an entry that is still young', () async {
    await writeAged(const Duration(hours: 1));

    expect(cache.read('uid'), isNotNull);
  });

  test('refuses an entry that has aged out', () async {
    await writeAged(const Duration(hours: 7));

    expect(cache.read('uid'), isNull);
  });

  test('serves an aged-out entry when asked to ignore its age', () async {
    await writeAged(const Duration(days: 30));

    // What the repository falls back to when the service cannot be reached.
    expect(cache.read('uid', ignoreAge: true)?.single.id, 11);
  });

  test('an entry it cannot read is a miss rather than a crash', () async {
    await box.put('uid', 'not json at all');

    expect(cache.read('uid'), isNull);
    expect(cache.read('uid', ignoreAge: true), isNull);
  });

  test('an entry with no date is a miss, since its age cannot be judged', () async {
    await box.put('uid', jsonEncode({'movies': const []}));

    expect(cache.read('uid'), isNull);
  });

  group('a like', () {
    test('makes a young entry stale, so the next launch asks again', () async {
      await cache.write('uid', const [starWars]);
      // The picks are derived from the liked titles, so a reader who has just
      // liked something should not be shown what the service made of the list
      // before it.
      await likes.markChanged('uid');

      expect(cache.read('uid'), isNull);
    });

    test('by somebody else leaves this account\'s entry alone', () async {
      await cache.write('uid', const [starWars]);
      await likes.markChanged('other-uid');

      expect(cache.read('uid'), isNotNull);
    });

    test('made before the entry was written does not stale it', () async {
      await likes.markChanged('uid');
      // The entry that follows already knows about that like.
      await cache.write('uid', const [starWars]);

      expect(cache.read('uid'), isNotNull);
    });

    test('does not stop the stale entry standing in for an unreachable service', () async {
      await cache.write('uid', const [starWars]);
      await likes.markChanged('uid');

      expect(cache.read('uid', ignoreAge: true)?.single.id, 11);
    });
  });
}
