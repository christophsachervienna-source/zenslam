import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodaysDillesWidget extends StatelessWidget {
  final TodaysDailiesModel cards;
  final int index;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  final favoriteController = Get.find<FavoriteController>();

  TodaysDillesWidget({
    super.key,
    required this.cards,
    required this.index,
    required this.isLoggedIn,
    this.activeSubscription,
    this.isTrialExpired,
  });

  /// Format duration to user-friendly format (e.g., "5 min", "1 hr 20 min")
  String _formatDuration(String duration) {
    final parts = duration.split(':');
    if (parts.isEmpty) return duration;

    try {
      if (parts.length == 2) {
        // MM:SS format
        final minutes = int.tryParse(parts[0]) ?? 0;
        if (minutes == 0) return '< 1 min';
        if (minutes < 60) return '$minutes min';
        final hours = minutes ~/ 60;
        final remainingMins = minutes % 60;
        if (remainingMins == 0) return '$hours hr';
        return '$hours hr $remainingMins min';
      } else if (parts.length == 3) {
        // HH:MM:SS format
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        if (hours == 0 && minutes == 0) return '< 1 min';
        if (hours == 0) return '$minutes min';
        if (minutes == 0) return '$hours hr';
        return '$hours hr $minutes min';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
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
          children: [
            // Thumbnail
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: cards.imageUrl,
                        cacheKey: cards.imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 0),
                        fadeOutDuration: const Duration(milliseconds: 0),
                        memCacheWidth: 300,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF252528),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF252528),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: AppColors.primaryColor.withValues(alpha: 0.5),
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Obx(() {
                      final audioService = AudioService.instance;
                      final currentPlayingId =
                          audioService.currentAudioData.value?['id'];
                      final isThisAudioPlaying =
                          audioService.hasActiveAudio.value &&
                          currentPlayingId == cards.id &&
                          audioService.isPlaying.value;

                      return Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withValues(alpha: 0.85),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          isThisAudioPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with favorite/lock icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          cards.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorite button
                      _buildFavoriteButton(),
                      const SizedBox(width: 6),
                      // Lock icon
                      _buildLockIcon(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category and duration
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cards.category,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Duration
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(cards.duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Obx(() {
      // Force observation of reactive variables for immediate UI updates
      final _ = favoriteController.favorites.value;
      final __ = favoriteController.optimisticToggledItems.length;
      final ___ = favoriteController.pendingFavoriteOperations.length;

      final isFavorite = favoriteController.isItemInFavorites(cards.id);
      final isPending =
          favoriteController.pendingFavoriteOperations.contains(cards.id);

      return GestureDetector(
        onTap: () {
          if (!isPending) {
            favoriteController.addFavorites(cards.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: isFavorite
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isFavorite
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    });
  }

  Widget _buildLockIcon() {
    // Use centralized lock logic for consistency
    final showLock = ContentLockHelper.instance.shouldShowLockIcon(
      isPaidContent: cards.isLocked,
    );

    if (!showLock) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Get.to(() => const SubscriptionScreenV2());
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock,
          size: 16,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
