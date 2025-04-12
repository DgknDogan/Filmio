import 'package:flutter/material.dart' show Icon, Icons;

enum DeviceTheme {
  light(label: "Light", icon: Icon(Icons.sunny)),
  dark(label: "Dark", icon: Icon(Icons.dark_mode)),
  system(label: "System", icon: Icon(Icons.phone_android_outlined));

  final String label;

  final Icon icon;

  const DeviceTheme({required this.label, required this.icon});

  static DeviceTheme getEnumByLabel({required String label}) {
    return DeviceTheme.values.firstWhere(
      (element) {
        return element.label == label;
      },
    );
  }
}
