import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/custom/custom_searchbar.dart';

@RoutePage()
class SeriesSearchPage extends StatefulWidget {
  final String heroTag;
  final String hintText;

  const SeriesSearchPage({super.key, required this.heroTag, required this.hintText});

  @override
  State<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends State<SeriesSearchPage> {
  final _focus = FocusNode();
  @override
  void initState() {
    Future.delayed(
      250.milliseconds,
      () {
        _focus.requestFocus();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: EdgeInsets.only(right: 20.w),
        actions: [
          Row(
            children: [
              SizedBox(
                width: 260.w,
                child: Hero(
                  tag: widget.heroTag,
                  child: CustomSearchbar(
                    isEnabled: true,
                    focusNode: _focus,
                    hintText: widget.hintText,
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              GestureDetector(
                onTap: () => context.router.maybePop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
