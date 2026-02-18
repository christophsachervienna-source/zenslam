import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? height;
  final double? radius;
  final Color? borderColor;
  final bool? readOnly;

  final void Function()? onTap;
  final ValueChanged<String>? onChanged;
  final bool obsecureText;
  final TextInputType? textInputType;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintext,

    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.obsecureText = false,
    this.textInputType,
    this.height,
    this.radius,
    this.borderColor,
    this.readOnly,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,

        border: Border.all(
          color: borderColor ?? AppColors.primaryColor.withValues(alpha: 0.25),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius ?? 8),
      ),
      child: Center(
        child: TextField(
          onTap: onTap,
          autofocus: false,
          controller: controller,
          obscureText: obsecureText,
          keyboardType: textInputType,
          onChanged: onChanged,
          readOnly: readOnly ?? false,

          enableInteractiveSelection: false,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
          decoration: InputDecoration(
            hintText: hintext,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.hintText,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
