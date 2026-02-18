import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/core/route/image_path.dart';

class MindfulnessCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onVideoTap;

  const MindfulnessCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.imagePath,
    this.onFavoriteTap,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A1F),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      title,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffffffff),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9A9A9E),
                      ),
                    ),
                  ],
                ),
              ),

              // Image with icons
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 5,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Image.asset(
                          ImagePath.favoriteImage,
                          height: 16,
                          width: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Image.asset(
                          ImagePath.lockImage,
                          height: 16,
                          width: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: onVideoTap,
                        child: Image.asset(
                          ImagePath.videoImage,
                          height: 16,
                          width: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
