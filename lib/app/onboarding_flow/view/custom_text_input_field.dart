import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';

class CustomTextInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomTextInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextField(
        controller: controller,
        style: globalTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ), // Replace with your global text style
        obscureText: obscureText,

        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: globalTextStyle(
            color: Color(0xFF9B9B9B),
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.transparent,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFF1B9117).withValues(alpha: 0.25),
            ), // 25% transparency
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFF1B9117).withValues(alpha: 0.25),
            ), // 25% transparency
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFF1B9117).withValues(alpha: 0.25),
            ), // 25% transparency
          ),

          prefixIcon: prefixIcon != null
              ? Image.asset(prefixIcon!, width: 20)
              : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
