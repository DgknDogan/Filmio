import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension StringExtension on String {
  String get coverImage => "$imagePathUrl$this";

  /// A review author's avatar. TMDB either stores the picture itself — a path
  /// like `/abc.jpg` — or hands back a Gravatar URL with its own leading
  /// slash bolted on, which would otherwise be prefixed into a dead address.
  String get avatarImage => startsWith('/http') ? substring(1) : coverImage;

  String get formattedTime => DateFormat("dd/MM/yyyy").format(DateTime.parse(this));

  /// The year out of a TMDB date. The API sends `1957-04-10`, and sometimes an
  /// empty string for a title with no release date — which is a year we do not
  /// print rather than a crash.
  String? get year => length >= 4 ? substring(0, 4) : null;

  String get rateNumber => "$this / 10";

  /// A camelCase identifier as words: `scienceFiction` → "Science Fiction".
  /// The genre enums are named in Dart's casing but read by people.
  String get spacedWords =>
      replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (match) => '${match[1]} ${match[2]}').capitalFirstLetter;

  String get capitalFirstLetter => substring(0, 1).toUpperCase() + substring(1, length);
}
