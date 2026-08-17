import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';

/// The brand mark: a reel drawn as a circle and six spokes.
///
/// It is painted rather than shipped as an image because it is a stroke
/// drawing — at 34pt a raster would soften, and the stroke has to take the
/// text colour of whichever brightness is in effect.
class FilmioMark extends StatelessWidget {
  final double size;

  const FilmioMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MarkPainter(color: context.palette.textPrimary),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final Color color;

  const _MarkPainter({required this.color});

  /// The drawing is authored on a 24×24 grid and scaled from there, so the
  /// proportions hold at any size.
  static const _grid = 24.0;
  static const _strokeWidth = 1.3;
  static const _radius = 8.4;

  /// Where each spoke ends, on the same grid. The centre is (12, 12).
  static const _spokes = [
    Offset(12, 3.6),
    Offset(19.3, 7.8),
    Offset(19.3, 16.2),
    Offset(12, 20.4),
    Offset(4.7, 16.2),
    Offset(4.7, 7.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    final centre = Offset(12 * scale, 12 * scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(centre, _radius * scale, stroke);
    for (final spoke in _spokes) {
      canvas.drawLine(centre, spoke * scale, stroke);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}
