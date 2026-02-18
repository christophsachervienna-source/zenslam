import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenslam/app/you_might_also_like/view/audio_player_controller.dart';
import 'package:zenslam/app/explore/controller/explore_controller.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/explore/view/widget/meditation_card.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/explore_all_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/master_classes_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/recommendation_controller.dart';
import 'package:zenslam/app/home_flow/controller/todays_dilles_controller.dart';
import 'package:zenslam/app/home_flow/model/featured_model.dart';
import 'package:zenslam/app/home_flow/model/masterclasses_model.dart';
import 'package:zenslam/app/mentor_flow/controller/most_popular_model.dart';
import 'package:zenslam/app/mentor_flow/controller/recommendation_model.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/app/you_might_also_like/view/you_might_also_like_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayerScreen extends StatelessWidget {
  AudioPlayerScreen({super.key});
  final favoriteController = Get.find<FavoriteController>();
  final ProfileController profileController = Get.find<ProfileController>();

  /// Determines if content should be locked.
  /// Simply uses the controller's already-computed lock status for consistency.
  bool _isContentLocked(AudioPlayerController controller) {
    return controller.isLocked.value;
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AudioPlayerController>()) {
      Get.delete<AudioPlayerController>(force: true);
    }
    final controller = Get.put(AudioPlayerController(), permanent: true);
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0C),
        body: Container(
          width: double.infinity,
          height: screenHeight,
          decoration: BoxDecoration(color: const Color(0xFF0A0A0C)),
          child: Stack(
            children: [
              // Background Image with Blur
              Obx(
                () => controller.imageUrl.value.isNotEmpty
                    ? Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: controller.imageUrl.value,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: const Color(0xFF0A0A0C)),
                          errorWidget: (context, url, error) =>
                              Container(color: const Color(0xFF0A0A0C)),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(color: const Color(0xFF0A0A0C)),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(controller, favoriteController),

                      Obx(() {
                        final isLocked = _isContentLocked(controller);
                        return isLocked
                            ? const SizedBox.shrink()
                            : controller.isLoading.value
                                ? _buildLoadingIndicator(context)
                                : const SizedBox.shrink();
                      }),

                      Obx(() {
                        final isLocked = _isContentLocked(controller);
                        return isLocked
                            ? _buildLockOverlay(context)
                            : const SizedBox.shrink();
                      }),

                      Obx(() {
                        final isLocked = _isContentLocked(controller);
                        return !isLocked && !controller.isLoading.value
                            ? _buildPlayerControls(controller, context)
                            : const SizedBox.shrink();
                      }),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),

                      Expanded(
                        child: Center(child: _buildContentInfo(controller)),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),

                      Obx(() {
                        final isLocked = _isContentLocked(controller);
                        return isLocked
                            ? _buildLockedRecommendationsWithButton(
                                controller,
                                context,
                                controller.currentModelType.value,
                                controller.currentItem.value,
                              )
                            : _buildRecommendations(
                                controller,
                                context,
                                controller.currentModelType.value,
                                controller.currentItem.value,
                              );
                      }),
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

Widget _buildLoadingIndicator(BuildContext context) {
  return Column(
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.154),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Image.asset(
              IconsPath.videobackward,
              height: 38,
              width: 38,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          //Image.asset(IconsPath.play, width: 40, height: 40),
          CircularProgressIndicator(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),

          Container(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              IconsPath.videofroward,
              height: 38,
              width: 38,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(Get.context!).copyWith(
                activeTrackColor: AppColors.primaryColor,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: AppColors.primaryColor,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 4,
              ),
              child: Slider(value: 0, onChanged: null),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '00:00',
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '00:00',
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildHeader(
  AudioPlayerController controller,
  FavoriteController favoriteController,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1F),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ),
        Row(
          children: [
            Obx(() {
              return GestureDetector(
                onTap: controller.isDownloaded.value
                    ? () {
                        Get.dialog(
                          AlertDialog(
                            title: Text('Remove Download?'),
                            content: Text(
                              'This will remove the audio from your offline storage.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.deleteAudio();
                                },
                                child: Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    : () {
                        controller.downloadAudio();
                      },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1F),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isDownloaded.value
                        ? Icons.download_done_outlined
                        : Icons.file_download_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            }),

            const SizedBox(width: 16),
            Obx(
              () => GestureDetector(
                onTap: () {
                  debugPrint(
                    'Favorite button pressed ID: ${controller.id.value}',
                  );
                  favoriteController.addFavorites(controller.id.value);
                },
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    Image.asset(
                      IconsPath.lockBg,
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Image.asset(
                        favoriteController.isItemInFavorites(
                              controller.id.value,
                            )
                            ? IconsPath.fill
                            : IconsPath.favoriteTwo,
                        height: 25,
                        width: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildLockOverlay(BuildContext context) {
  return Center(
    child: Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.14),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1F),
            shape: BoxShape.circle,
          ),
          child: Image.asset(IconsPath.lockIcon, height: 26),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.105),
      ],
    ),
  );
}

Widget _buildPlayerControls(
  AudioPlayerController controller,
  BuildContext context,
) {
  return Column(
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.154),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => controller.skipBackward(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Image.asset(
                IconsPath.videobackward,
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.2),

          Obx(
            () => GestureDetector(
              onTap: () => controller.togglePlayPause(),
              child: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.2),

          GestureDetector(
            onTap: () => controller.skipForward(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                IconsPath.videofroward,
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: AppColors.primaryColor,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: AppColors.primaryColor,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: controller.progress,
                  onChanged: (value) => controller.seekTo(value),
                ),
              ),
            ),

            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.formattedCurrentTime,
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      controller.formattedTotalTime,
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildContentInfo(AudioPlayerController controller) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, height: 0),
          Obx(
            () => Text(
              controller.title.value,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Obx(() {
            final fullDescription = controller.description.value;
            final isExpanded = controller.isDescriptionExpanded.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textSpan = TextSpan(
                      text: fullDescription,
                      style: GoogleFonts.dmSans(
                        color: Color(0xFF9A9A9E),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    );

                    final textPainter = TextPainter(
                      text: textSpan,
                      maxLines: 4,
                      textDirection: TextDirection.ltr,
                    );
                    textPainter.layout(maxWidth: constraints.maxWidth);

                    final exceedsMaxLines = textPainter.didExceedMaxLines;
                    final shouldShowButton = exceedsMaxLines;

                    final displayText = shouldShowButton && !isExpanded
                        ? _getTextUpToMaxLines(
                            fullDescription,
                            constraints.maxWidth,
                            12,
                          )
                        : fullDescription;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: GoogleFonts.dmSans(
                            color: Color(0xFF9A9A9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: isExpanded ? null : 4,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                        if (shouldShowButton) const SizedBox(height: 4),
                        if (shouldShowButton)
                          GestureDetector(
                            onTap: () {
                              controller.isDescriptionExpanded.value =
                                  !isExpanded;
                            },
                            child: Text(
                              isExpanded ? 'Show Less' : 'Show More',
                              style: GoogleFonts.dmSans(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'By ${controller.author.value}',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Helper to get category from any item type (handles FavoriteItem specially)
String _getCategoryFromItem(dynamic item) {
  if (item is FavoriteItem) {
    return item.item.category;
  }
  try {
    return item.category ?? '';
  } catch (e) {
    return '';
  }
}

Widget _buildLockedRecommendationsWithButton(
  AudioPlayerController controller,
  BuildContext context,
  String currentModelType,
  dynamic currentItem,
) {
  final modelItems = _getItemsByModelType(currentModelType, currentItem);
  return Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You might also like',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(
                    () => YouMightAlsoLikeScreen(
                      items: modelItems,
                      modelType: currentModelType,
                      category: _getCategoryFromItem(currentItem),
                    ),
                  ),
                  child: Text(
                    'See All',
                    style: GoogleFonts.dmSans(
                      color: !controller.isLocked.value
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          SizedBox(
            height: 165,
            child: modelItems.isEmpty
                ? Center(
                    child: Text(
                      'No items available',
                      style: GoogleFonts.dmSans(color: Colors.white),
                    ),
                  ) // Add this for debugging
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: modelItems.length,
                    itemBuilder: (context, index) {
                      final item = modelItems[index];
                      debugPrint('Item at index $index: ${item.toString()}');

                      return Container(
                        width: 165,
                        margin: const EdgeInsets.only(right: 16),
                        child: MeditationCard(
                          item: item,
                          onTap: () => debugPrint('Locked content tapped'),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 50),
        ],
      ),
      Positioned(
        top: 115,
        bottom: -3,
        right: 0,
        left: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xFF0A0A0C).withValues(alpha: 1.0),
                Color(0xFF0A0A0C).withValues(alpha: 1.0),
              ],
              stops: const [0.0, 0.55, 0.9],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 16, bottom: 40),
              child: _buildGetFullAccessButton(controller),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildRecommendations(
  AudioPlayerController controller,
  BuildContext context,
  String currentModelType,
  dynamic currentItem,
) {
  final modelItems = _getItemsByModelType(currentModelType, currentItem);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You might also like',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(
                () => YouMightAlsoLikeScreen(
                  items: modelItems,
                  modelType: currentModelType,
                  category: _getCategoryFromItem(currentItem),
                ),
              ),
              child: Text(
                'See All',
                style: GoogleFonts.dmSans(
                  color: !controller.isLocked.value
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 165,
        child: modelItems.isEmpty
            ? Center(
                child: Text(
                  'No items available',
                  style: GoogleFonts.dmSans(color: Colors.white),
                ),
              ) // Add this for debugging
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: modelItems.length,
                itemBuilder: (context, index) {
                  final item = modelItems[index];
                  debugPrint('Item at index $index: ${item.toString()}');

                  return Container(
                    width: 165,
                    margin: const EdgeInsets.only(right: 16),
                    child: MeditationCard(
                      item: item,
                      onTap: () {
                        debugPrint('On tap');
                        dynamic contentItem = item;
                        String itemId = '';
                        String itemContentType = '';

                        if (item is FavoriteItem) {
                          contentItem = item.item;
                          itemId = item.itemId;
                          // Get contentType from the tapped item - try multiple sources
                          if (item.contentType.isNotEmpty) {
                            itemContentType = item.contentType[0];
                          } else if (item.category.isNotEmpty) {
                            // Use category as fallback for contentType
                            itemContentType = item.category;
                          } else if (item.item.type.isNotEmpty) {
                            // Try the nested item's type directly
                            itemContentType = item.item.type;
                          } else {
                            // Last resort: use controller's current contentType
                            itemContentType = controller.contentType.value;
                          }
                          debugPrint('🎯 FavoriteItem contentType extraction:');
                          debugPrint('   - item.contentType: ${item.contentType}');
                          debugPrint('   - item.category: ${item.category}');
                          debugPrint('   - item.item.type: ${item.item.type}');
                          debugPrint('   - Final itemContentType: $itemContentType');
                        } else {
                          itemId = item.id;
                          // Get contentType from the item
                          try {
                            if (item.contentType != null && item.contentType.isNotEmpty) {
                              itemContentType = item.contentType[0];
                            } else {
                              itemContentType = controller.contentType.value;
                            }
                          } catch (e) {
                            itemContentType = controller.contentType.value;
                          }
                        }
                        controller.playNext(
                          contentItem,
                          currentModelType,
                          itemId,
                          itemContentType,
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      SizedBox(height: MediaQuery.of(context).size.width * 0.1),
    ],
  );
}

Widget _buildGetFullAccessButton(AudioPlayerController controller) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: () => controller.getFullAccess(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
      ),
      child: Text(
        'Get Full Access',
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

String _getTextUpToMaxLines(String text, double maxWidth, double fontSize) {
  final textSpan = TextSpan(
    text: text,
    style: GoogleFonts.dmSans(
      color: Color(0xFF9A9A9E),
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    ),
  );

  final textPainter = TextPainter(
    text: textSpan,
    maxLines: 4,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: maxWidth);

  // Get the end position for 4 lines
  final position = textPainter.getPositionForOffset(
    Offset(maxWidth, textPainter.preferredLineHeight * 4),
  );

  // Get the text up to the 4th line
  final endIndex =
      textPainter.getOffsetBefore(position.offset) ?? position.offset;

  // Extract the text and add ellipsis
  String result = text.substring(0, endIndex).trim();

  // Ensure we don't cut in the middle of a word if possible
  final lastSpace = result.lastIndexOf(' ');
  if (lastSpace > result.length * 0.8) {
    // Only if it's near the end
    result = result.substring(0, lastSpace).trim();
  }

  return '$result...';
}

List<dynamic> allItems = [
  RecommendationModel,
  TodaysDailiesModel,
  MostPopularModel,
  ExploreItem,
  MasterClassModel,
  FeaturedModel,
  FavoriteResponse,
];

List<dynamic> _getItemsByModelType(String modelType, dynamic currentItem) {
  debugPrint('=== _getItemsByModelType Debug ===');
  debugPrint('Received modelType: "$modelType"');
  debugPrint('Received currentItem: ${currentItem?.toString()}');
  debugPrint('CurrentItem ID: ${currentItem?.id}');
  debugPrint('CurrentItem runtimeType: ${currentItem?.runtimeType}');

  try {
    List<dynamic> items = [];

    // Get the appropriate list based on modelType
    switch (modelType) {
      case 'RecommendationModel':
        items = Get.find<RecommendationController>().recommendations;
        debugPrint('Found ${items.length} RecommendationModel items');
        break;
      case 'TodaysDailiesModel':
        items = Get.find<TodaysDillesController>().dailies;
        debugPrint('Found ${items.length} TodaysDailiesModel items');
        break;
      case 'MostPopularModel':
        items = Get.find<MostPopularController>().popularItems;
        debugPrint('Found ${items.length} MostPopularModel items');
        break;
      case 'ExploreItem':
        items = Get.find<ExploreController>().filteredContent;
        debugPrint('Found ${items.length} ExploreContent items');
        break;
      case 'ExploreAllItem':
        items = Get.find<ExploreAllController>().allExploreItems;
        debugPrint('Found ${items.length} ExploreAllContent items');
        break;
      case 'MasterClassModel':
        items = Get.find<MasterClassesController>().masterList;
        debugPrint('Found ${items.length} MasterClassModel items');
        break;
      case 'FeaturedModel':
        items = Get.find<FeaturedController>().featuredItems;
        debugPrint('Found ${items.length} FeaturedModel items');
        break;
      case 'FavoriteResponse':
        items = Get.find<FavoriteController>().favorites.value?.data.data ?? [];
        debugPrint('Found ${items.length} FavoriteResponse items');
        break;
      default:
        debugPrint('❌ Unknown model type: "$modelType"');
        debugPrint(
          'Available types: RecommendationModel, TodaysDailiesModel, MostPopularModel etc',
        );
        return [];
    }

    // Filter out the current item and return others
    // Filter out the current item and return others
    final filteredItems = items.where((item) {
      if (modelType == 'FavoriteResponse' &&
          item is FavoriteItem &&
          currentItem is FavoriteItem) {
        debugPrint(
          'Filtering FavoriteItem: ${item.itemId} != ${currentItem.itemId}',
        );
        return item.itemId != currentItem.itemId;
      }
      return item.id != currentItem?.id;
    }).toList();
    debugPrint('After filtering: ${filteredItems.length} items');

    return filteredItems;
  } catch (e) {
    debugPrint('❌ Error in _getItemsByModelType: $e');
    debugPrint('Stack trace: ${e.toString()}');
    return [];
  }
}
