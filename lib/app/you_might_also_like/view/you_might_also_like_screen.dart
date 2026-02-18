import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/explore/view/widget/premium_content_card.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:zenslam/app/you_might_also_like/controller/you_might_also_like_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YouMightAlsoLikeScreen extends StatelessWidget {
  final List<dynamic> items;
  final String modelType;
  final String category;

  YouMightAlsoLikeScreen({
    super.key,
    required this.items,
    required this.modelType,
    required this.category,
  });

  final YouMightAlsoLikeController controller = Get.put(
    YouMightAlsoLikeController(),
  );
  final RxBool isNavigationLoading = false.obs;

  /// Convert dynamic item to ExploreItem for PremiumContentCard
  ExploreItem _convertToExploreItem(dynamic item) {
    if (item is ExploreItem) return item;

    try {
      // Handle FavoriteItem - content data is nested inside item.item
      if (item is FavoriteItem) {
        final content = item.item;
        return ExploreItem(
          id: item.itemId,
          title: content.title,
          description: content.description,
          thumbnail: content.thumbnail,
          content: content.content,
          author: content.author,
          duration: content.duration,
          contentType: content.type.isNotEmpty ? [content.type] : [category],
          accessType: content.accessType,
          views: 0,
          spendTime: 0,
          isFeature: false,
          masterClass: false,
          todayDailies: false,
          mostPopular: false,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
        );
      }

      // Default handling for other models
      return ExploreItem(
        id: item.id?.toString() ?? '',
        title: item.title ?? '',
        description: item.description ?? '',
        thumbnail: item.thumbnail ?? item.imageUrl ?? '',
        content: item.content ?? item.audioUrl ?? '',
        author: item.author ?? '',
        duration: item.duration is String ? item.duration : '0:00',
        contentType: item.contentType is List ? List<String>.from(item.contentType) : [category],
        accessType: item.accessType ?? 'FREE',
        views: item.views ?? 0,
        spendTime: item.spendTime ?? 0,
        isFeature: item.isFeature ?? false,
        masterClass: item.masterClass ?? false,
        todayDailies: item.todayDailies ?? false,
        mostPopular: item.mostPopular ?? false,
        createdAt: item.createdAt ?? DateTime.now(),
        updatedAt: item.updatedAt ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error converting item: $e');
      return ExploreItem.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController = Get.find<FavoriteController>();

    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header - matching Explore page style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: QuestionnaireTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'You Might Also Like',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),

                // Content Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: items.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 120),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final exploreItem = _convertToExploreItem(item);

                              return PremiumContentCard(
                                item: exploreItem,
                                onTap: () async {
                                  isNavigationLoading.value = true;
                                  // Get the correct ID for the content
                                  final contentId = item is FavoriteItem ? item.itemId : item.id;
                                  await controller.playLike(item, category, contentId, modelType);
                                  isNavigationLoading.value = false;
                                },
                                onFavoritePressed: () {
                                  favoriteController.addFavorites(exploreItem.id);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            // Mini player
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(),
            ),
            // Loading overlay
            Obx(() => isNavigationLoading.value
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: 64,
            color: QuestionnaireTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: QuestionnaireTheme.titleMedium(),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for suggestions',
            style: QuestionnaireTheme.bodySmall(),
          ),
        ],
      ),
    );
  }
}
