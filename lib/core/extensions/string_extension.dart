import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension StringExtension on String {
  String get coverImage => "$imagePathUrl$this";

  String get formattedTime => DateFormat("dd/MM/yyyy").format(DateTime.parse(this));

  /// The year out of a TMDB date. The API sends `1957-04-10`, and sometimes an
  /// empty string for a title with no release date — which is a year we do not
  /// print rather than a crash.
  String? get year => length >= 4 ? substring(0, 4) : null;

  String get rateNumber => "$this / 10";

  String get capitalFirstLetter => substring(0, 1).toUpperCase() + substring(1, length);
}
