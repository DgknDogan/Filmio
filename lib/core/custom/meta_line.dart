import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';
import 'numeric_transition_text.dart';

/// The one line of facts under a title: a rating behind its star, then the
/// year, the genre, whatever else the entity carries — separated by a dot in
/// a colour quiet enough that the dots do not read as content.
class MetaLine extends StatelessWidget {
  final double? rating;

  /// Already-formatted fragments. Empty ones are dropped, so a missing year
  /// does not leave a stranded separator.
  final List<String?> parts;

  /// True where the line is drawn over artwork rather than over the page.
  final bool onImage;

  /// True where the line is one of several the same spot takes turns showing,
  /// so a new rating or genre rolls into place a character at a time rather
  /// than swapping in at once.
  final bool rollChanges;

  const MetaLine({super.key, this.rating, required this.parts, this.onImage = false, this.rollChanges = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = onImage ? context.styles.metaOnImage : context.styles.meta;
    final present = parts.nonNulls.where((part) => part.isNotEmpty).toList();

    Widget fragment(String value, {int? maxLines}) => rollChanges
        ? NumericTransitionText(value, style: style, maxLines: maxLines, overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis)
        : Text(value, style: style, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis);

    return Row(
      children: [
        if (rating != null) ...[
          Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
          AppGap.horizontal(AppSpacing.xs),
          fragment(rating!.toStringAsFixed(1)),
          if (present.isNotEmpty) _Separator(style: style),
        ],
        for (final (index, part) in present.indexed) ...[
          if (index > 0) _Separator(style: style),
          Flexible(child: fragment(part, maxLines: 1)),
        ],
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  final TextStyle style;

  const _Separator({required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      // Quiet, but quiet relative to the line it punctuates: [inputBorder] is
      // a hairline meant for a drawn edge, and on a light page it left the dot
      // at 1.2:1 — which is not a separator, it is a missing one.
      child: Text('·', style: style.copyWith(color: (style.color ?? context.palette.textSecondary).withValues(alpha: 0.55))),
    );
  }
}
