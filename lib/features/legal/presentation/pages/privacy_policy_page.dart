import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/extensions/context_extension.dart';

/// The privacy policy, in the app.
///
/// App Review guideline 5.1.1(i) wants the policy reachable from inside the
/// app and not only from the store listing, so it is a screen rather than a
/// link out: it works with no network, needs no browser, and cannot rot the
/// way a URL can. The same text is published at `docs/privacy-policy.html`
/// for the App Store Connect metadata field, which does need a public URL.
@RoutePage()
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                children: [
                  Text(context.l10n.privacyUpdated, style: context.styles.meta),
                  AppGap.vertical(AppSpacing.lg),
                  Text(context.l10n.privacyIntro, style: context.styles.paragraph),
                  _Clause(title: context.l10n.privacyCollectTitle, body: context.l10n.privacyCollectBody),
                  _Clause(title: context.l10n.privacyUseTitle, body: context.l10n.privacyUseBody),
                  _Clause(title: context.l10n.privacyShareTitle, body: context.l10n.privacyShareBody),
                  _Clause(title: context.l10n.privacyKeepTitle, body: context.l10n.privacyKeepBody),
                  _Clause(title: context.l10n.privacyRightsTitle, body: context.l10n.privacyRightsBody),
                  _Clause(title: context.l10n.privacyChildrenTitle, body: context.l10n.privacyChildrenBody),
                  _Clause(title: context.l10n.privacyChangesTitle, body: context.l10n.privacyChangesBody),
                  _Clause(title: context.l10n.privacyContactTitle, body: context.l10n.privacyContactBody),
                  AppGap.vertical(AppSpacing.xs),
                  // Selectable because it is the one line on this screen
                  // someone actually needs to copy.
                  SelectableText(context.l10n.privacyContactEmail, style: context.styles.link),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xxl, AppSpacing.xl),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            label: context.l10n.backAction,
            isFilled: false,
            onPressed: () => context.router.maybePop(),
          ),
          AppGap.horizontal(AppSpacing.md),
          Expanded(child: Text(context.l10n.privacyTitle, style: context.styles.screenTitle)),
        ],
      ),
    );
  }
}

/// One numbered-in-spirit section: what it is about, then what it says.
class _Clause extends StatelessWidget {
  final String title;
  final String body;

  const _Clause({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.styles.sectionTitle),
          AppGap.vertical(AppSpacing.sm),
          Text(body, style: context.styles.paragraph),
        ],
      ),
    );
  }
}
