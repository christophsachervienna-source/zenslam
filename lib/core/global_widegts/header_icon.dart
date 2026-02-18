import 'package:flutter/material.dart';

class HeaderIcon extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;

  const HeaderIcon({super.key, required this.iconPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        width: 26,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF).withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Image.asset(iconPath, height: 14, width: 14),
      ),
    );
  }
}
