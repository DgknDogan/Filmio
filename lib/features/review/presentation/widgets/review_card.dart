import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/app_network_image.dart';
import '../../../../core/custom/app_sheet.dart';
import '../../../../core/enums/media_type.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_report.dart';
import '../cubit/review_moderation_cubit.dart';
import 'report_review_sheet.dart';

/// One review: who wrote it, what they scored it, and what they said.
///
/// Reviews run long — TMDB has no length limit — so the text is cut off after
/// a few lines and opens on a tap. Whether this one is open is not screen
/// state: nothing outside the card acts on it, and it dies with the card. The
/// same goes for whether a flagged review has been opened past its warning.
///
/// The menu is the reader's way out of a review they should not have to read:
/// report it, or stop seeing that author altogether. Both are what App Review
/// guideline 1.2 requires of an app that shows other people's writing.
class ReviewCard extends StatefulWidget {
  final ReviewEntity review;

  /// Which title the review is of. Carried so a report can say what was being
  /// reviewed without a second lookup.
  final int mediaId;
  final MediaType mediaType;

  /// How much of a closed review is shown.
  static const collapsedLines = 5;

  const ReviewCard({super.key, required this.review, required this.mediaId, required this.mediaType});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _expanded = false;

  /// A flagged review stays folded until the reader asks for it.
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final content = review.content ?? '';
    final isFolded = review.isObjectionable && !_revealed;

    return Container(
      decoration: AppDecorations(context.palette).panel,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorLine(
            review: review,
            onReport: _report,
            onBlock: _block,
          ),
          if (content.isNotEmpty) ...[
            AppGap.vertical(AppSpacing.md),
            if (isFolded)
              _FlaggedNotice(onReveal: () => setState(() => _revealed = true))
            else
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

  Future<void> _report() async {
    final review = widget.review;
    final id = review.id;
    if (id == null || id.isEmpty) return;

    final cubit = context.read<ReviewModerationCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final sent = context.l10n.reportSent;
    final failed = context.l10n.reportFailed;

    final reason = await showReportReviewSheet(context);
    if (reason == null) return;

    final filed = await cubit.report(
      ReviewReport(
        reviewId: id,
        author: review.displayName,
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        reason: reason,
        excerpt: review.content ?? '',
      ),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(filed ? sent : failed)));
  }

  Future<void> _block() async {
    final author = widget.review.displayName;
    if (author.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.reviewsAuthorBlocked(author);

    await context.read<ReviewModerationCubit>().blockAuthor(author);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// What stands in for a review the content filter flagged.
///
/// Folded rather than dropped: the filter is a word list and will be wrong
/// sometimes, so the reader keeps the choice. What they do not get is the
/// language arriving unannounced.
class _FlaggedNotice extends StatelessWidget {
  final VoidCallback onReveal;

  const _FlaggedNotice({required this.onReveal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.visibility_off_outlined, size: AppSpacing.xl, color: context.palette.textSecondary),
        AppGap.horizontal(AppSpacing.md),
        Expanded(child: Text(context.l10n.reviewsFlaggedWarning, style: context.styles.meta)),
        TextButton(onPressed: onReveal, child: Text(context.l10n.reviewsShowAnyway)),
      ],
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
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const _AuthorLine({required this.review, required this.onReport, required this.onBlock});

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
        _ModerationMenu(onReport: onReport, onBlock: onBlock),
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

/// The way to report a review or stop seeing its author.
///
/// A sheet rather than a `PopupMenuButton`: that draws a Material card wherever
/// it can find room, in Material's own colours and corners, and looks like a
/// different app every time it opens. Everything modal here arrives from the
/// bottom instead.
class _ModerationMenu extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const _ModerationMenu({required this.onReport, required this.onBlock});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _open(context),
      tooltip: context.l10n.reviewsMoreActions,
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.more_horiz_rounded, size: AppSpacing.xl, color: context.palette.textSecondary),
    );
  }

  Future<void> _open(BuildContext context) async {
    final action = await AppSheet.showActions<VoidCallback>(
      context,
      title: context.l10n.reviewsMoreActions,
      actions: [
        AppSheetAction(value: onReport, label: context.l10n.reviewsReport, icon: Icons.flag_outlined),
        AppSheetAction(value: onBlock, label: context.l10n.reviewsBlockAuthor, icon: Icons.person_off_outlined),
      ],
    );

    action?.call();
  }
}
