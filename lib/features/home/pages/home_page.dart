import 'package:auto_route/auto_route.dart';
import 'package:filmio/features/film/cubit/film_home_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../routes/app_router.gr.dart';
import '../../account/cubit/account_cubit.dart';
import '../../series/cubit/series_home_page_cubit.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  final FilmHomePageCubit filmHomePageCubit;
  final SeriesHomePageCubit seriesHomePageCubit;
  final AccountCubit accountCubit;

  const HomePage({
    super.key,
    required this.filmHomePageCubit,
    required this.seriesHomePageCubit,
    required this.accountCubit,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.filmHomePageCubit),
        BlocProvider.value(value: widget.seriesHomePageCubit),
        BlocProvider.value(value: widget.accountCubit),
      ],
      child: AutoTabsRouter(
        homeIndex: 0,
        routes: [
          FilmHomeRoute(),
          SeriesHomeRoute(),
          AccountRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              elevation: 0,
              unselectedItemColor: Color(0xff283618),
              selectedItemColor: Colors.white,
              backgroundColor: Color(0xff606c38),
              iconSize: 26.r,
              selectedFontSize: 18.sp,
              unselectedFontSize: 16.sp,
              currentIndex: tabsRouter.activeIndex,
              onTap: (index) {
                tabsRouter.setActiveIndex(index);
              },
              items: [
                BottomNavigationBarItem(label: 'Movies', icon: Icon(Icons.movie)),
                BottomNavigationBarItem(label: 'Series', icon: Icon(Icons.tv)),
                BottomNavigationBarItem(label: 'Account', icon: Icon(Icons.account_circle))
              ],
            ),
          );
        },
      ),
    );
  }
}
