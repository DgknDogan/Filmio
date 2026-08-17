import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

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

  const MetaLine({super.key, this.rating, required this.parts, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = onImage ? context.styles.metaOnImage : context.styles.meta;
    final present = parts.nonNulls.where((part) => part.isNotEmpty).toList();

    return Row(
      children: [
        if (rating != null) ...[
          Icon(Icons.star_rounded, size: AppSpacing.lg, color: palette.accentSoft),
          AppGap.horizontal(AppSpacing.xs),
          Text(rating!.toStringAsFixed(1), style: style),
          if (present.isNotEmpty) _Separator(style: style),
        ],
        for (final (index, part) in present.indexed) ...[
          if (index > 0) _Separator(style: style),
          Flexible(child: Text(part, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
      child: Text('·', style: style.copyWith(color: context.palette.inputBorder)),
    );
  }
}
