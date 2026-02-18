import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'duration_display.dart';

class BottomCard extends StatelessWidget {
  final ExploreItem item;
  final VoidCallback onTap;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  BottomCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.isLoggedIn,
    this.activeSubscription,
    this.isTrialExpired,
  });
  final favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    cacheKey: item.thumbnail,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 0),
                    fadeOutDuration: const Duration(milliseconds: 0),
                    memCacheWidth: 500,
                    memCacheHeight: 500,
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
                        child: Icon(Icons.error, color: Colors.grey.shade200),
                      );
                    },
                  ),
                ),
              ),
              // Background Image
              // SizedBox(
              //   width: double.infinity,
              //   height: double.infinity,
              //   child: Image.network(
              //     item.thumbnail,
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) => Container(
              //       color: Colors.grey[800],
              //       child: const Icon(
              //         Icons.image_not_supported,
              //         color: Colors.white54,
              //         size: 50,
              //       ),
              //     ),
              //     loadingBuilder: (context, child, loadingProgress) {
              //       if (loadingProgress == null) return child;
              //       return Container(
              //         color: Colors.grey[800],
              //         child: Center(
              //           child: CircularProgressIndicator(
              //             valueColor: AlwaysStoppedAnimation<Color>(
              //               const Color(0xFFD4B896),
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              // Gradient Overlay
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
                      Colors.black.withValues(
                        alpha: 0.7,
                      ), // Fixed: use withOpacity
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 8,
                left: 8,
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      favoriteController.addFavorites(item.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        Image.asset(
                          IconsPath.lockBg,
                          height: 22,
                          width: 22,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Image.asset(
                            favoriteController.isItemInFavorites(item.id)
                                ? IconsPath.fill
                                : IconsPath.favorite,
                            height: 12,
                            width: 12,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Lock Icon - uses centralized lock logic for consistency
              Positioned(
                top: 8,
                right: 8,
                child: Builder(
                  builder: (context) {
                    final showLock = ContentLockHelper.instance.shouldShowLockIcon(
                      isPaidContent: item.isLocked,
                    );

                    if (!showLock) return const SizedBox.shrink();

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => const SubscriptionScreenV2());
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            IconsPath.lockBg,
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Image.asset(
                              IconsPath.lock,
                              height: 11,
                              width: 11,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.contentType[0]} • ${DurationDisplay.parseDuration(item.duration)}',
                              style: globalTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9A9A9E),
                              ),
                            ),
                          ),
                          Obx(() {
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
                          // Container(
                          //   padding: const EdgeInsets.all(2),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: const Icon(
                          //     Icons.play_arrow_rounded,
                          //     color: Colors.black,
                          //     size: 16,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
