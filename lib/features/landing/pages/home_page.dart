import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/routes/app_router.gr.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _splashController;
  @override
  void initState() {
    _splashController = AnimationController(vsync: this, duration: 2000.ms);
    super.initState();
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.pageView(
      homeIndex: 0,
      routes: [
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
                onTap: (index) {
                  tabsRouter.setActiveIndex(index);
                },
                items: [
                  BottomNavigationBarItem(label: 'Movies', icon: Icon(Icons.movie)),
                  BottomNavigationBarItem(label: 'Series', icon: Icon(Icons.tv)),
                  BottomNavigationBarItem(label: 'Account', icon: Icon(Icons.account_circle))
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff3A3A3A),
              ),
              child: Center(
                child: Image.asset(
                  "assets/logo.png",
                  height: 250.h,
                  color: Colors.white,
                ),
              ),
            ).animate(
              controller: _splashController,
              effects: [
                MoveEffect(
                  begin: Offset(0, 0),
                  end: Offset(0, -1000),
                  duration: 2000.ms,
                  curve: Curves.easeInOutCubic,
                  delay: 1000.ms,
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
