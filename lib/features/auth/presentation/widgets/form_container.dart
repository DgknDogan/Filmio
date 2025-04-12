import 'package:flutter/material.dart';

class FormContainer extends StatelessWidget {
  final Widget child;
  const FormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
