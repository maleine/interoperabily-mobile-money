import 'package:flutter/material.dart';
import 'package:interoperabilite/widgets/app_TextStyle.dart';
import 'package:interoperabilite/widgets/colors.dart';

class TextFieldForm extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final bool isObscure;
  const TextFieldForm({
    super.key,
    required this.controller,
    this.labelText,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: appTextStyle(ColorTheme.blackColor, FontWeight.bold, 16),
      ),
    );
  }
}
