import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final Color color;
  final Color textColor;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.height = 56,
    this.width,
    this.color = AppColors.primaryColor,
    this.textColor = const Color(0xff00071B),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade600 : color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDisabled ? Colors.grey.shade600 : color),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child:
              child ??
              Text(
                title,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDisabled ? Colors.white70 : textColor,
                ),
              ),
        ),
      ),
    );
  }
}
