import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/cubit/title_list_cubit.dart';
import '../../../../core/custom/app_error_view.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/custom/genre_tags.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';
import 'collapsing_list.dart';

/// One of the account's lists, on its own screen.
///
/// The four of them — liked films, liked series, films to watch, series to
/// watch — are the same screen: a back arrow, a name, how many titles are
/// under it, and a column of rows that folds a row away when it leaves the
/// list. What differs is the name, the sentence shown when it is empty, and
/// what a row says, so those arrive as arguments and the layout lives here
/// once.
///
/// It takes the state rather than reading a cubit, because each of those
/// screens provides a cubit of its own type and a widget cannot name four.
class TitleListView<T> extends StatelessWidget {
  /// The screen's name, in the header.
  final String title;

  /// Shown in place of the list when there is nothing in it.
  final String emptyMessage;

  final TitleListState<T> state;

  /// What identifies a row between one build and the next, so the list knows
  /// which row left and can fold that one away.
  final Object? Function(T title) idOf;

  final Widget Function(BuildContext context, T title, int index) rowBuilder;

  /// What the error view's retry button does.
  final VoidCallback onRetry;

  const TitleListView({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.state,
    required this.idOf,
    required this.rowBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: title,
          count: switch (state) {
            TitleListLoaded(:final titles) => titles.length,
            _ => null,
          },
        ),
        Expanded(
          child: switch (state) {
            TitleListLoading() => const Center(child: CircularProgressIndicator()),
            TitleListFailure(:final message) => AppErrorView(message: message, onRetry: onRetry),
            // The empty message belongs to the list rather than standing
            // beside it, so taking the last title out folds the row away and
            // leaves the message behind it.
            TitleListLoaded(:final titles) => CollapsingList<T>(
                items: titles,
                idOf: idOf,
                padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                emptyBuilder: (context) => Center(child: Text(emptyMessage, style: context.styles.meta)),
                itemBuilder: rowBuilder,
              ),
          },
        ),
      ],
    );
  }
}

/// The back arrow, the screen's name, and how many titles are under it.
class _Header extends StatelessWidget {
  final String title;
  final int? count;

  const _Header({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xxl, AppSpacing.lg),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            label: context.l10n.backAction,
            isFilled: false,
            onPressed: () => context.router.maybePop(),
          ),
          AppGap.horizontal(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.styles.screenTitle),
                if (count != null) ...[
                  AppGap.vertical(AppSpacing.xs / 2),
                  Text(context.l10n.titleListCount(count!).toUpperCase(), style: context.styles.sectionAction),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One title in one of those lists: its poster, what it is, and the mark
/// saying which list it is in.
///
/// Every field arrives already resolved — a film and a series keep their name
/// and their date under different field names, and this row is not the place
/// to know which is which.
class TitleListRow extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? year;
  final double? voteAverage;
  final List<int>? genreIds;
  final bool isSeries;

  /// The heart or the bookmark — which list this row is in, said once at the
  /// end of it.
  final IconData mark;

  final String heroTag;
  final VoidCallback onTap;

  const TitleListRow({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.year,
    required this.voteAverage,
    required this.genreIds,
    required this.mark,
    required this.heroTag,
    required this.onTap,
    this.isSeries = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: AppDecorations(palette).panel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62.w,
              child: PosterCard(imageUrl: imageUrl, title: title, heroTag: heroTag),
            ),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(title, style: context.styles.rowTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      AppGap.horizontal(AppSpacing.md),
                      if (voteAverage != null) ...[
                        Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
                        AppGap.horizontal(AppSpacing.xs),
                        Text(voteAverage!.toStringAsFixed(1), style: context.styles.ratingSmall),
                      ],
                    ],
                  ),
                  AppGap.vertical(AppSpacing.sm),
                  if (year case final year?) Text(year, style: context.styles.meta),
                  AppGap.vertical(AppSpacing.sm),
                  GenreTags(genreIds: genreIds, isSeries: isSeries, limit: 2),
                ],
              ),
            ),
            AppGap.horizontal(AppSpacing.md),
            Icon(mark, size: AppSpacing.xl, color: palette.accentSoft),
          ],
        ),
      ),
    );
  }
}
