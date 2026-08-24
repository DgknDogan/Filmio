import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/extensions/context_extension.dart';
import 'auth_hero.dart';

/// The shape both auth screens share: banner and headline at the top, fields
/// under them, and the actions parked at the bottom of the viewport.
///
/// The page does not resize for the keyboard: the actions stay where they
/// were and the keyboard slides over them, rather than the button jumping up
/// the screen every time a field is tapped. The content still scrolls, so a
/// screen too short for the banner and the form is not an overflow the way the
/// old fixed `Column` was.
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;

  /// The fields.
  final Widget form;

  /// The primary action, pinned to the bottom above [footer].
  final Widget submitButton;

  /// The link to the other auth screen.
  final Widget footer;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.submitButton,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // The viewport keeps its full height while the keyboard is up, which
          // is what holds the actions still instead of lifting them.
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHero(),
                    Padding(
                      padding: AppInsets.authBody,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: context.styles.authTitle),
                          AppGap.vertical(AppSpacing.xs),
                          Text(subtitle, style: context.styles.authSubtitle),
                          AppGap.vertical(AppSpacing.xl),
                          form,
                        ],
                      ),
                    ),
                    // Takes the slack on a tall screen and gives it back on a
                    // short one, which is what holds the actions at the
                    // bottom without stranding them off screen.
                    const Spacer(),
                    SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          Padding(padding: AppInsets.authHorizontal, child: submitButton),
                          AppGap.vertical(AppSpacing.lg),
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.lg),
                            child: footer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
