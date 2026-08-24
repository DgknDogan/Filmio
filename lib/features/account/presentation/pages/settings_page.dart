import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/cubit/theme_cubit.dart';
import '../../../../core/cubit/session_cubit.dart';
import '../../../../core/custom/circle_icon_button.dart';
import '../../../../core/enums/device_theme.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../injection_container.dart';
import '../cubit/account_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/delete_account_sheet.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.select((SessionCubit cubit) => cubit.state.isGuest);

    // `AccountCubit` is provided by `WrapperPage`, which is the tab shell —
    // and this screen is pushed at the root, over that shell rather than
    // inside it, so the wrapper's copy is not above this page and cannot be
    // read from here. It gets its own instead; the profile is three fields
    // off the signed-in user, so a second read costs nothing.
    //
    // `SettingsCubit` sits at page level rather than inside the log-out button
    // because two things on this screen now end the session — signing out and
    // deleting the account — and both leave for the login page.
    //
    // `ThemeCubit` needs no provider here at all: `main.dart` puts it above
    // `MaterialApp.router`, so every routed page is already under it.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AccountCubit(getIt())),
        BlocProvider(create: (context) => SettingsCubit(getIt(), getIt())),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: _onSettingsState,
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
                      // A guest has no address to show and no account to
                      // delete, so both sections are absent rather than empty.
                      if (!isGuest) ...[
                        AppGap.vertical(AppSpacing.xxl),
                        _Section(
                          label: context.l10n.accountTitle,
                          children: const [_EmailRow()],
                        ),
                      ],
                      AppGap.vertical(AppSpacing.xxl),
                      _Section(
                        label: context.l10n.settingsAbout,
                        children: const [_PrivacyPolicyRow(), _SupportRow(), _TmdbAttribution()],
                      ),
                      if (!isGuest) ...[
                        AppGap.vertical(AppSpacing.xxl),
                        _Section(
                          label: context.l10n.settingsDangerZone,
                          children: const [_DeleteAccountButton()],
                        ),
                      ],
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
      ),
    );
  }

  /// Navigating and announcing are side effects, so they live in a listener.
  /// Signing out and deleting both end at the login page — the difference is
  /// that after a deletion there is no account to come back to.
  static void _onSettingsState(BuildContext context, SettingsState state) {
    switch (state) {
      case SettingsSignedOut() || SettingsAccountDeleted():
        // Signing out clears the guest flag too, so the app-level session has
        // to be re-read — but only once this screen is gone. Refreshing first
        // rebuilt it as a signed-in user's settings for the frame before the
        // replace landed: the account rows appeared and the button relabelled
        // itself, in front of somebody on their way out.
        final session = context.read<SessionCubit>();
        context.router.replaceAll([const LoginRoute()]).whenComplete(session.refresh);
      case SettingsDeleteFailed(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case _:
        break;
    }
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
            border: Border.all(color: palette.controlBorder),
          ),
          child: Row(
            children: [
              for (final (index, theme) in DeviceTheme.values.indexed) ...[
                if (index > 0) SizedBox(width: 1, child: ColoredBox(color: palette.controlBorder)),
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

/// The way to the privacy policy from inside the app, which is where App
/// Review guideline 5.1.1(i) requires it to be reachable.
class _PrivacyPolicyRow extends StatelessWidget {
  const _PrivacyPolicyRow();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => context.router.push(const PrivacyPolicyRoute()),
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: AppDecorations(palette).panel,
          child: Row(
            children: [
              Expanded(child: Text(context.l10n.settingsPrivacyPolicy, style: context.textTheme.bodyMedium)),
              Icon(Icons.chevron_right_rounded, size: AppSpacing.xl, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// How to reach a person about the app.
///
/// The address is printed rather than hidden behind the label: App Review
/// guideline 1.5 wants contact information reachable, and guideline 1.2 wants
/// it published for anything showing other people's writing. A row that only
/// opens a mail draft fails both on a device with no mail account.
class _SupportRow extends StatelessWidget {
  const _SupportRow();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _write(context),
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: AppDecorations(palette).panel,
          child: Row(
            children: [
              Expanded(child: Text(context.l10n.settingsSupport, style: context.textTheme.bodyMedium)),
              Text(context.l10n.privacyContactEmail, style: context.styles.meta),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _write(BuildContext context) async {
    final address = context.l10n.privacyContactEmail;
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.settingsSupportFailed(address);
    final draft = Uri(
      scheme: 'mailto',
      path: address,
      queryParameters: {'subject': context.l10n.settingsSupportSubject},
    );

    // A device with no mail account set up either refuses or throws, depending
    // on the platform; both mean the same thing to the reader.
    var opened = false;
    try {
      opened = await launchUrl(draft);
    } on PlatformException {
      opened = false;
    }
    if (opened) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The credit TMDB's API terms require: every app that calls the API has to
/// say, in the app, that TMDB neither endorses nor certifies it. Without this
/// the app is using a third-party service outside its terms of use, which is
/// its own App Review problem (guideline 5.2.2) on top of TMDB's.
class _TmdbAttribution extends StatelessWidget {
  const _TmdbAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: AppDecorations(context.palette).panel,
      child: Text(context.l10n.settingsTmdbAttribution, style: context.styles.paragraph),
    );
  }
}

/// Deleting the account, which guideline 5.1.1(v) requires any app that lets
/// people create one to offer from inside it.
///
/// Two steps on purpose: the dialog states what is about to be lost, and the
/// password proves it is the account holder asking. Firebase also refuses to
/// delete a user on a stale sign-in, so the password is needed either way.
class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDeleting = state is SettingsDeletingAccount;

        return OutlinedButton(
          // A destructive variant, not a restatement of the theme's outline
          // button: the danger colour is what marks this apart from Log out.
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.danger,
            side: BorderSide(color: palette.danger),
          ),
          onPressed: isDeleting ? null : () => _confirm(context),
          child: Text(context.l10n.settingsDeleteAccount),
        );
      },
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final password = await showDeleteAccountSheet(context);

    if (password == null || password.isEmpty) return;
    await cubit.deleteAccount(password);
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    final isGuest = context.select((SessionCubit cubit) => cubit.state.isGuest);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        // Signing out is not the primary thing to do on this screen, so it
        // takes the neutral outline rather than the accent one. For a guest
        // the same button is the way in rather than the way out: there is no
        // session to end, only one to start.
        return OutlinedButton(
          onPressed: state is SettingsSigningOut ? null : () => context.read<SettingsCubit>().logout(),
          child: Text(isGuest ? context.l10n.settingsLeaveGuest : context.l10n.settingsLogOut),
        );
      },
    );
  }
}
