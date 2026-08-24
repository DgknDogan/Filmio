import 'package:flutter/material.dart';

import '../../../../core/custom/app_sheet.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/review_report.dart';

/// Asks what is wrong with a review, and returns the answer.
///
/// A fixed list, one tap: picking a reason files the report. An extra "send"
/// button would only add a step to something nobody wants to spend time on,
/// and the reasons are short enough to read at a glance.
Future<ReportReason?> showReportReviewSheet(BuildContext context) {
  return AppSheet.showActions<ReportReason>(
    context,
    title: context.l10n.reportTitle,
    message: context.l10n.reportBody,
    actions: [
      for (final reason in ReportReason.values)
        AppSheetAction(
          value: reason,
          label: _label(context, reason),
          icon: _icon(reason),
        ),
    ],
  );
}

String _label(BuildContext context, ReportReason reason) => switch (reason) {
      ReportReason.offensiveLanguage => context.l10n.reportReasonOffensiveLanguage,
      ReportReason.hateOrHarassment => context.l10n.reportReasonHateOrHarassment,
      ReportReason.spam => context.l10n.reportReasonSpam,
      ReportReason.spoiler => context.l10n.reportReasonSpoiler,
      ReportReason.other => context.l10n.reportReasonOther,
    };

IconData _icon(ReportReason reason) => switch (reason) {
      ReportReason.offensiveLanguage => Icons.report_gmailerrorred_outlined,
      ReportReason.hateOrHarassment => Icons.gpp_maybe_outlined,
      ReportReason.spam => Icons.block_outlined,
      ReportReason.spoiler => Icons.visibility_off_outlined,
      ReportReason.other => Icons.more_horiz_rounded,
    };
