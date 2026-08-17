import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';

/// The heading over a row of posters: a name on the left, and on the right
/// the way out of the row.
///
/// The two sit on a shared baseline rather than centred against each other,
/// which is what keeps a 15px title and an 11px link reading as one line.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(title, style: context.styles.sectionTitle, overflow: TextOverflow.ellipsis)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!.toUpperCase(), style: context.styles.sectionAction),
          ),
      ],
    );
  }
}

/// The heading of a block inside a details sheet — "SYNOPSIS", "CAST".
///
/// Quieter than [SectionHeader], and never carries an action: it labels a
/// paragraph rather than heading a row you can scroll out of.
class SheetSectionLabel extends StatelessWidget {
  final String label;

  const SheetSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: context.styles.sectionLabel);
  }
}
