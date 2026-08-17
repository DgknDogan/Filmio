import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../extensions/context_extension.dart';

/// The app's primary action: an accent outline over a wash of the same
/// colour, sitting on a soft pool of it.
///
/// Shape, colour and label style come from `elevatedButtonTheme`; the glow is
/// here because it is painted behind the button rather than by it. What this
/// adds beyond the look is the in-flight state — a request that is running
/// disables the button and swaps the label for a spinner, so the same submit
/// cannot be fired twice.
class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool isLoading;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: AppDecorations(palette).primaryActionGlow,
      child: SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 18.r,
                  width: 18.r,
                  child: CircularProgressIndicator(strokeWidth: 2, color: palette.onButton),
                )
              : Text(text),
        ),
      ),
    );
  }
}
