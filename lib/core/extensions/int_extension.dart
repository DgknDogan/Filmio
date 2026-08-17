import 'package:intl/intl.dart';

extension IntExtension on int {
  /// 892431 → "892K". A vote count is a sense of scale, not a number anyone
  /// reads digit by digit.
  String get compact => NumberFormat.compact().format(this);
}
