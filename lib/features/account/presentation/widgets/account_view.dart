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
import '../../../../core/custom/poster_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_lists_cubit.dart';
import 'taste_profile_card.dart';

/// Everything the account tab draws.
///
/// Separate from the page so it can be rendered without a router above it: the
/// page is a `RouterScope` descendant because it listens for its tab coming
/// back to the front, and nothing here needs that.
class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The bloom of accent is the page's ground rather than a block inside
      // the scroll view, so it stays where it is while everything scrolls over
      // it. A gradient that scrolled with the content read as a second layer
      // moving over the background rather than as the background itself.
      body: DecoratedBox(
        decoration: AppDecorations(context.palette).accountHero,
        child: SafeArea(
          bottom: false,
          // One scroll for the whole tab, identity included.
          child: ListView(
            padding: AppInsets.tabBody,
            children: [
              const _Identity(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                // A guest has no lists to open — the rows would lead to two
                // empty screens and no explanation. What goes there instead is
                // the reason they are empty.
                child: BlocSelector<SessionCubit, SessionState, bool>(
                  selector: (state) => state.isGuest,
                  builder: (context, isGuest) => isGuest ? const _GuestInvitation() : const _Lists(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the account holds: the profile its lists add up to, and the four rows
/// that open them.
///
/// The liked pair first, because that is the list the recommendations are
/// built from and the one the heart on every details screen fills. The
/// watchlist pair reads as the answer to a different question — not what you
/// thought of something, but what you have not got to yet — so it sits under
/// them rather than interleaved by catalogue.
class _Lists extends StatelessWidget {
  const _Lists();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountListsCubit, AccountListsState>(
      builder: (context, state) {
        final loaded = state is AccountListsLoaded ? state : null;

        return Column(
          children: [
            // Absent until the lists are read, and absent again if a read did
            // not come back: a profile built on half the lists would describe
            // somebody else, and the rows below still work without it.
            if (loaded != null) ...[
              TasteProfileCard(profile: loaded.profile),
              AppGap.vertical(AppSpacing.lg),
            ],
            _AccountRow(
              icon: Icons.favorite_border_rounded,
              label: context.l10n.likedMovies,
              posterPaths: loaded?.likedMovies.map((movie) => movie.posterPath).toList(),
              onTap: () => context.router.push(const LikedMoviesRoute()),
            ),
            AppGap.vertical(AppSpacing.md),
            _AccountRow(
              icon: Icons.tv_outlined,
              label: context.l10n.likedSeries,
              posterPaths: loaded?.likedSeries.map((series) => series.posterPath).toList(),
              onTap: () => context.router.push(const LikedSeriesRoute()),
            ),
            AppGap.vertical(AppSpacing.md),
            _AccountRow(
              icon: Icons.bookmark_border_rounded,
              label: context.l10n.watchlistMovies,
              posterPaths: loaded?.watchlistMovies.map((movie) => movie.posterPath).toList(),
              onTap: () => context.router.push(const WatchlistMoviesRoute()),
            ),
            AppGap.vertical(AppSpacing.md),
            _AccountRow(
              icon: Icons.bookmark_added_outlined,
              label: context.l10n.watchlistSeries,
              posterPaths: loaded?.watchlistSeries.map((series) => series.posterPath).toList(),
              onTap: () => context.router.push(const WatchlistSeriesRoute()),
            ),
          ],
        );
      },
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

/// Who is signed in. The brand colour behind it belongs to the page, so this
/// is only the row of who you are — and it scrolls away with everything else.
class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    return Padding(
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

/// One way out of this screen: an icon, what it opens, and a few of its
/// covers.
class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;

  /// The list's titles in order, or null until it has been read. The covers
  /// are what makes a row of these read as content rather than as a menu.
  final List<String?>? posterPaths;

  /// Returns the pushed screen's future, so the row knows when it has been
  /// closed and the lists are worth reading again.
  final Future<void> Function() onTap;

  /// How many covers fit beside the label without crowding it.
  static const _previewCount = 3;

  const _AccountRow({required this.icon, required this.label, required this.posterPaths, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      // The list may be changed on the screen this opens — a like taken back,
      // a title off the watchlist — so the covers and the profile are read
      // again once it closes.
      onTap: () async {
        final cubit = context.read<AccountListsCubit>();
        await onTap();
        await cubit.load();
      },
      borderRadius: AppRadius.smAll,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: AppDecorations(palette).panel,
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.xl, color: palette.accentSoft),
            AppGap.horizontal(AppSpacing.lg),
            Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
            if (posterPaths != null && posterPaths!.isNotEmpty) ...[
              AppGap.horizontal(AppSpacing.md),
              _Covers(posterPaths: posterPaths!, limit: _previewCount),
            ],
            AppGap.horizontal(AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, size: AppSpacing.xl, color: palette.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// The first few covers of a list, at a size that says what is in it without
/// competing with the row's own label.
class _Covers extends StatelessWidget {
  final List<String?> posterPaths;
  final int limit;

  const _Covers({required this.posterPaths, required this.limit});

  @override
  Widget build(BuildContext context) {
    final shown = posterPaths.nonNulls.take(limit).toList();
    if (shown.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, path) in shown.indexed) ...[
          if (index > 0) AppGap.horizontal(AppSpacing.xs),
          SizedBox(
            width: 24.w,
            // A preview this size has no business decoding a full poster.
            child: PosterCard(imageUrl: path.coverImage, title: '', memCacheHeight: 120),
          ),
        ],
      ],
    );
  }
}
