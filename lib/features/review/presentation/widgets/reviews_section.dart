import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/cubit/load_more_state.dart';
import '../../../../core/custom/section_header.dart';
import '../../../../core/extensions/context_extension.dart';
import '../cubit/reviews_cubit.dart';
import 'review_card.dart';

/// What a film's and a series' details screen both hang under their synopsis:
/// the reviews TMDB holds for the title, a page at a time.
///
/// It reads the [ReviewsCubit] the page provides, so the two screens differ
/// only in which title they stand it up for.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.sheet,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
        child: BlocBuilder<ReviewsCubit, ReviewsState>(
          builder: (context, state) {
            return switch (state) {
              ReviewsLoading() => SizedBox(height: 96.h, child: const Center(child: CircularProgressIndicator())),
              ReviewsFailure(:final message) => _SectionFailure(message: message),
              // A title nobody has reviewed gets no heading either: an empty
              // block under the synopsis would read as something failing.
              ReviewsLoaded(:final reviews) when reviews.isEmpty => const SizedBox.shrink(),
              ReviewsLoaded() => _ReviewList(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final ReviewsLoaded state;

  const _ReviewList({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.reviewsTitle),
        AppGap.vertical(AppSpacing.xs),
        // The count is of every review there is, not of the pages read so far.
        Text(context.l10n.reviewsCount(state.totalResults), style: context.styles.meta),
        AppGap.vertical(AppSpacing.md),
        // The page is already one scroll; a list of its own inside it would be
        // a second, so the cards are laid out rather than scrolled.
        for (final review in state.reviews) ...[
          ReviewCard(key: ValueKey(review.id), review: review),
          AppGap.vertical(AppSpacing.md),
        ],
        _ListFoot(state: state),
      ],
    );
  }
}

/// Where the paging shows: a way to ask for the next page, what happened to
/// the last ask, or nothing at all once the list is complete.
class _ListFoot extends StatelessWidget {
  final ReviewsLoaded state;

  const _ListFoot({required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasMore) return const SizedBox.shrink();

    return switch (state.more) {
      LoadMoreInProgress() => SizedBox(
          height: 44.h,
          child: Center(
            child: SizedBox(
              height: 20.r,
              width: 20.r,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.palette.accent),
            ),
          ),
        ),
      LoadMoreFailure(:final message) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: context.styles.meta),
            _LoadMoreButton(label: context.l10n.tryAgain),
          ],
        ),
      LoadMoreIdle() => _LoadMoreButton(label: context.l10n.reviewsLoadMore),
    };
  }
}

class _LoadMoreButton extends StatelessWidget {
  final String label;

  const _LoadMoreButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => context.read<ReviewsCubit>().loadMore(),
        child: Text(label),
      ),
    );
  }
}

/// The first page failed, so there is nothing to keep on screen — the block
/// says so and offers to ask again.
class _SectionFailure extends StatelessWidget {
  final String message;

  const _SectionFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.reviewsTitle),
        AppGap.vertical(AppSpacing.sm),
        Text(message, style: context.styles.meta),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.read<ReviewsCubit>().loadFirstPage(),
            child: Text(context.l10n.tryAgain),
          ),
        ),
      ],
    );
  }
}
