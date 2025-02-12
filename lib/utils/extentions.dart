import 'constants.dart';

extension ImageConverter on String {
  String get coverImage => "$imagePathUrl$this";
}
