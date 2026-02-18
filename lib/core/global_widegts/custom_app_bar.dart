import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final bool showImage;
  final String? text;
  final String? imagePath;
  final VoidCallback? onImageTap;

  const CustomAppBar({
    super.key,
    this.showImage = false,
    this.text,
    this.imagePath,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 55.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              IconsPath.arrowBackIcon,
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ),
          ),

          if (text != null)
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                text!,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffffffff),
                ),
              ),
            ),

          const Spacer(),

          if (imagePath != null)
            GestureDetector(
              onTap: onImageTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Image.asset(
                  imagePath!,
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
