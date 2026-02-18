import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:zenslam/app/home_flow/widgets/duration_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeditationCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  MeditationCard({super.key, required this.item, required this.onTap});

  final favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    // Extract data based on item type
    String imageUrl = '';
    String title = '';
    String durationText = '';
    String id = '';
    String contentTypeString = '';

    if (item is FavoriteItem) {
      final content = item.item;
      imageUrl = content.thumbnail;
      title = content.title;
      durationText = content.duration; // It's already a String "MM:SS"
      id = item.itemId; // Use itemId for favorites
      // FavoriteItemData has 'type' as a String, not 'contentType' as a List
      contentTypeString = content.type;
    } else {
      // Default handling for other models
      try {
        imageUrl = item.thumbnail ?? item.imageUrl ?? '';
        title = item.title ?? '';

        if (item.duration is Duration) {
          durationText = _formatDuration(item.duration);
        } else if (item.duration is String) {
          durationText = item.duration;
        } else {
          durationText = '0:00';
        }

        id = item.id?.toString() ?? '';
        if (item.contentType != null &&
            item.contentType is List &&
            item.contentType.isNotEmpty) {
          contentTypeString = item.contentType[0];
        }
      } catch (e) {
        debugPrint('Error extracting item data: $e');
      }
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
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
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              // Background Image
              // SizedBox(
              //   width: double.infinity,
              //   height: double.infinity,
              //   child: Image.network(
              //     imageUrl,
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

              // Favorite Icon
              Positioned(
                top: 8,
                left: 8,
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      favoriteController.addFavorites(id);
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
                          right: 6,
                          child: Image.asset(
                            favoriteController.isItemInFavorites(id)
                                ? IconsPath.fill
                                : IconsPath.favorite,
                            height: 11,
                            width: 11,
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
                child: Image.asset(
                  ImagePath.videoImage,
                  height: 20,
                  width: 20,
                  fit: BoxFit.contain,
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
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$contentTypeString • ${DurationDisplay.parseDuration(durationText)}',
                              style: globalTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9A9A9E),
                              ),
                            ),
                          ),
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

String _formatDuration(Duration duration) {
  if (duration == Duration.zero) return '0';

  // Format as MM:SS
  return '${duration.inMinutes}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
}
