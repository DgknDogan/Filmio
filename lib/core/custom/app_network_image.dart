import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_shimmer.dart';

/// The single way this app draws a remote image.
///
/// `CachedNetworkImage` is never called directly in feature code: every remote
/// image gets the same shimmer while loading and the same fallback when the URL
/// is dead, and both can be restyled here alone.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  /// Left null on purpose: that is the framework default (`scaleDown`), which
  /// is what a poster wants. Pass `cover` explicitly when a tile should crop.
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  /// Caps the decoded size. A grid of posters decoding at full resolution is
  /// the usual cause of memory pressure.
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => AppShimmer(width: width, height: height, borderRadius: borderRadius),
      errorWidget: (context, url, error) => _Unavailable(width: width, height: height, borderRadius: borderRadius),
    );
  }
}

/// Shown when a poster URL fails. A dead image should read as "nothing here",
/// not as a broken layout.
class _Unavailable extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _Unavailable({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: borderRadius ?? AppRadius.smAll,
      ),
      child: Icon(Icons.image_not_supported_outlined, color: palette.textSecondary, size: AppSpacing.xxl),
    );
  }
}
