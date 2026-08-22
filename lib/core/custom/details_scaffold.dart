import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import '../extensions/int_extension.dart';
import 'app_network_image.dart';
import 'circle_icon_button.dart';
import 'genre_tags.dart';
import 'poster_card.dart';
import 'section_header.dart';

/// How the artwork behaves under the scroll. Sizes, not spacing, so they are
/// literal — but they are named here rather than buried in a build method,
/// because the three of them only make sense together.
abstract final class _BackdropMetrics {
  /// The height the artwork opens at.
  static double get max => 470.h;

  /// What is left of it once the page has been scrolled — a blurred band
  /// behind the top bar rather than a picture.
  static double get min => 250.h;

  /// The scroll distance over which that happens. Short on purpose: a details
  /// page is not tall, so a longer run would never be finished.
  static double get shrinkRun => 140.h;

  /// Where the sheet starts, i.e. how much artwork is left uncovered.
  static double get reveal => 330.h;

  /// Empty sheet under the last row. It is not decoration: a title with a
  /// short synopsis barely scrolls, and without this the artwork would stop
  /// collapsing half way through [shrinkRun].
  static double get foot => AppSpacing.huge * 3;
}

/// The poster the header is built around. Everything else in that row is
/// placed against it, so its size is named once.
double get _posterWidth => 118.w;
double get _posterHeight => _posterWidth * 3 / 2;

/// The details screen a film and a series are both read from.
///
/// One scroll: the artwork sits behind it, shrinking and blurring as the sheet
/// climbs over it, and the sheet carries the record. What differs between the
/// two features is what they hang off it — a film has a heart in the bar and a
/// row of similar titles under the synopsis, a series has neither — so those
/// arrive as [action] and [extras] rather than as a flag in here.
class DetailsScaffold extends StatefulWidget {
  /// The still behind the page. Callers fall back to the poster themselves:
  /// which image stands in for a missing backdrop is theirs to decide.
  final String backdropUrl;

  final String posterUrl;
  final String title;

  /// What the poster flies in on, from the row that was tapped.
  final Object heroTag;

  /// Already formatted — a year, not a date.
  final String? year;

  final double? rating;
  final int? voteCount;

  final List<int>? genreIds;

  /// Television has its own genre id list, which overlaps the film one
  /// without matching it.
  final bool isSeries;

  final String? overview;

  /// Sits opposite the back arrow. A film puts its heart here; a series has
  /// nothing to put there, and the row holds the space open so the title in
  /// the middle stays centred.
  final Widget? action;

  /// Anything the record carries below the synopsis — a similar-titles row.
  /// Each one paints its own sheet ground, since the sheet is what the page
  /// is written on from the header down.
  final List<Widget> extras;

  const DetailsScaffold({
    super.key,
    required this.backdropUrl,
    required this.posterUrl,
    required this.title,
    required this.heroTag,
    this.year,
    this.rating,
    this.voteCount,
    this.genreIds,
    this.isSeries = false,
    this.overview,
    this.action,
    this.extras = const [],
  });

  @override
  State<DetailsScaffold> createState() => _DetailsScaffoldState();
}

class _DetailsScaffoldState extends State<DetailsScaffold> {
  /// Scroll position is not screen state — nothing outside this widget acts on
  /// it — so it stays here and drives the artwork through [AnimatedBuilder]
  /// rather than through a cubit or `setState`.
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      body: Stack(
        children: [
          _BackdropLayer(url: widget.backdropUrl, scroll: _scroll),
          CustomScrollView(
            controller: _scroll,
            slivers: [
              // The window onto the artwork. Transparent, so a drag started
              // over the image still scrolls the page.
              SliverToBoxAdapter(child: SizedBox(height: _BackdropMetrics.reveal)),
              SliverToBoxAdapter(child: _Header(details: widget)),
              SliverToBoxAdapter(child: _Synopsis(overview: widget.overview)),
              for (final extra in widget.extras) SliverToBoxAdapter(child: extra),
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: palette.sheet,
                  child: SizedBox(height: _BackdropMetrics.foot, width: double.infinity),
                ),
              ),
              // Keeps the sheet's colour running to the foot of the viewport
              // when the record is short.
              SliverFillRemaining(hasScrollBody: false, child: ColoredBox(color: palette.sheet)),
            ],
          ),
          _TopBar(title: widget.title, action: widget.action, scroll: _scroll),
        ],
      ),
    );
  }
}

/// The artwork, and what the scroll does to it: it loses height faster than the
/// page gains it, and goes out of focus as it goes.
class _BackdropLayer extends StatelessWidget {
  final String url;
  final ScrollController scroll;

  const _BackdropLayer({required this.url, required this.scroll});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final image = AppNetworkImage(url: url, fit: BoxFit.cover);

    return AnimatedBuilder(
      animation: scroll,
      builder: (context, child) {
        final offset = scroll.hasClients ? scroll.offset : 0.0;
        final t = (offset / _BackdropMetrics.shrinkRun).clamp(0.0, 1.0);

        // Pulling the page down past the top stretches the artwork instead of
        // leaving a gap under it.
        final height = offset < 0 ? _BackdropMetrics.max - offset : lerpDouble(_BackdropMetrics.max, _BackdropMetrics.min, t)!;
        final sigma = t * 16;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (sigma > 0.5)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
                  child: child,
                )
              else
                child!,
              DecoratedBox(decoration: AppDecorations(palette).backdropScrim),
              // The band behind the top bar has to stay dark enough to read
              // the back arrow off, whatever the still underneath is.
              ColoredBox(color: palette.surface.withValues(alpha: t * 0.35)),
            ],
          ),
        );
      },
      child: image,
    );
  }
}

/// The top of the sheet: the poster held to the left, everything the title is
/// named and rated by to the right of it.
class _Header extends StatelessWidget {
  final DetailsScaffold details;

  const _Header({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations(context.palette).detailSheet,
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            // The poster is positioned, so it contributes no height of its
            // own: the column beside it has to reserve the row's height, or a
            // title with a short name would let the poster run into the
            // synopsis below.
            constraints: BoxConstraints(minHeight: _posterHeight),
            child: Padding(
              padding: EdgeInsets.only(left: _posterWidth + AppSpacing.lg),
              child: _HeaderInfo(details: details),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: _posterWidth,
            child: PosterCard(
              imageUrl: details.posterUrl,
              title: details.title,
              heroTag: details.heroTag,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final DetailsScaffold details;

  const _HeaderInfo({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(details.title, style: context.styles.detailTitle),
        if (details.year case final year?) ...[
          AppGap.vertical(AppSpacing.sm),
          Text(year, style: context.styles.meta),
        ],
        if (details.rating case final rating?) ...[
          AppGap.vertical(AppSpacing.sm),
          _InlineRating(rating: rating, voteCount: details.voteCount),
        ],
        AppGap.vertical(AppSpacing.md),
        GenreTags(genreIds: details.genreIds, isSeries: details.isSeries, limit: 2),
      ],
    );
  }
}

class _Synopsis extends StatelessWidget {
  final String? overview;

  const _Synopsis({required this.overview});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (overview == null || overview!.isEmpty) {
      return ColoredBox(color: palette.sheet, child: SizedBox(height: AppSpacing.xl, width: double.infinity));
    }

    return ColoredBox(
      color: palette.sheet,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetSectionLabel(label: context.l10n.detailsSynopsis),
            AppGap.vertical(AppSpacing.sm),
            Text(overview!, style: context.styles.paragraph),
          ],
        ),
      ),
    );
  }
}

/// Back, the title once the artwork is too small to carry it, and whatever the
/// screen puts opposite the arrow.
class _TopBar extends StatelessWidget {
  final String title;
  final Widget? action;
  final ScrollController scroll;

  const _TopBar({required this.title, required this.action, required this.scroll});

  @override
  Widget build(BuildContext context) {
    final decorations = AppDecorations(context.palette);

    return AnimatedBuilder(
      animation: scroll,
      builder: (context, child) {
        final offset = scroll.hasClients ? scroll.offset : 0.0;
        final t = (offset / _BackdropMetrics.shrinkRun).clamp(0.0, 1.0);

        // The bar comes in over the whole of the artwork's collapse rather
        // than at the moment the sheet reaches it — the sheet needs more
        // scroll to arrive than the collapse takes, so it is under a finished
        // bar by the time it gets there, and the arrival is a slow wash
        // instead of a switch.
        final arrival = Curves.easeInOut.transform((t / 0.9).clamp(0.0, 1.0));

        return DecoratedBox(decoration: decorations.topBarScrim(arrival), child: child);
      },
      // The tail the scrim thins out over. Without it the gradient would have
      // to fade across the row itself, and the page would show through the
      // title rather than pass under it.
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg),
        child: _TopBarRow(title: title, action: action, scroll: scroll),
      ),
    );
  }
}

class _TopBarRow extends StatelessWidget {
  final String title;
  final Widget? action;
  final ScrollController scroll;

  const _TopBarRow({required this.title, required this.action, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleIconButton(
              icon: Icons.arrow_back_rounded,
              label: context.l10n.backAction,
              onPressed: () => context.router.maybePop(),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: scroll,
                builder: (context, child) {
                  final offset = scroll.hasClients ? scroll.offset : 0.0;
                  final t = (offset / _BackdropMetrics.shrinkRun).clamp(0.0, 1.0);

                  // The title only arrives once the artwork has gone soft
                  // enough that it cannot carry it any more.
                  return Opacity(opacity: ((t - 0.45) / 0.35).clamp(0.0, 1.0), child: child);
                },
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.styles.sectionLabel,
                ),
              ),
            ),
            // Balances the back button where there is nothing to put opposite
            // it, so the title sits centred rather than off to the right.
            action ?? SizedBox(width: 44.r),
          ],
        ),
      ),
    );
  }
}

class _InlineRating extends StatelessWidget {
  final double rating;
  final int? voteCount;

  const _InlineRating({required this.rating, this.voteCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: AppSpacing.lg, color: context.palette.accentSoft),
        AppGap.horizontal(AppSpacing.sm),
        Text(rating.toStringAsFixed(1), style: context.styles.ratingSmall),
        AppGap.horizontal(AppSpacing.sm),
        Flexible(
          child: Text(
            voteCount == null ? '/ 10' : '/ 10 · ${context.l10n.detailsVotes(voteCount!.compact)}',
            style: context.styles.meta,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
