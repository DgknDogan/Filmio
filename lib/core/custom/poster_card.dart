import 'package:flutter/material.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_network_image.dart';

/// A poster, at the one aspect ratio and the one treatment the app uses.
///
/// The caption is printed on the artwork rather than under it: the title and
/// its year sit in a scrim along the bottom edge, so a row of posters is a row
/// of images and not a row of images with text between them.
class PosterCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  /// The line under the title — a year, a rating, or both.
  final String? meta;

  /// A poster small enough that a caption would be unreadable sets this
  /// false and lets the row beside it carry the text.
  final bool showCaption;

  /// Set when the poster flies into a details screen.
  final Object? heroTag;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.meta,
    this.showCaption = true,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final poster = DecoratedBox(
      decoration: AppDecorations(context.palette).poster,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: imageUrl, fit: BoxFit.cover, memCacheHeight: 600),
              if (showCaption) _Caption(title: title, meta: meta),
            ],
          ),
        ),
      ),
    );

    final withHero = heroTag == null
        ? poster
        : Hero(
            tag: heroTag!,
            flightShuttleBuilder: _crossFade,
            child: poster,
          );

    return onTap == null ? withHero : GestureDetector(onTap: onTap, child: withHero);
  }
}

/// What is drawn while a poster is in the air between two screens.
///
/// The two ends are the same picture but not the same card: a row prints the
/// title on its poster, a details header does not. The framework's own shuttle
/// draws the destination alone, so the caption would disappear the instant the
/// flight began and reappear the instant a back gesture started.
///
/// The destination is laid down first and kept opaque — the poster must never
/// go translucent in mid-air, which is what a plain cross-fade of two cards
/// would do — and the departing end is faded out over it.
Widget _crossFade(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final from = (fromHeroContext.widget as Hero).child;
  final to = (toHeroContext.widget as Hero).child;

  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return Stack(
        fit: StackFit.expand,
        children: [
          to,
          Opacity(opacity: 1 - animation.value, child: from),
        ],
      );
    },
  );
}

class _Caption extends StatelessWidget {
  final String title;
  final String? meta;

  const _Caption({required this.title, this.meta});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
        decoration: AppDecorations(context.palette).posterCaptionScrim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.styles.posterTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (meta != null) ...[
              AppGap.vertical(AppSpacing.xs / 2),
              Text(
                meta!.toUpperCase(),
                style: context.styles.posterMeta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
