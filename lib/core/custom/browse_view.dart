import 'dart:math' show max;
import 'dart:ui' show clampDouble, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_decorations.dart';
import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'custom_searchbar.dart';
import 'featured_hero.dart';
import 'poster_row.dart';

/// The height the app's search field is drawn at, taken from the field itself:
/// the bar and the search screen have to agree on it, and on the padding above
/// it, or the flight between them starts by jumping.
double get _fieldHeight => searchFieldHeight;

/// Room under the last row. The page has to be able to scroll a whole block
/// past the top for the snap to have anywhere to land.
double get _foot => 500.h;

/// How near an end the page has to be let go for that end to take it.
///
/// Only the last stretch at either end pulls. Everywhere between them the page
/// is left exactly where the reader let go of it — a page that always snapped
/// would be one that could not be read half way down the block.
const double _pull = 0.20;

/// How much of the opening block has been scrolled away, 0 to 1.
///
/// Two things run off it and have to run off it together: the block fading
/// out, and the bar taking on the ground the block is giving up. Tying the bar
/// to the search field instead makes it arrive in one step, half way through,
/// while the block is still fading.
double _gone(ScrollController scroll) {
  final offset = scroll.hasClients ? scroll.offset : 0.0;

  return (offset / FeaturedHero.height).clamp(0.0, 1.0);
}

/// One heading and the posters under it.
///
/// Data rather than a built [PosterRow]: the view hangs its own keys off the
/// first row to find the page's resting place, and it cannot do that to a row
/// it was handed already assembled.
class BrowseRow {
  final String title;
  final PageStorageKey<String> storageKey;

  /// One `PosterCard` per title.
  final List<Widget> posters;

  const BrowseRow({required this.title, required this.storageKey, required this.posters});
}

/// A tab that opens on one title's artwork and continues into rows of posters.
///
/// One scroll with a bar floating over it. The recommendation at the head of
/// the page washes out into the page's own ground as it leaves, and half way
/// through that the search button springs open into a field.
///
/// Both the films tab and the series tab are this view with their own titles
/// in it — the scroll, the snap and the bar are the same machine, and keeping
/// one copy of it is what stops the two tabs drifting apart.
class BrowseView extends StatefulWidget {
  /// The block the page opens with, given how far past the top of itself its
  /// artwork should reach. A [FeaturedHero] in practice: the view hands it the
  /// overscroll and takes care of fading it out.
  final Widget Function(BuildContext context, double stretch) featuredBuilder;

  final List<BrowseRow> rows;

  /// What the collapsed control shares with the search screen's field, so the
  /// one becomes the other.
  final Object searchHeroTag;

  final String searchHint;

  /// Opens the search screen. The control in the bar is not a field that can
  /// be typed in — this is the way in.
  final VoidCallback onSearch;

  const BrowseView({
    super.key,
    required this.featuredBuilder,
    required this.rows,
    required this.searchHeroTag,
    required this.searchHint,
    required this.onSearch,
  });

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> with SingleTickerProviderStateMixin {
  /// Scroll position is not screen state — nothing outside this widget reads
  /// it — so it stays here and drives the page through listeners rather than
  /// through the bloc or `setState`.
  final ScrollController _scroll = ScrollController();

  /// The bar's two modes. It is a controller rather than a reading off the
  /// scroll because the field does not track the finger: it is let go at the
  /// half way mark and springs the rest of the way on its own.
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    reverseDuration: const Duration(milliseconds: 350),
  );

  late final Animation<double> _expansion = CurvedAnimation(
    parent: _bar,
    curve: Curves.easeInOut,
    reverseCurve: Curves.easeInOut,
  );

  /// Set while the page is animating itself, so the snap does not hear its own
  /// scroll end and fire again.
  bool _snapping = false;

  /// The first row of posters and the bar over it, so the page can ask the
  /// layout where they are rather than being told a number.
  final GlobalKey _firstRow = GlobalKey();
  final GlobalKey _firstHeading = GlobalKey();
  final GlobalKey _barKey = GlobalKey();

  /// The offset the block is read as gone at: the first row's heading clear of
  /// the bar, with a gutter under it.
  ///
  /// Measured rather than declared. The block's height belongs to
  /// [FeaturedHero] and the bar's to itself; copies of either kept here would
  /// go stale the first time one of them changed. Cached because the field's
  /// trigger reads it on every scrolled frame; dropped whenever the layout it
  /// was read from can have changed.
  double? _blockPast;

  double? _blockGone() {
    if (_blockPast != null) return _blockPast;

    final row = _firstRow.currentContext?.findRenderObject();
    final bar = _barKey.currentContext?.findRenderObject();
    if (row is! RenderBox || !row.attached) return null;
    if (bar is! RenderBox || !bar.attached) return null;

    final rowTop = RenderAbstractViewport.of(row).getOffsetToReveal(row, 0).offset;

    // The bar floats over the scroll rather than above it, so a row brought to
    // the top of the viewport is a row with its heading behind the bar.
    return _blockPast = rowTop - bar.size.height - AppSpacing.xl;
  }

  /// The offset the heading itself is gone at — the resting place above, plus
  /// the gutter and the heading that sat in it.
  ///
  /// Everything between the two is still the resting place half left: the
  /// heading is on its way behind the bar and the row under it is cut. Let go
  /// in there and the page goes back.
  double? _headingGone(double block) {
    if (_headingPast != null) return _headingPast;

    final heading = _firstHeading.currentContext?.findRenderObject();
    if (heading is! RenderBox || !heading.attached) return null;

    return _headingPast = block + AppSpacing.xl + heading.size.height;
  }

  double? _headingPast;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_watchForField);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A new viewport — a rotation, a split view — puts the row somewhere else.
    _blockPast = null;
    _headingPast = null;
  }

  @override
  void didUpdateWidget(BrowseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different set of rows is a different first row, and the resting place
    // measured off the old one no longer describes it.
    if (widget.rows.length != oldWidget.rows.length) {
      _blockPast = null;
      _headingPast = null;
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_watchForField);
    _scroll.dispose();
    _bar.dispose();
    super.dispose();
  }

  void _watchForField() {
    final block = _blockGone();
    if (block == null) return;

    // Half way through the block.
    final wantsField = _scroll.offset > block / 2;

    if (wantsField && _bar.status != AnimationStatus.forward && !_bar.isCompleted) {
      _bar.forward();
    } else if (!wantsField && _bar.status != AnimationStatus.reverse && !_bar.isDismissed) {
      _bar.reverse();
    }
  }

  /// Finishes the block off when the page is let go near either end of it.
  bool _snap(ScrollEndNotification notification) {
    // The poster rows scroll too, and their ends arrive here as well.
    if (notification.depth > 0 || _snapping) return false;

    final block = _blockGone();
    if (block == null || block <= 0) return false;

    final offset = _scroll.offset;
    if (offset <= 0) return false;

    // The foot under the last row is there to give the snap somewhere to land,
    // not to be read. Coming to rest at the end of it means the page has run
    // out, so it climbs back to the first row rather than leaving the reader
    // holding a screen of nothing. One pixel of tolerance: the end of a scroll
    // is rarely the exact number.
    if (_scroll.position.extentAfter < 1) return _snapTo(block);

    if (offset >= block) {
      // Just past the resting place, with the heading half behind the bar:
      // back to it.
      final heading = _headingGone(block);

      return heading != null && offset < heading ? _snapTo(block) : false;
    }

    final target = switch (offset / block) {
      < _pull => 0.0,
      > 1 - _pull => block,
      // Left in the middle on purpose: the reader stopped there.
      _ => null,
    };

    return target == null ? false : _snapTo(target);
  }

  /// Always returns false — the notification is answered, not consumed.
  bool _snapTo(double target) {
    _snapping = true;

    // The notification arrives mid-scroll-update; the position cannot be
    // driven again until that has finished being delivered.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scroll.hasClients) return;

      await _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );

      _snapping = false;
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollEndNotification>(
          onNotification: _snap,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: _Featured(builder: widget.featuredBuilder, scroll: _scroll),
              ),
              SliverPadding(
                padding: AppInsets.tabBody,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final (index, row) in widget.rows.indexed) ...[
                      if (index > 0) AppGap.vertical(AppSpacing.xxl),
                      PosterRow(
                        // Only the first row is measured — it is the one the
                        // page comes to rest on.
                        key: index == 0 ? _firstRow : null,
                        headingKey: index == 0 ? _firstHeading : null,
                        title: row.title,
                        storageKey: row.storageKey,
                        posters: row.posters,
                      ),
                    ],
                    AppGap.vertical(_foot),
                  ]),
                ),
              ),
            ],
          ),
        ),
        _TopBar(
          key: _barKey,
          expansion: _expansion,
          scroll: _scroll,
          searchHeroTag: widget.searchHeroTag,
          searchHint: widget.searchHint,
          onSearch: widget.onSearch,
        ),
      ],
    );
  }
}

/// The block the page opens with: how it stretches, and how it leaves.
class _Featured extends StatelessWidget {
  final Widget Function(BuildContext context, double stretch) builder;
  final ScrollController scroll;

  const _Featured({required this.builder, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scroll,
      builder: (context, child) {
        final offset = scroll.hasClients ? scroll.offset : 0.0;

        // Read off the block's own height rather than off where the page has
        // got to: it is the block that is leaving, and it is gone when there
        // is none of it left.
        return Opacity(
          opacity: clampDouble(1 - _gone(scroll) * 1.5, 0, 1),
          child: builder(context, max(0.0, -offset)),
        );
      },
    );
  }
}

/// The word mark, and the search control that grows beside it.
class _TopBar extends StatelessWidget {
  /// 0 is a button, 1 is a field. Springs, so it passes 1 and comes back.
  final Animation<double> expansion;

  /// The bar's ground is not the field's business: it comes in with the scroll,
  /// as the block below fades.
  final ScrollController scroll;

  final Object searchHeroTag;
  final String searchHint;
  final VoidCallback onSearch;

  const _TopBar({
    super.key,
    required this.expansion,
    required this.scroll,
    required this.searchHeroTag,
    required this.searchHint,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final decorations = AppDecorations(context.palette);

    return AnimatedBuilder(
      animation: Listenable.merge([scroll, expansion]),
      builder: (context, child) {
        final spring = expansion.value;
        final settled = spring.clamp(0.0, 1.0);

        return DecoratedBox(
          // The ground the block gives up, the bar takes on — at the same rate,
          // so the two read as one exchange rather than as two events.
          decoration: decorations.topBarScrim(_gone(scroll)),
          child: SafeArea(
            bottom: false,
            child: Padding(
              // The same gutter and the same room above the field that
              // `SearchBarRow` gives it on the search screen.
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
              child: SizedBox(
                height: _fieldHeight,
                child: Row(
                  children: [
                    // The word mark stays put through the whole scroll. The
                    // field grows into what is left of the row beside it
                    // rather than over it.
                    Text(context.l10n.appName.toUpperCase(), style: context.styles.brandSmall),
                    AppGap.horizontal(AppSpacing.lg),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _SearchControl(
                          spring: spring,
                          settled: settled,
                          heroTag: searchHeroTag,
                          hint: searchHint,
                          onTap: onSearch,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The search button and the search field are one control at two widths.
///
/// It is not a field that can be typed in: tapping it opens the search screen,
/// which has the real one. What it does is say what is about to happen, in the
/// shape of the thing that will happen.
class _SearchControl extends StatelessWidget {
  /// The spring's own value, which overshoots 1 and settles back through it.
  final double spring;

  /// The same value with the overshoot taken off, for the things that would
  /// look wrong going past their end: colours, opacities, the ground.
  final double settled;

  final Object heroTag;
  final String hint;
  final VoidCallback onTap;

  /// The ring `CircleIconButton` draws, so the collapsed end of this reads as
  /// the same button the other tabs have.
  static double get _buttonSize => 38.r;

  const _SearchControl({
    required this.spring,
    required this.settled,
    required this.heroTag,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The overshoot past the full width has nowhere to go — the bar is
        // already that wide — so it is the undershoot on the way back that
        // the spring is read from.
        final width = lerpDouble(_buttonSize, constraints.maxWidth, spring)!.clamp(_buttonSize, constraints.maxWidth);

        return Semantics(
          button: true,
          label: hint,
          child: GestureDetector(
            onTap: onTap,
            // Where the search screen's field comes from and goes back to.
            child: Hero(
              tag: heroTag,
              child: Container(
                width: width,
                height: lerpDouble(_buttonSize, _fieldHeight, settled),
                decoration: BoxDecoration(
                  // The button sits on artwork and the field sits on the page,
                  // so the fill has to travel too.
                  color: Color.lerp(palette.surface.withValues(alpha: 0.7), palette.surfaceRaised, settled),
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(color: palette.inputBorder),
                ),
                // The field's own insides rather than a copy of them, so the
                // hint is in the same place here as it is on the search screen
                // and the flight between the two does not step. Disabled: the
                // way in is the tap above, not the keyboard. What is too
                // narrow to show — the hint, while this is still a button — is
                // clipped rather than faded.
                child: ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: SearchFieldContent(
                    isEnabled: false,
                    hintText: hint,
                    iconColor: Color.lerp(palette.textPrimary, palette.textSecondary, settled),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
