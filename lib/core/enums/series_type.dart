import '../extensions/string_extension.dart';

/// TMDB's television genres. They overlap the film list without matching it —
/// television has its own ids, and its own genres.
enum SeriesType {
  action(id: 10759),
  animation(id: 16),
  comedy(id: 35),
  crime(id: 80),
  documentary(id: 99),
  drama(id: 18),
  family(id: 10751),
  kids(id: 10762),
  mystery(id: 9648),
  news(id: 10763),
  reality(id: 10764),
  scifi(id: 10765),
  soap(id: 10766),
  talk(id: 10767),
  politics(id: 10768),
  western(id: 37);

  final int id;

  const SeriesType({required this.id});

  /// What the reader sees: `scienceFiction` as "Science Fiction".
  String get label => name.spacedWords;

  static String getEnumById({required int id}) {
    return SeriesType.values.firstWhere((element) => element.id == id).label;
  }
}
