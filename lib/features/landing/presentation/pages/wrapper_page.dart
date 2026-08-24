import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/app_decorations.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../injection_container.dart';
import '../../../account/presentation/cubit/account_cubit.dart';
import '../../../movie/presentation/bloc/movie_bloc.dart';
import '../../../series/presentation/bloc/series_bloc.dart';
import '../../../../gen/assets.gen.dart';

@RoutePage()
class WrapperPage extends StatelessWidget {
  const WrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MovieBloc(getIt(), getIt(), getIt(), getIt())..add(GetMovies()), lazy: false),
        BlocProvider(create: (context) => SeriesBloc(getIt(), getIt(), getIt(), getIt())..add(GetSeries()), lazy: false),
        BlocProvider(create: (context) => AccountCubit(getIt()), lazy: false),
      ],
      child: AutoTabsRouter.pageView(
        homeIndex: 0,
        routes: const [
          MovieRoute(),
          SeriesHomeRoute(),
          AccountRoute(),
        ],
        physics: const NeverScrollableScrollPhysics(),
        builder: (context, child, animation) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Stack(
            children: [
              Scaffold(
                // The tab pages run their artwork to the top of the screen,
                // so the bar floats over the content rather than reserving a
                // strip under it.
                extendBody: true,
                body: child,
                bottomNavigationBar: _NavBar(
                  activeIndex: tabsRouter.activeIndex,
                  onSelected: tabsRouter.setActiveIndex,
                ),
              ),
              const _SplashAnimation()
            ],
          );
        },
      ),
    );
  }
}

/// The tab bar.
///
/// Written out rather than themed from `BottomNavigationBar`, because the
/// design's bar is a row of three stacked icon-and-label pairs with its own
/// spacing and a hairline top edge — none of which that widget exposes.
class _NavBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int index) onSelected;

  const _NavBar({required this.activeIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations(context.palette).navBar,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Row(
            children: [
              _NavItem(
                // Keyed so an integration test can reach a tab without going
                // through its label, which is localised.
                key: const Key('moviesTab'),
                icon: Icons.movie_outlined,
                label: context.l10n.moviesTitle,
                isActive: activeIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavItem(
                key: const Key('seriesTab'),
                icon: Icons.tv_outlined,
                label: context.l10n.seriesTitle,
                isActive: activeIndex == 1,
                onTap: () => onSelected(1),
              ),
              _NavItem(
                key: const Key('accountTab'),
                icon: Icons.person_outline_rounded,
                label: context.l10n.accountTitle,
                isActive: activeIndex == 2,
                onTap: () => onSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({super.key, required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colour = isActive ? palette.accent : palette.textSecondary;

    return Expanded(
      child: Semantics(
        selected: isActive,
        button: true,
        child: InkResponse(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24.r, color: colour),
                // AppGap.vertical(AppSpacing.sm),
                Text(label, style: context.styles.navLabel.copyWith(color: colour)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashAnimation extends StatefulWidget {
  const _SplashAnimation();

  @override
  State<_SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<_SplashAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _splashController;
  @override
  void initState() {
    _splashController = AnimationController(vsync: this, duration: 2000.ms);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashController.isAnimating) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.palette.surface,
        ),
        child: Center(
          child: Assets.logo.image(
            height: 250.h,
            color: context.palette.textPrimary,
          ),
        ),
      ).animate(
        controller: _splashController,
        onComplete: (controller) {
          controller.dispose();
        },
        effects: [
          MoveEffect(
            begin: const Offset(0, 0),
            end: const Offset(0, -900),
            duration: 2500.ms,
            curve: Curves.easeInOutCubic,
            delay: 1500.ms,
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
