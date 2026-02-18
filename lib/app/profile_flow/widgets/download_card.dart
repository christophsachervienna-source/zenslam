import 'dart:io';
import 'dart:ui';

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  DownloadCard({super.key, required this.item, required this.onTap});

  final favoriteController = Get.find<FavoriteController>();

  String _formatDuration(dynamic duration) {
    if (duration == null) return '0 min';
    int seconds = duration is int ? duration : int.tryParse(duration.toString()) ?? 0;
    final minutes = (seconds / 60).round();
    if (minutes == 0) return '< 1 min';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) return '$hours hr';
    return '$hours hr $remainingMins min';
  }

  @override
  Widget build(BuildContext context) {
    bool isLocalImage =
        item['localThumbnailPath'] != null &&
        (item['localThumbnailPath'].startsWith('/') ||
            item['localThumbnailPath'].startsWith('file://'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              _buildBackgroundImage(isLocalImage),

              // Gradient overlay
              _buildGradientOverlay(),

              // Glass effect at bottom
              _buildGlassEffect(),

              // Content
              _buildContent(),

              // Favorite button
              _buildFavoriteButton(),

              // Downloaded badge
              _buildDownloadedBadge(),

              // Play button
              _buildPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(bool isLocalImage) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: isLocalImage
          ? Image.file(
              File(item['localThumbnailPath']),
              fit: BoxFit.cover,
              width: double.infinity,
            )
          : Image.network(
              item['thumbnail'] ?? item['imageUrl'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: QuestionnaireTheme.cardGradient(),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primaryColor.withValues(alpha: 0.5),
                  size: 40,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: QuestionnaireTheme.cardGradient(),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildGlassEffect() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0A0A0C).withValues(alpha: 0.4),
                  const Color(0xFF0A0A0C).withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with play button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item['title'] ?? 'No Title',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Category and duration row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['category'] ?? 'Audio',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(item['duration']),
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
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 10,
      left: 10,
      child: Obx(
        () {
          final isFavorite = favoriteController.isItemInFavorites(item['id']);
          return GestureDetector(
            onTap: () => favoriteController.addFavorites(item['id']),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                boxShadow: isFavorite
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFavorite
                    ? AppColors.primaryColor
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadedBadge() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.download_done_rounded,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      bottom: 50,
      right: 10,
      child: Obx(() {
        final audioService = AudioService.instance;
        final currentPlayingId = audioService.currentAudioData.value?['id'];
        final isThisAudioPlaying =
            audioService.hasActiveAudio.value &&
            currentPlayingId == item['id'] &&
            audioService.isPlaying.value;

        return GestureDetector(
          onTap: () {
            if (isThisAudioPlaying) {
              audioService.pauseAudio();
            } else if (audioService.hasActiveAudio.value &&
                currentPlayingId == item['id']) {
              audioService.resumeAudio();
            } else {
              onTap();
            }
          },
          child: Container(
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
                  color: AppColors.primaryColor.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
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
          ),
        );
      }),
    );
  }
}
