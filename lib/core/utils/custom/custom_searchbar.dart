import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchbar extends StatelessWidget {
  final bool isEnabled;
  final String hintText;
  final FocusNode? focusNode;
  const CustomSearchbar({super.key, required this.isEnabled, this.focusNode, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
