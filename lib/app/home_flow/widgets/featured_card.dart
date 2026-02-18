import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/core/widgets/thumbnail_image.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'duration_display.dart';

class FeaturedCard extends StatelessWidget {
  final int index;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  final FeaturedController controller = Get.find<FeaturedController>();
  final favoriteController = Get.find<FavoriteController>();

  FeaturedCard({
    super.key,
    required this.index,
    required this.isLoggedIn,
    this.activeSubscription,
    this.isTrialExpired,
  });

  @override
  Widget build(BuildContext context) {
    final item = controller.featuredItems[index];

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ThumbnailImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 500,
                memCacheHeight: 500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          Positioned(
            top: 8,
            left: 8,
            child: Obx(() {
              // Force observation of reactive variables for immediate UI updates
              final _ = favoriteController.favorites.value;
              final __ = favoriteController.optimisticToggledItems.length;
              final ___ = favoriteController.pendingFavoriteOperations.length;

              final isFavorite = favoriteController.isItemInFavorites(item.id);
              final isPending =
                  favoriteController.pendingFavoriteOperations.contains(item.id);

              return GestureDetector(
                onTap: () {
                  if (!isPending) {
                    favoriteController.addFavorites(item.id);
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
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isFavorite
                                ? AppColors.primaryColor
                                : Colors.white,
                          ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Builder(
              builder: (context) {
                // Use centralized lock logic for consistency
                final showLock = ContentLockHelper.instance.shouldShowLockIcon(
                  isPaidContent: controller.featuredItems[index].isLocked,
                );

                if (!showLock) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    Get.to(() => const SubscriptionScreenV2());
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 8,
            right: 8,
            child: Obx(() {
              final audioService = AudioService.instance;

              // Get current playing audio ID from stored data
              final currentPlayingId =
                  audioService.currentAudioData.value?['id'];
              final isThisAudioPlaying =
                  audioService.hasActiveAudio.value &&
                  currentPlayingId == item.id &&
                  audioService.isPlaying.value;

              return GestureDetector(
                onTap: () {
                  // if (isThisAudioPlaying) {
                  //   audioService.pauseAudio();
                  // } else {
                  //   // Start playing this audio
                  // }
                },
                child: Image.asset(
                  isThisAudioPlaying
                      ? IconsPath.pauseIcon
                      : ImagePath.videoImage,
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                ),
              );
            }),
          ),

          Positioned(
            bottom: 8,
            left: 10,
            right: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${item.category} • ${DurationDisplay.parseDuration(item.duration)}',
                  style: globalTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9A9A9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
