import 'package:flutter/material.dart';

class CustomPasswordTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool? obscureText;
  final String hintText;
  final Widget suffixIcon;
  final String? errorText;
  final Function(String) onChanged;

  const CustomPasswordTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText,
    required this.hintText,
    required this.suffixIcon,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Color(0xFF636363),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.grey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            suffixIcon: suffixIcon,
            errorText: errorText?.isEmpty ?? true ? null : errorText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
