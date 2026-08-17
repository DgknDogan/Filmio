import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// The round icon button the app uses over artwork and beside a screen title:
/// a hairline ring over a translucent disc of the page's own ground.
///
/// It is sized to the 44pt target even where the drawn circle is smaller, so
/// a back arrow at the top of a poster is not a 38pt hit area.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  /// For the screen reader, and as the long-press tooltip.
  final String label;

  /// Off for the buttons that sit on a page rather than on artwork — there
  /// the ring alone is enough.
  final bool isFilled;

  final Color? iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.isFilled = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final decoration = AppDecorations(palette).circleButton;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: onPressed,
          radius: 24.r,
          child: Padding(
            // The ring is 38; the padding is what makes the target 44.
            padding: EdgeInsets.all(AppSpacing.xs / 2 + 1),
            child: Container(
              height: 38.r,
              width: 38.r,
              alignment: Alignment.center,
              decoration: isFilled ? decoration : decoration.copyWith(color: Colors.transparent),
              child: Icon(icon, size: AppSpacing.xl, color: iconColor ?? palette.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
