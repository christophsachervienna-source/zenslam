import 'dart:math';

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/explore/view/widget/premium_content_card.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/explore_all_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreAllScreen extends StatelessWidget {
  final String categoryName;
  final int categoryIndex;
  final RxBool isLoggedIn;

  const ExploreAllScreen({
    super.key,
    required this.categoryName,
    required this.categoryIndex,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final ExploreAllController controller = Get.find<ExploreAllController>();
    final FavoriteController favoriteController = Get.find<FavoriteController>();
    final RxBool isNavigationLoading = false.obs;

    // Initialize the category when screen loads - always call selectCategory
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.selectCategory(categoryIndex);
      // If no items loaded for this category, fetch them
      if (controller.selectedCategoryItems.isEmpty) {
        final category = controller.categories[categoryIndex];
        await controller.loadContentForCategory(category);
        controller.selectCategory(categoryIndex); // Refresh after load
      }
    });

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
                        categoryName,
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                // Content Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildContent(controller, favoriteController, isNavigationLoading, context),
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

  Widget _buildContent(
    ExploreAllController controller,
    FavoriteController favoriteController,
    RxBool isNavigationLoading,
    BuildContext context,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent &&
            controller.currentCategoryHasMore &&
            !controller.isLoadingMore.value) {
          controller.loadMoreContent();
        }
        return false;
      },
      child: Obx(() {
        // Show loading indicator for initial load
        if (controller.isLoading.value && controller.selectedCategoryItems.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        // Show error message with retry
        if (controller.errorMessage.value.isNotEmpty &&
            controller.selectedCategoryItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => await controller.refreshContent(),
            color: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.primaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load content",
                        style: globalTextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.errorMessage.value,
                          style: globalTextStyle(color: Colors.white54, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshContent(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Show empty state
        if (controller.selectedCategoryItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => await controller.refreshContent(),
            color: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No items found for",
                        style: globalTextStyle(color: AppColors.primaryColor, fontSize: 16),
                      ),
                      Text(
                        categoryName,
                        style: globalTextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Grid content
        final itemCount = controller.selectedCategoryItems.length +
            (controller.currentCategoryHasMore ? 1 : 0);

        return RefreshIndicator(
          onRefresh: () async => await controller.refreshContent(),
          color: AppColors.primaryColor,
          backgroundColor: Colors.transparent,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= controller.selectedCategoryItems.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  ),
                );
              }

              final item = controller.selectedCategoryItems[index];
              return PremiumContentCard(
                item: item,
                onTap: () async {
                  isNavigationLoading.value = true;
                  await controller.playMeditation(
                    item,
                    item.contentType[Random().nextInt(item.contentType.length)],
                    item.id,
                  );
                  isNavigationLoading.value = false;
                },
                onFavoritePressed: () {
                  favoriteController.addFavorites(item.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
