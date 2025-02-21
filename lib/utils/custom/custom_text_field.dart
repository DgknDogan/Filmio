import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String text;
  final bool isObsecure;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool hasError;
  final String? Function(String?)? validator;
  const CustomTextField({
    super.key,
    required this.text,
    required this.isObsecure,
    required this.controller,
    required this.hasError,
    this.onChanged,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: !hasError ? Colors.white : Colors.red.shade600,
            width: 2.5.w,
          ),
          right: BorderSide(
            color: !hasError ? Colors.white : Colors.red.shade600,
            width: 2.5.w,
          ),
        ),
      ),
      duration: 500.ms,
      child: TextFormField(
        buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
          return null;
        },
        validator: validator,
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
