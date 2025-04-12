import '../extensions/string_extension.dart';

enum MovieType {
  action(id: 28),
  adventure(id: 12),
  animation(id: 16),
  comedy(id: 35),
  crime(id: 80),
  documentary(id: 99),
  drama(id: 18),
  family(id: 10751),
  fantasy(id: 14),
  history(id: 36),
  horror(id: 27),
  music(id: 10402),
  mystery(id: 9648),
  romance(id: 10749),
  scienceFiction(id: 878),
  tvMovie(id: 10770),
  thriller(id: 53),
  war(id: 10752),
  western(id: 37);

  final int id;

  const MovieType({required this.id});

  static String getEnumById({required int id}) {
    return MovieType.values.firstWhere((element) => element.id == id).name.capitalFirstLetter;
  }
}
