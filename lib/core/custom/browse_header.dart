import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'circle_icon_button.dart';

/// The top of a browse-all screen: the way back, what is being browsed, how
/// many titles that is, and the way to narrow it.
///
/// Fixed above the grid rather than scrolling with it — the filter control is
/// the point of the screen, and a reader four pages down is exactly the reader
/// most likely to want it.
class BrowseHeader extends StatelessWidget {
  final String title;

  /// Null while the first page is still loading: the screen does not yet know
  /// how many titles it is showing, and a nought would be a wrong answer
  /// rather than a missing one.
  final String? resultLabel;

  /// How many filters are in force, which the control says out loud so the
  /// reader knows why they are seeing a short list.
  final int activeFilterCount;

  final VoidCallback onFilter;

  const BrowseHeader({
    super.key,
    required this.title,
    required this.resultLabel,
    required this.activeFilterCount,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xxl, AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  label: context.l10n.backAction,
                  onPressed: () => context.router.maybePop(),
                ),
                AppGap.horizontal(AppSpacing.md),
                Expanded(
                  child: Text(title, style: context.styles.screenTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            AppGap.vertical(AppSpacing.md),
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(resultLabel?.toUpperCase() ?? '', style: context.styles.sectionLabel),
                  GestureDetector(
                    onTap: onFilter,
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded, size: AppSpacing.lg, color: context.palette.accent),
                        AppGap.horizontal(AppSpacing.sm),
                        Text(
                          context.l10n.filtersAction(activeFilterCount).toUpperCase(),
                          style: context.styles.sectionAction,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
