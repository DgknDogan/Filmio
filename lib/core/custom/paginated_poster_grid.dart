import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_spacing.dart';
import '../cubit/load_more_state.dart';
import '../extensions/context_extension.dart';

/// A grid of posters that asks for the next page as the reader reaches the end
/// of this one.
///
/// The scroll is what pages, not a button: [onLoadMore] fires once the last
/// row is within [_reach] of the viewport, and the cubit behind it is expected
/// to ignore an ask it is already answering — this widget will call again on
/// the next frames while the fetch is in flight.
class PaginatedPosterGrid extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Whether there is a page after the one on screen.
  final bool hasMore;

  /// What the foot of the grid is doing, so a failed page can be reported and
  /// retried without disturbing what has already been read.
  final LoadMoreState more;

  final VoidCallback onLoadMore;

  const PaginatedPosterGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.hasMore,
    required this.more,
    required this.onLoadMore,
  });

  /// How near the end of the grid the reader has to be for the next page to be
  /// asked for. Roughly two rows: enough that the page is usually there before
  /// it is reached, and not so much that a browse of the first screen fetches
  /// three pages nobody looked at.
  static double get _reach => 600;

  @override
  State<PaginatedPosterGrid> createState() => _PaginatedPosterGridState();
}

class _PaginatedPosterGridState extends State<PaginatedPosterGrid> {
  bool _shouldAsk(ScrollNotification notification) {
    if (notification.depth > 0) return false;
    if (!widget.hasMore) return false;
    // A page already in flight, or one that failed and is waiting to be
    // retried by hand — neither is an invitation to ask again.
    if (widget.more is! LoadMoreIdle) return false;

    return notification.metrics.extentAfter < PaginatedPosterGrid._reach;
  }

  bool _onScroll(ScrollNotification notification) {
    if (_shouldAsk(notification)) widget.onLoadMore();

    // Answered, not consumed.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 2 / 3,
              ),
              delegate: SliverChildBuilderDelegate(widget.itemBuilder, childCount: widget.itemCount),
            ),
          ),
          SliverToBoxAdapter(child: _GridFoot(hasMore: widget.hasMore, more: widget.more, onRetry: widget.onLoadMore)),
        ],
      ),
    );
  }
}

/// What sits under the last row: the next page arriving, the reason it did
/// not, or the room the tab bar floats over.
class _GridFoot extends StatelessWidget {
  final bool hasMore;
  final LoadMoreState more;
  final VoidCallback onRetry;

  const _GridFoot({required this.hasMore, required this.more, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final foot = Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: switch (more) {
        LoadMoreInProgress() => Center(
            child: SizedBox(
              height: 20.r,
              width: 20.r,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.palette.accent),
            ),
          ),
        LoadMoreFailure(:final message) => Column(
            children: [
              Text(message, textAlign: TextAlign.center, style: context.styles.meta),
              TextButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
            ],
          ),
        LoadMoreIdle() => AppGap.vertical(AppSpacing.xxl),
      },
    );

    return hasMore || more is! LoadMoreIdle ? foot : AppGap.vertical(AppSpacing.xxl);
  }
}
