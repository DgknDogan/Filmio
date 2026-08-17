import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/extensions/context_extension.dart';
import 'filmio_mark.dart';

/// The brand at the top of an auth screen: the mark, the word mark, and a
/// bloom of accent behind them.
///
/// There is no banner — no fill, no edge, no clip. The colour is a wash that
/// starts just off the top of the screen and is gone before the form begins,
/// so the page is one continuous ground.
class AuthHero extends StatelessWidget {
  const AuthHero({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations(context.palette).authHero,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
          child: Column(
            children: [
              FilmioMark(size: 34.r),
              AppGap.vertical(AppSpacing.lg),
              // The tracking is added after the last letter too, which shifts
              // a centred word to the left by that much. The padding puts it
              // back, and takes its value from the style so the two cannot
              // drift apart.
              Padding(
                padding: EdgeInsets.only(left: context.styles.authBrand.letterSpacing ?? 0),
                child: Text(context.l10n.appName.toUpperCase(), style: context.styles.authBrand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
