import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// The loading placeholder used everywhere something is still arriving.
///
/// Keeping it in one widget means a list of posters and a details header
/// shimmer the same way, and restyling it is a single edit.
class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppShimmer({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: palette.shimmerBase,
          borderRadius: borderRadius ?? AppRadius.smAll,
        ),
      ),
    );
  }
}
