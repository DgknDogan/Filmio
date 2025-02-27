import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/routes/app_router.gr.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      homeIndex: 0,
      routes: [
        MovieRoute(),
        SeriesHomeRoute(),
        AccountRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
