import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../extensions/brightness_extension.dart';

class CustomSliverAppBar extends StatelessWidget {
  final List<Widget> actions;
  final Widget title;
  const CustomSliverAppBar({
    super.key,
    required this.actions,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).isLight ? Color(0xff6a5acd) : Colors.black,
      actionsPadding: EdgeInsets.zero,
      centerTitle: false,
      toolbarHeight: 70.h,
      floating: true,
      automaticallyImplyLeading: false,
      leadingWidth: 0.w,
      actions: actions,
      title: Container(margin: EdgeInsets.only(left: 10.w), child: title),
      titleTextStyle: Theme.of(context).textTheme.headlineLarge,
    );
  }
}
