import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchbar extends StatelessWidget {
  final bool isEnabled;
  final String hintText;
  final FocusNode? focusNode;
  final double? height;
  final double? width;
  final void Function(String)? onChanged;
  const CustomSearchbar({
    super.key,
    required this.isEnabled,
    this.focusNode,
    required this.hintText,
    this.height,
    this.width,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50.h,
      width: width,
      child: TextField(
        onChanged: onChanged,
        focusNode: focusNode,
        enabled: isEnabled,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: isEnabled ? 26.r : 20.r,
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(15.r),
          ),
          hintText: hintText,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
