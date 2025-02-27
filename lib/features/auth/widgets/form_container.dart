import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormContainer extends StatelessWidget {
  final Widget child;
  const FormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff2a2a2a),
        borderRadius: BorderRadius.all(
          Radius.circular(20.r),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.w).add(EdgeInsets.only(top: 100.h)),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: child,
    );
  }
}
