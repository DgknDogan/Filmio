import 'package:flutter/material.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_tag.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/taste_profile.dart';

/// What the account's lists add up to, over the identity and above the rows
/// that open them.
///
/// Every figure is derived from lists the tab has already read, so this costs
/// no request — and it is the one part of the screen that tells the reader
/// something they did not already know about themselves.
class TasteProfileCard extends StatelessWidget {
  final TasteProfile profile;

  const TasteProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations(context.palette).panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.tasteTitle.toUpperCase(), style: context.styles.sectionLabel),
          AppGap.vertical(AppSpacing.md),
          // Nothing liked means every figure below would be a dash, which
          // reads as a screen that failed rather than one waiting for you.
          if (profile.hasNoTaste)
            Text(context.l10n.tasteEmpty, style: context.styles.meta)
          else ...[
            if (profile.topGenres.isNotEmpty) ...[
              Text(context.l10n.tasteGenres, style: context.styles.meta),
              AppGap.vertical(AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final (index, genre) in profile.topGenres.indexed) AppTag(name: genre, isPrimary: index == 0),
                ],
              ),
              AppGap.vertical(AppSpacing.lg),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A dash rather than a hidden tile: the row keeps its shape
                // between two accounts, and an absent figure is a thing the
                // catalogue did not say rather than a tile that moved.
                _Figure(label: context.l10n.tasteDecade, value: profile.favouriteDecade ?? '—'),
                _Figure(label: context.l10n.tasteRating, value: profile.averageRating?.toStringAsFixed(1) ?? '—'),
                _Figure(label: context.l10n.tasteLiked, value: '${profile.likedMovies + profile.likedSeries}'),
                _Figure(label: context.l10n.tasteWatchlist, value: '${profile.watchlistTotal}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One figure and what it is of, in a column of its own so four of them share
/// the width evenly however long their values are.
class _Figure extends StatelessWidget {
  final String label;
  final String value;

  const _Figure({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.styles.rowTitle),
          AppGap.vertical(AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: context.styles.sectionLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
