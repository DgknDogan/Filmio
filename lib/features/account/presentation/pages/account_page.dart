import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/cubit/session_cubit.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/custom/custom_button.dart';
import '../../../../core/custom/guest_prompt.dart';
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
            // A guest has no lists to open — the rows would lead to two empty
            // screens and no explanation. What goes there instead is the
            // reason they are empty.
            child: BlocSelector<SessionCubit, SessionState, bool>(
              selector: (state) => state.isGuest,
              builder: (context, isGuest) => isGuest ? const _GuestInvitation() : const _Lists(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The two lists an account keeps.
class _Lists extends StatelessWidget {
  const _Lists();

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

/// What a guest gets in place of their lists: what an account would add, and
/// one way to get one.
class _GuestInvitation extends StatelessWidget {
  const _GuestInvitation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations(context.palette).panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.guestAccountPrompt, style: context.styles.paragraph),
          AppGap.vertical(AppSpacing.lg),
          CustomButton(
            text: context.l10n.guestCreateAccount,
            onPressed: () => showGuestPrompt(
              context,
              title: context.l10n.guestCreateAccount,
              body: context.l10n.guestAccountPrompt,
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

  /// The initial of the word standing in for a name, where a picture would be.
  static Widget? _avatarMark(BuildContext context, {required bool isGuest, required String? photoUrl}) {
    if (isGuest) {
      return Text(
        context.l10n.guestName.characters.first.toUpperCase(),
        style: context.styles.screenTitle.copyWith(color: context.palette.textSecondary),
      );
    }

    if (photoUrl != null) return null;

    return Icon(Icons.person_outline_rounded, color: context.palette.textSecondary, size: AppSpacing.xxxl);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final isGuest = context.select((SessionCubit cubit) => cubit.state.isGuest);

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final loaded = state is AccountLoaded ? state : null;
        final name = isGuest ? context.l10n.guestName : loaded?.name;

        return Row(
          children: [
            Container(
              height: 70.r,
              width: 70.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.tagNeutralBackground,
                border: Border.all(color: palette.inputBorder),
                image: isGuest || loaded?.photoUrl == null ? null : DecorationImage(image: AssetImage(loaded!.photoUrl!), fit: BoxFit.cover),
              ),
              child: _avatarMark(context, isGuest: isGuest, photoUrl: loaded?.photoUrl),
            ),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name case final name?) Text(name, style: context.styles.screenTitle),
                  // A guest has no address to print, and an empty line where
                  // one usually is reads as something that failed to load.
                  if (!isGuest && loaded?.email != null) ...[
                    AppGap.vertical(AppSpacing.xs),
                    Text(loaded!.email!, style: context.styles.meta),
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
            Icon(Icons.chevron_right_rounded, size: AppSpacing.xl, color: palette.textSecondary),
          ],
        ),
      ),
    );
  }
}
