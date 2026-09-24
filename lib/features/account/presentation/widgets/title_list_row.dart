import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/genre_tags.dart';
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';

/// One title in an account list: its poster, what it is, and the [badge] that
/// says why it is in this list.
///
/// Takes the fields rather than an entity, so a film and a series share it;
/// [MovieListRow] and [SeriesListRow] do the reading.
class TitleListRow extends StatelessWidget {
  final String posterUrl;
  final String title;
  final String? year;
  final double? rating;
  final List<int>? genreIds;
  final bool isSeries;
  final String heroTag;
  final IconData badge;
  final VoidCallback onTap;

  const TitleListRow({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.year,
    required this.rating,
    required this.genreIds,
    required this.isSeries,
    required this.heroTag,
    required this.badge,
    required this.onTap,
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
              child: PosterCard(imageUrl: posterUrl, title: title, heroTag: heroTag),
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
                        child: Text(
                          title,
                          style: context.styles.rowTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppGap.horizontal(AppSpacing.md),
                      if (rating != null) ...[
                        Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
                        AppGap.horizontal(AppSpacing.xs),
                        Text(rating!.toStringAsFixed(1), style: context.styles.ratingSmall),
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
            Icon(badge, size: AppSpacing.xl, color: palette.accentSoft),
          ],
        ),
      ),
    );
  }
}
