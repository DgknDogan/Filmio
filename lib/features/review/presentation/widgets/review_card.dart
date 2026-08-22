import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_network_image.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../domain/entities/review_entity.dart';

/// One review: who wrote it, what they scored it, and what they said.
///
/// Reviews run long — TMDB has no length limit — so the text is cut off after
/// a few lines and opens on a tap. Whether this one is open is not screen
/// state: nothing outside the card acts on it, and it dies with the card.
class ReviewCard extends StatefulWidget {
  final ReviewEntity review;

  /// How much of a closed review is shown.
  static const collapsedLines = 5;

  const ReviewCard({super.key, required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final content = review.content ?? '';

    return Container(
      decoration: AppDecorations(context.palette).panel,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorLine(review: review),
          if (content.isNotEmpty) ...[
            AppGap.vertical(AppSpacing.md),
            _Content(
              content: content,
              expanded: _expanded,
              onToggle: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }
}

/// What the review says, and the way into the rest of it.
///
/// The text is measured at the width it is about to be drawn in, so the toggle
/// only appears on a review that is actually cut off — a two-line one has
/// nothing to open.
class _Content extends StatelessWidget {
  final String content;
  final bool expanded;
  final VoidCallback onToggle;

  const _Content({required this.content, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final style = context.styles.paragraph;

    return LayoutBuilder(
      builder: (context, constraints) {
        final overflows = _overflows(context, style, constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: style,
              maxLines: expanded ? null : ReviewCard.collapsedLines,
              overflow: expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows) ...[
              AppGap.vertical(AppSpacing.sm),
              GestureDetector(
                onTap: onToggle,
                child: Text(
                  expanded ? context.l10n.reviewsShowLess : context.l10n.reviewsReadMore,
                  style: context.styles.link,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Whether the closed form would cut the review off. Measured with the
  /// reader's own text scale, since a review that fits at one size need not at
  /// another.
  bool _overflows(BuildContext context, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: content, style: style),
      maxLines: ReviewCard.collapsedLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);

    final didExceed = painter.didExceedMaxLines;
    painter.dispose();

    return didExceed;
  }
}

/// The avatar, the credit, the date, and the score if there is one.
class _AuthorLine extends StatelessWidget {
  final ReviewEntity review;

  const _AuthorLine({required this.review});

  @override
  Widget build(BuildContext context) {
    final name = review.displayName.isEmpty ? context.l10n.reviewsUnknownAuthor : review.displayName;

    return Row(
      children: [
        _Avatar(path: review.avatarPath, name: name),
        AppGap.horizontal(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.styles.rowTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (review.createdAt case final createdAt?) ...[
                AppGap.vertical(AppSpacing.xs),
                Text(_date(createdAt), style: context.styles.meta),
              ],
            ],
          ),
        ),
        if (review.rating case final rating?) ...[
          AppGap.horizontal(AppSpacing.sm),
          _RatingTag(rating: rating),
        ],
      ],
    );
  }

  /// TMDB sends an ISO 8601 timestamp; a review whose date does not parse
  /// loses the line rather than the card.
  String _date(String createdAt) {
    try {
      return createdAt.formattedTime;
    } on FormatException {
      return '';
    }
  }
}

class _Avatar extends StatelessWidget {
  final String? path;
  final String name;

  const _Avatar({required this.path, required this.name});

  @override
  Widget build(BuildContext context) {
    final size = 36.r;
    final palette = context.palette;

    if (path == null || path!.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: palette.surfaceMuted),
        child: Text(
          name.isEmpty ? '?' : name.characters.first.toUpperCase(),
          style: context.styles.rowTitle,
        ),
      );
    }

    return ClipOval(
      child: AppNetworkImage(
        url: path!.avatarImage,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheHeight: (size * 3).round(),
      ),
    );
  }
}

/// The author's own score, next to their name. Reads as a tag rather than as
/// the title's rating, which is the star on the header above it.
class _RatingTag extends StatelessWidget {
  final double rating;

  const _RatingTag({required this.rating});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(borderRadius: AppRadius.xsAll, color: palette.tagAccentBackground),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: AppSpacing.md, color: palette.onTagAccent),
          AppGap.horizontal(AppSpacing.xs),
          Text(rating.toStringAsFixed(1), style: context.styles.tag.copyWith(color: palette.onTagAccent)),
        ],
      ),
    );
  }
}
