import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/cubit/theme_cubit.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/enums/device_theme.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../injection_container.dart';
import '../cubit/account_cubit.dart';
import '../cubit/settings_cubit.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // `AccountCubit` is provided by `WrapperPage`, which is the tab shell —
    // and this screen is pushed at the root, over that shell rather than
    // inside it, so the wrapper's copy is not above this page and cannot be
    // read from here. It gets its own instead; the profile is three fields
    // off the signed-in user, so a second read costs nothing.
    //
    // `ThemeCubit` needs no provider here at all: `main.dart` puts it above
    // `MaterialApp.router`, so every routed page is already under it.
    return BlocProvider(
      create: (context) => AccountCubit(getIt()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  children: [
                    _Section(
                      label: context.l10n.settingsAppearance,
                      children: const [_ThemeSelector()],
                    ),
                    AppGap.vertical(AppSpacing.xxl),
                    _Section(
                      label: context.l10n.accountTitle,
                      children: const [_EmailRow()],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxl),
                child: const _LogOutButton(),
              ),
            ],
          ),
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
          Text(context.l10n.settingsTitle, style: context.styles.screenTitle),
        ],
      ),
    );
  }
}

/// A labelled group of rows. The label is the quiet upper-case line the
/// system uses wherever a block needs naming.
class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: context.styles.sectionLabel),
        AppGap.vertical(AppSpacing.md),
        ...children,
      ],
    );
  }
}

/// The three themes as one segmented control.
///
/// A segmented control rather than a menu: there are three options, they are
/// mutually exclusive, and showing all three is how the user sees that
/// "System" is one of them.
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: palette.inputBorder),
          ),
          child: Row(
            children: [
              for (final (index, theme) in DeviceTheme.values.indexed) ...[
                if (index > 0) SizedBox(width: 1, child: ColoredBox(color: palette.inputBorder)),
                Expanded(
                  child: _ThemeOption(
                    theme: theme,
                    isSelected: state.deviceTheme == theme,
                    onTap: () => context.read<ThemeCubit>().changeTheme(theme),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final DeviceTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({required this.theme, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? palette.buttonBackground : null,
            border: isSelected ? Border.all(color: palette.buttonBorder) : null,
          ),
          child: Text(
            _label(context, theme),
            style: context.styles.footerPrompt.copyWith(
              color: isSelected ? palette.onButton : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  String _label(BuildContext context, DeviceTheme theme) => switch (theme) {
        DeviceTheme.light => context.l10n.themeLight,
        DeviceTheme.dark => context.l10n.themeDark,
        DeviceTheme.system => context.l10n.themeSystem,
      };
}

/// The address the user signed in with. Shown, not editable — changing it is
/// not something this app does.
class _EmailRow extends StatelessWidget {
  const _EmailRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final email = state is AccountLoaded ? state.email : null;
        if (email == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: AppDecorations(context.palette).panel,
          child: Row(
            children: [
              Expanded(child: Text(context.l10n.authEmail, style: context.textTheme.bodyMedium)),
              Text(email, style: context.styles.meta),
            ],
          ),
        );
      },
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(getIt()),
      // Navigating is a side effect, so it belongs in a listener — and it now
      // waits for the sign-out instead of racing it.
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => current is SettingsSignedOut,
        listener: (context, state) => context.router.replaceAll([const LoginRoute()]),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            // Signing out is not the primary thing to do on this screen, so it
            // takes the neutral outline rather than the accent one.
            return OutlinedButton(
              onPressed: state is SettingsSigningOut ? null : () => context.read<SettingsCubit>().logout(),
              child: Text(context.l10n.settingsLogOut),
            );
          },
        ),
      ),
    );
  }
}
