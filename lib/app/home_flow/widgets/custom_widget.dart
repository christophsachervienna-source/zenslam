import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomWidget extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onVideoTap;

  CustomWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onFavoriteTap,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A1F),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
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
                        onTap: () {
                          controller.isSelected.value =
                              !controller.isSelected.value;
                        },
                        child: Obx(
                          () => Image.asset(
                            controller.isSelected.value
                                ? ImagePath.favoriteImage
                                : IconsPath.fill,
                            height: 16,
                            width: 16,
                            fit: BoxFit.contain,
                          ),
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
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffffffff),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9A9A9E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
