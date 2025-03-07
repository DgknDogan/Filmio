import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_text_field.dart';

class CustomForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const CustomForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          CustomTextField(
            hasError: false,
            text: "Email",
            isObsecure: false,
            controller: emailController,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            hasError: false,
            text: "Password",
            isObsecure: true,
            controller: passwordController,
          ),
        ],
      ),
    );
  }
}
