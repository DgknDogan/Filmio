import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_network_image.dart';
import 'featured_carousel.dart';
import 'meta_line.dart';
import 'numeric_transition_text.dart';
import 'poster_card.dart';

/// One title the featured block can show — everything about it that changes
/// when the block steps on to another.
class FeaturedTitle {
  /// The still behind the whole block.
  final String imageUrl;

  /// The title's poster, held to the left of the text.
  ///
  /// The rows further down the page are rows of posters, so the opening title
  /// is one too — and it is the poster, not the backdrop, that flies into the
  /// details screen.
  final String posterUrl;

  final String title;
  final double? rating;
  final List<String?> metaParts;

  /// Different for every title in the block: while the poster cross-fades,
  /// the old title's and the new one's are both on screen.
  final Object? heroTag;

  const FeaturedTitle({
    required this.imageUrl,
    required this.posterUrl,
    required this.title,
    required this.metaParts,
    this.rating,
    this.heroTag,
  });
}

/// The full-bleed opening of a tab: a title's artwork, with the page's own
/// ground bleeding back in at the bottom so the rows below continue out of it
/// rather than starting after it.
///
/// Given more than one title, it steps through them without end, by swipe or
/// by the arrows either side of its action. Only the artwork slides. The
/// poster and the lines beside it stay where they are and change in place a
/// moment after it sets off — the poster cross-fading, the name, rating and
/// genre rolling over a character at a time. The kicker, the action and the
/// arrows do not change at all: they belong to the block, not to any one
/// title.
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

  /// Best first. With only one, the action has the row to itself.
  final List<FeaturedTitle> titles;

  /// The label over the title — the same whichever one is showing.
  final String kicker;

  /// The one filled action, handed the index of the title showing when it is
  /// pressed.
  final String actionLabel;
  final ValueChanged<int> onAction;

  /// How far past the top of the block its artwork reaches.
  ///
  /// The page hands it the overscroll: the still grows upward into the gap a
  /// pulled-down list opens, so the block stretches rather than sliding off a
  /// bare ground. Everything else stays where it is.
  final double stretch;

  const FeaturedHero({
    super.key,
    required this.titles,
    required this.kicker,
    required this.actionLabel,
    required this.onAction,
    this.stretch = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FeaturedCarousel(
        count: titles.length,
        pageBuilder: (context, index) => _Artwork(url: titles[index].imageUrl, stretch: stretch),
        overlayBuilder: (context, controls) => _Still(
          index: controls.shown,
          title: titles[controls.shown],
          kicker: kicker,
          actionLabel: actionLabel,
          onAction: () => onAction(controls.shown),
          onPrevious: controls.onPrevious,
          onNext: controls.onNext,
        ),
      ),
    );
  }
}

/// One title's artwork, filling the block. This is all that slides.
class _Artwork extends StatelessWidget {
  final String url;
  final double stretch;

  const _Artwork({required this.url, required this.stretch});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      // The artwork is allowed out of the top of the block, and only the top:
      // what it grows into is the gap above the first sliver.
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -stretch,
          left: 0,
          right: 0,
          bottom: 0,
          // The scrim travels with the still rather than staying with the
          // block, or the stretched strip would come out lighter than the rest
          // and read as a band across the top.
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Backdrop(url: url),
              DecoratedBox(decoration: AppDecorations(context.palette).backdropScrim),
            ],
          ),
        ),
      ],
    );
  }
}

/// Everything over the artwork, which stays where it is while the artwork
/// slides: the poster and the lines beside it, changing in place, and the
/// action with its arrows, not changing at all.
class _Still extends StatelessWidget {
  /// Which of the block's titles [title] is — what tells one poster from the
  /// next while they cross-fade.
  final int index;
  final FeaturedTitle title;
  final String kicker;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// How long the poster takes to cross-fade into the next title's.
  static const Duration _posterFade = Duration(milliseconds: 300);

  const _Still({
    required this.index,
    required this.title,
    required this.kicker,
    required this.actionLabel,
    required this.onAction,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          // Drawn over the pages but not in the way of them: a swipe that
          // starts on the poster or the text still reaches the artwork.
          IgnorePointer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: FeaturedHero.posterWidth,
                  child: AnimatedSwitcher(
                    duration: _posterFade,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: PosterCard(
                      key: ValueKey(index),
                      imageUrl: title.posterUrl,
                      title: title.title,
                      heroTag: title.heroTag,
                    ),
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
                      NumericTransitionText(
                        title.title,
                        style: context.styles.featureTitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppGap.vertical(AppSpacing.md),
                      MetaLine(rating: title.rating, parts: title.metaParts, onImage: true, rollChanges: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppGap.vertical(AppSpacing.lg),
          SizedBox(
            height: FeaturedHero.actionHeight,
            child: _Actions(label: actionLabel, onPressed: onAction, onPrevious: onPrevious, onNext: onNext),
          ),
          AppGap.vertical(AppSpacing.xxl),
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

/// The filled action, with an arrow either side of it when there is another
/// title to step to.
class _Actions extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Actions({required this.label, required this.onPressed, this.onPrevious, this.onNext});

  @override
  Widget build(BuildContext context) {
    final previous = onPrevious;
    final next = onNext;

    return Row(
      spacing: AppSpacing.sm,
      children: [
        if (previous != null)
          Expanded(
            child: _StepButton(
              key: const Key('featuredPrevious'),
              icon: Icons.arrow_back_ios_new_rounded,
              label: context.l10n.featuredPrevious,
              onPressed: previous,
            ),
          ),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: FeaturedHero.actionHeight,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(FeaturedHero.actionHeight)),
              child: Text(label),
            ),
          ),
        ),
        if (next != null)
          Expanded(
            child: _StepButton(
              key: const Key('featuredNext'),
              icon: Icons.arrow_forward_ios_rounded,
              label: context.l10n.featuredNext,
              onPressed: next,
            ),
          ),
      ],
    );
  }
}

/// An arrow beside the action, stepping the block to another title.
class _StepButton extends StatelessWidget {
  final IconData icon;

  /// What a screen reader says for the arrow, and what a long press shows.
  final String label;
  final VoidCallback onPressed;

  const _StepButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: ElevatedButton(
        onPressed: onPressed,
        // The theme pads a button for a word; an arrow in a sixth of the row
        // has no room for that padding.
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(FeaturedHero.actionHeight),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon),
      ),
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
