import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchbar extends StatelessWidget {
  final bool isEnabled;
  final String hintText;
  final FocusNode? focusNode;
  final double? height;
  final double? width;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  const CustomSearchbar({
    super.key,
    required this.isEnabled,
    this.focusNode,
    required this.hintText,
    this.height,
    this.width,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        onTapOutside: (event) {
          focusNode!.unfocus();
        },
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        enabled: isEnabled,
        cursorColor: Colors.black,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 26.r,
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
