import '../enums/movie_type.dart';
import '../enums/series_type.dart';

/// The first genre the app has a name for.
///
/// Used where there is room for one word of category and no more — a hero's
/// meta line, a poster caption. The enums throw on an id they do not carry and
/// TMDB does add genres, so an unknown id is skipped rather than fatal.
extension GenreLabels on List<int>? {
  String? get firstMovieGenre => _first((id) => MovieType.getEnumById(id: id));

  String? get firstSeriesGenre => _first((id) => SeriesType.getEnumById(id: id));

  String? _first(String Function(int id) lookup) {
    for (final id in this ?? const <int>[]) {
      try {
        return lookup(id);
      } on StateError {
        continue;
      }
    }
    return null;
  }
}
