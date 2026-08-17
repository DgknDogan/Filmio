import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_spacing.dart';
import 'section_header.dart';

/// A heading and the row of posters under it.
///
/// The heading is inset to the page gutter but the row is not: the posters
/// run off the right edge, which is what tells the reader there are more of
/// them than fit.
class PosterRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final PageStorageKey<String> storageKey;

  /// One `PosterCard` per title. The row sizes them; they only have to draw.
  final List<Widget> posters;

  /// Set by a page that has to know where the heading is rather than where the
  /// row is — the movie tab snaps to it.
  final Key? headingKey;

  const PosterRow({
    super.key,
    required this.title,
    required this.storageKey,
    required this.posters,
    this.actionLabel,
    this.onAction,
    this.headingKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          key: headingKey,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: SectionHeader(title: title, actionLabel: actionLabel, onAction: onAction),
        ),
        AppGap.vertical(AppSpacing.md),
        SizedBox(
          // 112 wide at 2:3.
          height: 168.h,
          child: ListView.separated(
            key: storageKey,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            itemCount: posters.length,
            separatorBuilder: (context, index) => AppGap.horizontal(AppSpacing.md),
            itemBuilder: (context, index) => SizedBox(width: 112.w, child: posters[index]),
          ),
        ),
      ],
    );
  }
}
