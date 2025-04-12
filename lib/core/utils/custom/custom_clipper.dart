import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBorderClipper extends CustomClipper<Path> {
  final double radius = 30.r;

  CustomBorderClipper();

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Path başlangıcı (sol üst)
    path.moveTo(0, 0 + radius);

    // Üst kenar
    path.lineTo(0, size.height);

    // Sol alt köşe
    path.quadraticBezierTo(0, size.height - radius, radius, size.height - radius);

    // Alt kenar
    path.lineTo(size.width - radius, size.height - radius);

    // Sağ alt köşe
    path.quadraticBezierTo(size.width, size.height - radius, size.width, size.height);

    // Sağ kenar
    path.lineTo(size.width, radius);

    // Sağ üst köşe
    path.quadraticBezierTo(size.width, 0, size.width, 0);

    // Üst kenar
    path.lineTo(radius, 0);

    // Sol üst köşe
    path.quadraticBezierTo(0, 0, 0, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }
}
