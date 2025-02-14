import 'constants.dart';
import 'package:intl/intl.dart';

extension ImageConverter on String {
  String get coverImage => "$imagePathUrl$this";
}

extension RoundNumber on double {
  String get roundNumber => toStringAsFixed(1);
}

extension TimeFormat on String {
  String get formattedTime => DateFormat("dd/MM/yyyy").format(DateTime.parse(this));
}
