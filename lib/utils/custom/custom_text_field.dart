import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String text;
  final bool isObsecure;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final int? maxLength;
  const CustomTextField({super.key, required this.text, required this.isObsecure, required this.controller, this.onChanged, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2.5.w,
          ),
          right: BorderSide(
            color: Colors.black,
            width: 2.5.w,
          ),
        ),
      ),
      child: TextFormField(
        buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
          return null;
        },
        maxLength: maxLength,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
        ),
        obscureText: isObsecure,
        cursorColor: Color(0xfffefae0),
        style: TextStyle(
          color: Color(0xfffefae0),
        ),
      ),
    );
  }
}
