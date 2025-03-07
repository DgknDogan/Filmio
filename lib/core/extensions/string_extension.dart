import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension StringExtension on String {
  String get coverImage => "$imagePathUrl$this";

  String get formattedTime => DateFormat("dd/MM/yyyy").format(DateTime.parse(this));

  String get rateNumber => "$this / 10";
}
