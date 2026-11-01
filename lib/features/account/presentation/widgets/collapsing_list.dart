import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';

/// A list whose rows leave by collapsing rather than by vanishing.
///
/// The liked lists read themselves again when a title's own screen closes,
/// because the like may have been taken back while it was open. Rebuilding
/// with one row fewer is the right answer and reads as a fault: everything
/// below jumps up in a single frame, and it happens while the poster is still
/// flying back into a row that is no longer there — `router.push` hands
/// control back when the pop begins, not when it ends.
///
/// So this holds the rows it is showing, waits for the screen above to finish
/// getting out of the way, and then sends the rows that have gone out to the
/// left before closing the space they leave. Any other change — a title
/// arriving, the order changing — is not something closing a details screen
/// produces, so it is drawn rather than animated.
class CollapsingList<T> extends StatefulWidget {
  /// How long a row takes to leave: out to the left, then the space closing
  /// behind it.
  static const collapse = Duration(milliseconds: 320);

  final List<T> items;

  /// What makes a row the same row across a reread. Compared rather than the
  /// item itself, because the same title comes back from Firestore with its
  /// rating and popularity moved on.
  final Object? Function(T item) idOf;

  /// [index] is where the row sits as it is drawn — what a poster's hero tag
  /// is built from. A row on its way out keeps the index it had.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// What stands where the list would be once the last row has folded away.
  final WidgetBuilder emptyBuilder;

  final EdgeInsetsGeometry padding;

  const CollapsingList({
    super.key,
    required this.items,
    required this.idOf,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.padding,
  });

  @override
  State<CollapsingList<T>> createState() => _CollapsingListState<T>();
}

class _CollapsingListState<T> extends State<CollapsingList<T>> {
  /// What is on screen, which lags [CollapsingList.items] for as long as a row
  /// is folding away.
  late List<T> _shown = [...widget.items];

  /// How many rows are mid-fold. The empty message waits for them: a list of
  /// none still has its last row on screen until the fold has finished.
  int _leaving = 0;

  /// Rebuilt with the list, for a change that cannot be animated.
  GlobalKey<AnimatedListState> _listKey = GlobalKey();

  /// The screen above getting out of the way, while it still is.
  Animation<double>? _settling;
  void Function(AnimationStatus status)? _onSettled;

  @override
  void didUpdateWidget(covariant CollapsingList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sameRows(widget.items)) {
      // The same rows, reread — their details may have moved on.
      _shown = [...widget.items];
      return;
    }

    _whenSettled(_reconcile);
  }

  @override
  void dispose() {
    _stopSettling();
    super.dispose();
  }

  bool _sameRows(List<T> incoming) {
    if (incoming.length != _shown.length) return false;

    return Iterable<int>.generate(incoming.length).every((index) => widget.idOf(incoming[index]) == widget.idOf(_shown[index]));
  }

  /// Runs [then] once the screen above has finished closing, or at once when
  /// there is no screen above to wait for.
  void _whenSettled(VoidCallback then) {
    _stopSettling();

    final secondary = ModalRoute.of(context)?.secondaryAnimation;
    if (secondary == null || secondary.status == AnimationStatus.dismissed) {
      then();
      return;
    }

    void onStatus(AnimationStatus status) {
      if (status != AnimationStatus.dismissed) return;

      _stopSettling();
      if (mounted) then();
    }

    _settling = secondary;
    _onSettled = onStatus;
    secondary.addStatusListener(onStatus);
  }

  void _stopSettling() {
    final listener = _onSettled;
    if (listener != null) _settling?.removeStatusListener(listener);

    _settling = null;
    _onSettled = null;
  }

  void _reconcile() {
    final incoming = widget.items;
    final incomingIds = {for (final item in incoming) widget.idOf(item)};
    final kept = [
      for (final item in _shown)
        if (incomingIds.contains(widget.idOf(item))) item,
    ];

    // Only a removal can be folded away: what is left has to be what arrived,
    // in the order it arrived in. Anything else starts the list over.
    final isRemovalOnly = kept.length == incoming.length &&
        Iterable<int>.generate(kept.length).every((index) => widget.idOf(kept[index]) == widget.idOf(incoming[index]));

    if (!isRemovalOnly) {
      setState(() {
        _shown = [...incoming];
        _leaving = 0;
        _listKey = GlobalKey();
      });
      return;
    }

    // Backwards, so an index is still the index of the row it names.
    for (var index = _shown.length - 1; index >= 0; index--) {
      if (incomingIds.contains(widget.idOf(_shown[index]))) continue;

      final leaving = _shown.removeAt(index);
      _leaving++;
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _Leaving(animation: animation, child: _row(context, leaving, index)),
        duration: CollapsingList.collapse,
      );
    }

    setState(() => _shown = [...incoming]);

    if (_leaving > 0) {
      Timer(CollapsingList.collapse, () {
        if (mounted) setState(() => _leaving = 0);
      });
    }
  }

  /// A row with the gap that follows it, so the two fold away together.
  Widget _row(BuildContext context, T item, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: widget.itemBuilder(context, item, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shown.isEmpty && _leaving == 0) return widget.emptyBuilder(context);

    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      initialItemCount: _shown.length,
      itemBuilder: (context, index, animation) => _row(context, _shown[index], index),
    );
  }
}

/// A row on its way out: it slides off to the left and fades as it goes, and
/// only once it is gone does the space it held close up. Two movements at once
/// on the same row read as one thing going wrong rather than as one thing
/// leaving.
///
/// The animation a removal is handed runs backwards, from one down to nought,
/// so the first half of the exit is the *top* of the range — which is why the
/// slide takes the later interval and the close the earlier one, and why the
/// curve that accelerates the row away is [Curves.easeOut] rather than the
/// [Curves.easeIn] it would be going the other way.
class _Leaving extends StatelessWidget {
  /// The row leaving, over the first part of the exit.
  static const _slide = Interval(0.4, 1, curve: Curves.easeOut);

  /// The space closing, over the rest of it.
  static const _close = Interval(0, 0.4, curve: Curves.easeInOut);

  final Animation<double> animation;
  final Widget child;

  const _Leaving({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final leaving = CurvedAnimation(parent: animation, curve: _slide);

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: _close),
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: leaving,
        child: SlideTransition(
          // A whole width to the left, which with the fade finishing alongside
          // it puts the row out of sight before the space starts closing.
          position: leaving.drive(Tween(begin: const Offset(-1, 0), end: Offset.zero)),
          child: child,
        ),
      ),
    );
  }
}
