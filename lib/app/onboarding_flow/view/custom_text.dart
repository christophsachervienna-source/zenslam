import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final double? height;

  const CustomText({
    super.key,
    required this.text,
    this.maxLines,
    this.textOverflow,
    this.fontSize,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: fontSize ?? 16,
        height: height,
        color: color ?? AppColors.textBlack,
        fontWeight: fontWeight ?? FontWeight.w500,
      ),
      overflow: textOverflow,
      maxLines: maxLines,
    );
  }
}
