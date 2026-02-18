import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 100,
        margin: EdgeInsets.only(top: 0),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A30), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 24, width: 24, fit: BoxFit.cover),
            const SizedBox(height: 6),
            Text(
              title,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9A9A9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
