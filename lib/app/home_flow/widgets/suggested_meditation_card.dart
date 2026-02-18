import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/core/widgets/thumbnail_image.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'duration_display.dart';

class SuggestedMeditationCard extends StatelessWidget {
  final int index;
  final MostPopularController controller;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  SuggestedMeditationCard({
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
    final card = controller.popularItems[index];

    return Container(
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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ThumbnailImage(
                imageUrl: card.imageUrl,
                fit: BoxFit.fill,
                memCacheWidth: 500,
                memCacheHeight: 500,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  favoriteController.addFavorites(card.id);
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
                        favoriteController.isItemInFavorites(card.id)
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

          // Lock - uses centralized lock logic for consistency
          Positioned(
            top: 8,
            right: 8,
            child: Builder(
              builder: (context) {
                final showLock = ContentLockHelper.instance.shouldShowLockIcon(
                  isPaidContent: controller.popularItems[index].isLocked,
                );

                if (!showLock) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {},
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
          // Video
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
                  currentPlayingId == card.id &&
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
                    card.title,
                    maxLines: 3, // Allow up to 3 lines
                    overflow: TextOverflow.ellipsis,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${card.category} • ${DurationDisplay.parseDuration(card.duration)}',
                  style: globalTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A9A9E),
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
