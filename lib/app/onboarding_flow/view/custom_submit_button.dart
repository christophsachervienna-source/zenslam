import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? icon;
  final double? radius;
  final Color? bgColor;
  final Color? border;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final FontWeight? fontWeight;

  const CustomSubmitButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.bgColor,
    this.border,
    this.textColor,
    this.radius,
    this.fontSize,
    this.height,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius ?? 8),
      child: Ink(
        decoration: BoxDecoration(
          gradient: bgColor == null
              ? const LinearGradient(
                  colors: [Color(0xff972E8B), Color(0xff5B0C6A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: bgColor, // if you want solid color instead of gradient
          borderRadius: BorderRadius.circular(radius ?? 8),
          border: Border.all(color: border ?? AppColors.primaryColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius ?? 8),
          splashColor: Colors.white.withValues(alpha: .3),
          onTap: onTap,
          child: Container(
            height: height ?? 50,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: fontSize ?? 16,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      color: textColor ?? AppColors.primaryColor,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 5),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.textBlack,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: icon),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
