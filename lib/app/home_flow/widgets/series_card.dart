import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/home_flow/controller/series_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeriesCard extends StatelessWidget {
  final int index;
  final SeriesController controller;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  SeriesCard({
    super.key,
    required this.index,
    required this.controller,
    required this.isLoggedIn,
    this.activeSubscription,
    this.isTrialExpired,
  });
  final favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    final series = controller.categoriesList[index];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    series.name,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    series.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffffffff),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    series.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9A9A9E),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Container(
                height: 94,
                width: 94,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // image: DecorationImage(
                  //   image: NetworkImage(series.thumbnail), // Series image
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: series.thumbnail,
                          cacheKey: series.thumbnail,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 0),
                          fadeOutDuration: const Duration(milliseconds: 0),
                          memCacheWidth: 300,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            // You can add retry logic here
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.error,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Favorites disabled for series - removed favorite button
                    // Positioned(
                    //   top: 8,
                    //   right: 8,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Get.to(() => SubcriptionScreen());
                    //     },
                    //     child: Obx(() {
                    //       bool showLock = false;
                    //       if (!isLoggedIn.value) {
                    //         showLock = false;
                    //       } else {
                    //         if (activeSubscription == true ||
                    //             isTrialExpired == false) {
                    //           showLock = false;
                    //         } else {
                    //           showLock = true;
                    //         }
                    //       }

                    //       return showLock
                    //           ? Stack(
                    //               children: [
                    //                 Image.asset(
                    //                   IconsPath.lockBg,
                    //                   height: 20,
                    //                   width: 20,
                    //                   fit: BoxFit.contain,
                    //                 ),
                    //                 Positioned(
                    //                   top: 4,
                    //                   right: 5,
                    //                   child: Image.asset(
                    //                     IconsPath.lock,
                    //                     height: 10,
                    //                     width: 10,
                    //                     fit: BoxFit.contain,
                    //                   ),
                    //                 ),
                    //               ],
                    //             )
                    //           : SizedBox.shrink();
                    //     }),
                    //   ),
                    // ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Image.asset(
                        ImagePath.videoImage,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(String id) {
    return Obx(() {
      // Force observation of reactive variables for immediate UI updates
      final _ = favoriteController.favorites.value;
      final __ = favoriteController.optimisticToggledItems.length;
      final ___ = favoriteController.pendingFavoriteOperations.length;

      final isFavorite = favoriteController.isItemInFavorites(id);
      final isPending = favoriteController.pendingFavoriteOperations.contains(id);

      return GestureDetector(
        onTap: () {
          if (!isPending) {
            favoriteController.addSeriesCategoryFavorites(id);
          }
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: isPending
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isFavorite ? AppColors.primaryColor : Colors.white,
                  ),
          ),
        ),
      );
    });
  }
}
