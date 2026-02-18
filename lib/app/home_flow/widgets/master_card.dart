import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/master_classes_controller.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MasterCard extends StatelessWidget {
  final int index;
  final MasterClassesController controller;
  final RxBool isLoggedIn;
  final bool? activeSubscription;
  final bool? isTrialExpired;

  MasterCard({
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
    final master = controller.masterList[index];

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
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Content on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      master.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    master.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    master.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Actions row - only show lock icon (favorites disabled for masterclasses)
                  Row(
                    children: [
                      // Lock icon
                      _buildLockIcon(master.isLocked),
                    ],
                  ),
                ],
              ),
            ),

            // Thumbnail on the right
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: master.thumbnail,
                          cacheKey: master.thumbnail,
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
                                Icons.school,
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
                            currentPlayingId == master.id &&
                            audioService.isPlaying.value;

                        return Container(
                          width: 32,
                          height: 32,
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
                            size: 20,
                          ),
                        );
                      }),
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
      final isPending =
          favoriteController.pendingFavoriteOperations.contains(id);

      return GestureDetector(
        onTap: () {
          if (!isPending) {
            favoriteController.addFavorites(id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
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
            size: 18,
            color: isFavorite
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    });
  }

  Widget _buildLockIcon(bool isLocked) {
    // Use centralized lock logic for consistency
    final showLock = ContentLockHelper.instance.shouldShowLockIcon(
      isPaidContent: isLocked,
    );

    if (!showLock) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Get.to(() => const SubscriptionScreenV2());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock,
          size: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
