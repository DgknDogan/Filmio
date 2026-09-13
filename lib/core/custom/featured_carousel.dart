import 'dart:async';

import 'package:flutter/material.dart';

/// What the still part of a [FeaturedCarousel] is handed to draw itself and to
/// drive the moving part.
class FeaturedCarouselControls {
  /// The title the still part shows. It follows the pages
  /// [FeaturedCarousel.followDelay] behind: the artwork sets off first, and
  /// the rest comes after it.
  final int shown;

  /// Step to the title before and the title after. Null when there is only
  /// one title and nowhere to step to.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const FeaturedCarouselControls({required this.shown, this.onPrevious, this.onNext});
}

/// The featured block stepping through its titles, round and round.
///
/// Two layers. The pages slide — one per title, built by [pageBuilder]; in
/// practice, only the artwork. Over them, [overlayBuilder] draws everything
/// that stays where it is: what changes in place rather than sliding, and
/// what does not change at all.
///
/// Only the arrows the overlay is handed move the pages; they do not swipe.
/// The still layer is told which title to show [followDelay] after an arrow
/// sets the pages off towards it. Arrows pressed faster than that skip the
/// titles in between rather than flicking through them.
///
/// There is no end in either direction: after the last title comes the first
/// again, and before the first comes the last. Underneath it is a [PageView]
/// with no page count, started a long way in, that reads each page's title off
/// its number — so there is always as far to go back as there is to go on.
///
/// A single title is drawn on its own, and the overlay is handed no arrows:
/// every step would land on the same title again.
///
/// Which title is showing lives here rather than in a bloc, as the page's
/// scroll does in `BrowseView`: nothing outside the block reads it.
class FeaturedCarousel extends StatefulWidget {
  /// How far behind the pages the still layer follows.
  static const Duration followDelay = Duration(milliseconds: 200);

  /// How many titles there are to step through. At least one.
  final int count;

  /// The part of the block that belongs to the title at [index], and slides.
  final Widget Function(BuildContext context, int index) pageBuilder;

  /// The part of the block that stays put over the pages.
  final Widget Function(BuildContext context, FeaturedCarouselControls controls) overlayBuilder;

  const FeaturedCarousel({
    super.key,
    required this.count,
    required this.pageBuilder,
    required this.overlayBuilder,
  }) : assert(count > 0);

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  /// How many times round the titles the carousel starts. No reader steps
  /// back that far.
  static const int _laps = 1000;

  static const Duration _stepDuration = Duration(milliseconds: 350);

  late PageController _pages = _startingOver();

  /// The page the arrows are taking the carousel to. Kept rather than read
  /// off the controller: a second press while the first step is still under
  /// way has to go one further, not land on the same page again.
  late int _targetPage = _pages.initialPage;

  final ValueNotifier<int> _shown = ValueNotifier(0);
  Timer? _follow;

  /// Not kept in page storage: a page number saved against one set of titles
  /// is a different title — or none — once the set has changed.
  PageController _startingOver() => PageController(initialPage: widget.count * _laps, keepPage: false);

  @override
  void didUpdateWidget(FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count == oldWidget.count) return;

    // A different number of titles puts every one of them on a different page,
    // so the carousel starts over at the first. The old page view goes with
    // the old controller; it is disposed once that has happened.
    final previous = _pages;
    _pages = _startingOver();
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());

    _targetPage = _pages.initialPage;
    _follow?.cancel();
    _shown.value = 0;
  }

  @override
  void dispose() {
    _follow?.cancel();
    _shown.dispose();
    _pages.dispose();
    super.dispose();
  }

  /// Hands the still layer [page]'s title once the artwork has had a head
  /// start. A newer destination replaces one still waiting.
  void _followTo(int page) {
    _follow?.cancel();
    _follow = Timer(FeaturedCarousel.followDelay, () => _shown.value = page % widget.count);
  }

  void _step(int by) {
    _targetPage += by;
    _pages.animateToPage(_targetPage, duration: _stepDuration, curve: Curves.easeInOut);
    _followTo(_targetPage);
  }

  void _stepBack() => _step(-1);

  void _stepOn() => _step(1);

  @override
  Widget build(BuildContext context) {
    final many = widget.count > 1;

    return Stack(
      fit: StackFit.expand,
      // The pages' artwork reaches up past the top of the block into an
      // overscrolled page.
      clipBehavior: Clip.none,
      children: [
        if (many)
          PageView.builder(
            // A page view handed a new controller carries its old offset
            // across into it, which would land the carousel mid-way through
            // the new titles. Keyed on the count, it is a new page view
            // instead, and opens where the new controller says.
            key: ValueKey(widget.count),
            controller: _pages,
            // The arrows are the only way through the titles.
            physics: const NeverScrollableScrollPhysics(),
            // A clipping page view would cut the artwork's stretch off at its
            // own edge.
            clipBehavior: Clip.none,
            itemBuilder: (context, page) => widget.pageBuilder(context, page % widget.count),
          )
        else
          widget.pageBuilder(context, 0),
        // Over the pages rather than on them, so it stays put while they move.
        ValueListenableBuilder<int>(
          valueListenable: _shown,
          builder: (context, shown, _) => widget.overlayBuilder(
            context,
            FeaturedCarouselControls(
              shown: shown,
              onPrevious: many ? _stepBack : null,
              onNext: many ? _stepOn : null,
            ),
          ),
        ),
      ],
    );
  }
}
