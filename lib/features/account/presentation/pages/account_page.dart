import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/extensions/context_extension.dart';
import '../cubit/account_cubit.dart';

@RoutePage()
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: AppInsets.tabBody,
        children: [
          const _Identity(),
          AppGap.vertical(AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                _AccountRow(
                  icon: Icons.favorite_border_rounded,
                  label: context.l10n.likedMovies,
                  onTap: () => context.router.push(const LikedMoviesRoute()),
                ),
                AppGap.vertical(AppSpacing.md),
                _AccountRow(
                  icon: Icons.tv_outlined,
                  label: context.l10n.likedSeries,
                  onTap: () => context.router.push(const LikedSeriesRoute()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Who is signed in, over a bloom of accent anchored off the top-left corner
/// — the one place on this screen the brand colour appears at any size.
class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations(context.palette).accountHero,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.accountTitle.toUpperCase(), style: context.styles.sectionLabel),
                  CircleIconButton(
                    icon: Icons.settings_outlined,
                    label: context.l10n.settingsTitle,
                    isFilled: false,
                    iconColor: context.palette.textSecondary,
                    onPressed: () => context.router.push(const SettingsRoute()),
                  ),
                ],
              ),
              AppGap.vertical(AppSpacing.lg),
              const _Profile(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final loaded = state is AccountLoaded ? state : null;

        return Row(
          children: [
            Container(
              height: 70.r,
              width: 70.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.tagNeutralBackground,
                border: Border.all(color: palette.inputBorder),
                image: loaded?.photoUrl == null ? null : DecorationImage(image: AssetImage(loaded!.photoUrl!), fit: BoxFit.cover),
              ),
              child: loaded?.photoUrl != null ? null : Icon(Icons.person_outline_rounded, color: palette.textSecondary, size: AppSpacing.xxxl),
            ),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loaded?.name case final name?) Text(name, style: context.styles.screenTitle),
                  if (loaded?.email case final email?) ...[
                    AppGap.vertical(AppSpacing.xs),
                    Text(email, style: context.styles.meta),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One way out of this screen: an icon, what it opens, and a chevron.
class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccountRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: AppDecorations(palette).panel,
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.xl, color: palette.accentSoft),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
            Icon(Icons.chevron_right_rounded, size: AppSpacing.xl, color: palette.inputBorder),
          ],
        ),
      ),
    );
  }
}
