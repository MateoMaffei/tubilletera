import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int? maxLines;
  final bool obscureText;
  final bool enable;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.obscureText = false,
    this.inputFormatters,
    this.enable = true,
  });

  static InputDecoration decoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enable,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: decoration(label: label, icon: prefixIcon),
      inputFormatters: inputFormatters
    );
  }
}
