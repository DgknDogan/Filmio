import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../extensions/context_extension.dart';

/// One word of category, as a chip.
///
/// [isPrimary] takes the accent pair and the rest the neutral one. Wherever
/// several of these sit together the first one is usually the primary, which
/// is a way of saying which of them actually describes the thing.
class AppTag extends StatelessWidget {
  final String name;
  final bool isPrimary;

  const AppTag({super.key, required this.name, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xsAll,
        color: isPrimary ? palette.tagAccentBackground : palette.tagNeutralBackground,
      ),
      child: Text(
        name,
        style: context.styles.tag.copyWith(color: isPrimary ? palette.onTagAccent : palette.onTagNeutral),
      ),
    );
  }
}
