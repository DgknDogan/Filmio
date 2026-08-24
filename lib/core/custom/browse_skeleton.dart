import 'package:flutter/material.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'app_shimmer.dart';
import 'browse_view.dart';
import 'featured_hero.dart';

/// A browse tab with its content still arriving.
///
/// The shape of the page is known before its content is: two named rows of
/// posters under a featured block. So the wait is spent drawing that shape
/// rather than a spinner or one flat rectangle — the reader can see where the
/// artwork is going to land, and nothing moves when it does.
///
/// The headings are the real ones. They are labels, not data: there is no
/// reason to withhold them until a request comes back.
class BrowseSkeleton extends StatelessWidget {
  /// The same three the loaded tab passes [BrowseView]. Search works while the
  /// rows are still coming — it does not depend on them.
  final Object searchHeroTag;
  final String searchHint;
  final VoidCallback onSearch;

  /// One row per heading, in the order the loaded tab lists them.
  final List<String> rowTitles;

  /// How many posters to stand in for. Enough to run off the right edge, which
  /// is what says the row scrolls.
  static const int _postersPerRow = 5;

  const BrowseSkeleton({
    super.key,
    required this.searchHeroTag,
    required this.searchHint,
    required this.onSearch,
    required this.rowTitles,
  });

  @override
  Widget build(BuildContext context) {
    return BrowseView(
      searchHeroTag: searchHeroTag,
      searchHint: searchHint,
      onSearch: onSearch,
      featuredBuilder: (context, stretch) => FeaturedHeroSkeleton(stretch: stretch),
      rows: [
        for (final title in rowTitles)
          BrowseRow(
            title: title,
            // Kept apart from the loaded row's key: this row has no scroll
            // position worth restoring into the real one.
            storageKey: PageStorageKey('skeleton_$title'),
            posters: List.generate(_postersPerRow, (_) => const PosterCardSkeleton()),
          ),
      ],
    );
  }
}

/// The featured block before there is a title in it.
///
/// Laid out against [FeaturedHero] itself — same height, same poster, same
/// three lines beside it, same action under them — so the block does not
/// resize when the real one replaces it. The ground behind is drawn flat and
/// only the pieces shimmer: a shimmer across the whole block says nothing
/// about what is coming, and reads as one grey slab.
class FeaturedHeroSkeleton extends StatelessWidget {
  /// How far past the top of the block its ground reaches, as [FeaturedHero]
  /// takes it.
  final double stretch;

  const FeaturedHeroSkeleton({super.key, this.stretch = 0});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final styles = context.styles;

    return SizedBox(
      height: FeaturedHero.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -stretch,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: palette.surfaceMuted),
                // The same wash the loaded block carries, so the skeleton
                // meets the first row the way the artwork will.
                DecoratedBox(decoration: AppDecorations(palette).backdropScrim),
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
                    SizedBox(width: FeaturedHero.posterWidth, child: const PosterCardSkeleton()),
                    AppGap.horizontal(AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TextLine(style: styles.kicker, widthFactor: 0.45),
                          AppGap.vertical(AppSpacing.md),
                          _TextLine(style: styles.featureTitle, widthFactor: 0.85),
                          AppGap.vertical(AppSpacing.md),
                          _TextLine(style: styles.meta, widthFactor: 0.6),
                        ],
                      ),
                    ),
                  ],
                ),
                AppGap.vertical(AppSpacing.lg),
                AppShimmer(height: FeaturedHero.actionHeight, borderRadius: AppRadius.mdAll),
                AppGap.vertical(AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A poster before its artwork, at the aspect ratio and corner every poster in
/// the app is drawn at.
class PosterCardSkeleton extends StatelessWidget {
  const PosterCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: AppShimmer(borderRadius: AppRadius.mdAll),
    );
  }
}

/// A stand-in for one line of text, at the height the style would have drawn.
///
/// Taken off the style rather than given a number, so a change to the type
/// scale moves the skeleton with it.
class _TextLine extends StatelessWidget {
  final TextStyle style;

  /// How much of the width the line runs to — a kicker is short, a title runs
  /// most of the way across. Even lengths would read as a paragraph.
  final double widthFactor;

  const _TextLine({required this.style, required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: AppShimmer(height: (style.fontSize ?? 14) * (style.height ?? 1.2)),
    );
  }
}
