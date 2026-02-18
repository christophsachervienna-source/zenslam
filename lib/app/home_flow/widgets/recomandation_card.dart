import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/recommendation_controller.dart';
import 'package:zenslam/app/mentor_flow/controller/recommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'duration_display.dart';

class RecomandationCard extends StatelessWidget {
  final int index;
  final RecommendationModel playerCard;
  final RecommendationController controller;

  RecomandationCard({
    super.key,
    required this.index,
    required this.playerCard,
    required this.controller,
  });

  final favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: playerCard.imageUrl,
                cacheKey: playerCard.imageUrl,
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
                  favoriteController.addFavorites(playerCard.id);
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
                        favoriteController.isItemInFavorites(playerCard.id)
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
          Positioned(
            bottom: 10,
            right: 10,
            child: Obx(() {
              final audioService = AudioService.instance;

              // Get current playing audio ID from stored data
              final currentPlayingId =
                  audioService.currentAudioData.value?['id'];
              final isThisAudioPlaying =
                  audioService.hasActiveAudio.value &&
                  currentPlayingId == playerCard.id &&
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
                Text(
                  playerCard.title,
                  style: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${playerCard.category} • ${DurationDisplay.parseDuration(playerCard.duration)}',
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
