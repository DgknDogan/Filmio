import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/routes/app_router.gr.dart';
import '../../../core/extensions/brightness_extension.dart';
import '../../../injection_container.dart';
import '../../account/presentation/cubit/account_cubit.dart';
import '../../movie/presentation/bloc/movie_bloc.dart';
import '../../series/presentation/bloc/series_bloc.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MovieBloc(getIt(), getIt())..add(GetMovies()), lazy: false),
        BlocProvider(create: (context) => SeriesBloc(getIt(), getIt())..add(GetSeries()), lazy: false),
        BlocProvider(create: (context) => AccountCubit(), lazy: false),
      ],
      child: AutoTabsRouter.pageView(
        homeIndex: 0,
        routes: const [
          MovieRoute(),
          SeriesHomeRoute(),
          AccountRoute(),
        ],
        physics: NeverScrollableScrollPhysics(),
        builder: (context, child, animation) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Stack(
            children: [
              Scaffold(
                body: child,
                bottomNavigationBar: BottomNavigationBar(
                  iconSize: 26.r,
                  selectedFontSize: 18.sp,
                  unselectedFontSize: 16.sp,
                  currentIndex: tabsRouter.activeIndex,
                  enableFeedback: false,
                  onTap: (index) {
                    tabsRouter.setActiveIndex(index);
                  },
                  items: const [
                    BottomNavigationBarItem(label: 'Movies', icon: Icon(Icons.movie)),
                    BottomNavigationBarItem(label: 'Series', icon: Icon(Icons.tv)),
                    BottomNavigationBarItem(label: 'Account', icon: Icon(Icons.account_circle))
                  ],
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
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Image.asset(
            "assets/logo.png",
            height: 250.h,
            color: Theme.of(context).isLight ? Colors.black : Colors.white,
          ),
        ),
      ).animate(
        controller: _splashController,
        onComplete: (controller) {
          controller.dispose();
        },
        effects: [
          MoveEffect(
            begin: Offset(0, 0),
            end: Offset(0, -900),
            duration: 2500.ms,
            curve: Curves.easeInOutCubic,
            delay: 1500.ms,
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}
