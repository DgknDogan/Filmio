import 'package:flutter/material.dart';

extension BrightnessExtension on ThemeData {
  bool get isLight => brightness == Brightness.light;
}
