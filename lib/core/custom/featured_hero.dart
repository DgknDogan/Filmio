import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_network_image.dart';
import 'meta_line.dart';
import 'poster_card.dart';

/// The full-bleed opening of a tab: one title's artwork, with the page's own
/// ground bleeding back in at the bottom so the rows below continue out of it
/// rather than starting after it.
///
/// Everything it draws is held to the foot of the block. The page's bar floats
/// over the head of it, so the artwork reaches the top of the screen and the
/// block has no idea the bar is there.
class FeaturedHero extends StatelessWidget {
  /// How tall the block is. Public because a page that opens with one has to
  /// know how much of itself the block is taking.
  static double get height => 430.h;

  /// The width of the poster held to the left of the text — the same width the
  /// details screen gives its poster, so the flight between the two is a move
  /// rather than a resize. Public for the same reason [height] is: the
  /// skeleton drawn while the block is loading has to reserve the same space,
  /// and a second copy of the number would drift.
  static double get posterWidth => 118.w;

  /// The height of the filled action under the text.
  static double get actionHeight => 44.h;

  /// The still behind the whole block.
  final String imageUrl;

  /// The title's poster, held to the left of the text.
  ///
  /// The rows further down the page are rows of posters, so the opening title
  /// is one too — and it is the poster, not the backdrop, that flies into the
  /// details screen.
  final String posterUrl;

  final String kicker;
  final String title;
  final double? rating;
  final List<String?> metaParts;

  /// The one filled action, and the icon buttons beside it.
  final String actionLabel;
  final VoidCallback onAction;
  final List<Widget> secondaryActions;

  final Object? heroTag;

  /// How far past the top of the block its artwork reaches.
  ///
  /// The page hands it the overscroll: the still grows upward into the gap a
  /// pulled-down list opens, so the block stretches rather than sliding off a
  /// bare ground. Everything else stays where it is.
  final double stretch;

  const FeaturedHero({
    super.key,
    required this.imageUrl,
    required this.posterUrl,
    required this.kicker,
    required this.title,
    required this.metaParts,
    required this.actionLabel,
    required this.onAction,
    this.rating,
    this.secondaryActions = const [],
    this.heroTag,
    this.stretch = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        // The artwork is allowed out of the top of the block, and only the
        // top: what it grows into is the gap above the first sliver.
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -stretch,
            left: 0,
            right: 0,
            bottom: 0,
            // The scrim travels with the still rather than staying with the
            // block, or the stretched strip would come out lighter than the
            // rest and read as a band across the top.
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Backdrop(url: imageUrl),
                DecoratedBox(decoration: AppDecorations(context.palette).backdropScrim),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: posterWidth,
                      child: PosterCard(
                        imageUrl: posterUrl,
                        title: title,
                        heroTag: heroTag,
                      ),
                    ),
                    AppGap.horizontal(AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(kicker.toUpperCase(), style: context.styles.kicker),
                          AppGap.vertical(AppSpacing.md),
                          Text(title, style: context.styles.featureTitle, maxLines: 3, overflow: TextOverflow.ellipsis),
                          AppGap.vertical(AppSpacing.md),
                          MetaLine(rating: rating, parts: metaParts, onImage: true),
                        ],
                      ),
                    ),
                  ],
                ),
                AppGap.vertical(AppSpacing.lg),
                _Actions(label: actionLabel, onPressed: onAction, secondary: secondaryActions),
                AppGap.vertical(AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The still behind the block is a ground rather than a picture: out of focus
/// and drained of most of its colour, so the poster on top of it is the one
/// thing on the screen that is sharp and the one thing that is in colour.
class _Backdrop extends StatelessWidget {
  final String url;

  /// How much of the still's own colour survives. 0 is grey.
  static const double _saturation = 0.5;
  static const double _blur = 6;

  /// Draining the colour lifts the mid-tones, which leaves the wordmark short
  /// of contrast at the top and a pale seam where the block meets the page at
  /// the bottom. The ground is put back down to where it was.
  static const double _brightness = 0.8;

  const _Backdrop({required this.url});

  @override
  Widget build(BuildContext context) {
    // A blur paints wider than the thing it blurs — roughly three times its
    // sigma past every edge, and nothing above clips it. Left alone, that
    // spilled band lands under the block, outside the scrim, and reads as a
    // strip of loose artwork between the recommendation and the first row.
    return ClipRect(
      child: ColorFiltered(
        colorFilter: _desaturate(_saturation, brightness: _brightness),
        child: ImageFiltered(
          // Clamped rather than decalled: a decalled blur fades the outermost
          // pixels to nothing, which on a full-bleed still reads as a border.
          imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur, tileMode: TileMode.clamp),
          child: AppNetworkImage(url: url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// A saturation matrix, scaled by [brightness].
///
/// The weights are what keep the result honest: draining the colour off a
/// channel-by-channel average would darken reds and lighten greens, so each
/// channel contributes what the eye actually reads it as.
ColorFilter _desaturate(double amount, {double brightness = 1}) {
  // Rec. 709 luminance weights — the same ones a display uses to decide how
  // bright a colour looks.
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  final rest = 1 - amount;
  final k = brightness;

  return ColorFilter.matrix([
    (rest * r + amount) * k, rest * g * k, rest * b * k, 0, 0, //
    rest * r * k, (rest * g + amount) * k, rest * b * k, 0, 0, //
    rest * r * k, rest * g * k, (rest * b + amount) * k, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}

class _Actions extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Widget> secondary;

  const _Actions({required this.label, required this.onPressed, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: FeaturedHero.actionHeight,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(FeaturedHero.actionHeight)),
              child: Text(label),
            ),
          ),
        ),
        for (final action in secondary) ...[
          AppGap.horizontal(AppSpacing.md),
          action,
        ],
      ],
    );
  }
}

/// The square sibling of the round icon button, used only beside a hero's
/// primary action where the two have to share a height.
class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;
  final Color? iconColor;

  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.smAll,
          child: Container(
            height: 44.h,
            width: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              color: palette.surfaceRaised.withValues(alpha: 0.6),
              border: Border.all(color: palette.controlBorder),
            ),
            child: Icon(icon, size: AppSpacing.xl, color: iconColor ?? palette.textPrimary),
          ),
        ),
      ),
    );
  }
}
