import 'dart:math';

import 'package:zenslam/app/bottom_nav_bar/controller/nav_controller.dart';
import 'package:zenslam/app/explore/controller/explore_controller.dart';
import 'package:zenslam/app/explore/view/widget/explore_search_bar.dart';
import 'package:zenslam/app/explore/view/widget/filter_bottom_sheet.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/explore/view/widget/premium_content_card.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreScreen extends StatelessWidget {
  ExploreScreen({super.key});

  final ExploreController controller = Get.find<ExploreController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final RxBool isNavigationLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: QuestionnaireTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Obx(() => ExploreSearchBar(
                      controller: searchController,
                      onChanged: (query) => controller.search(query),
                      onFilterPressed: () => _showFilterSheet(context),
                      showFilterIndicator: controller.sortBy.value != 0,
                    )),
                  ),

                  // Category Chips
                  _buildCategoryChips(),

                  const SizedBox(height: 16),

                  // Content Grid
                  Expanded(
                    child: _buildContentGrid(context),
                  ),
                ],
              ),

              // Mini Player
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayerWidget(),
              ),

              // Loading Overlay
              Obx(
                () => isNavigationLoading.value
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
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final navController = Get.find<NavController>();
              navController.changeTab(0);
            },
            icon: Image.asset(
              IconsPath.arrowBackIcon,
              width: 24,
            ),
          ),
          Text(
            'Explore',
            style: QuestionnaireTheme.headline(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selectedIndex = controller.selectedCategory.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.selectCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.primaryColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      controller.categories[index],
                      style: QuestionnaireTheme.bodySmall(
                        color: isSelected
                            ? Colors.black
                            : QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildContentGrid(BuildContext context) {
    return Obx(() {
      // Show search results if searching
      if (controller.isSearching.value) {
        return _buildSearchResults();
      }

      // Show loading
      if (controller.isLoading.value && controller.filteredContent.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        );
      }

      // Show error
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(
            "Failed to load content",
            style: QuestionnaireTheme.bodyMedium(color: AppColors.primaryColor),
          ),
        );
      }

      // Show empty state
      if (controller.filteredContent.isEmpty) {
        return _buildEmptyState();
      }

      // Show content grid
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent &&
              controller.hasMore.value &&
              !controller.isLoadingMore.value) {
            controller.loadMoreContent();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshContent();
          },
          color: AppColors.primaryColor,
          backgroundColor: QuestionnaireTheme.cardBackground,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: controller.filteredContent.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.filteredContent.length) {
                return Center(
                  child: controller.isLoadingMore.value
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              }

              final item = controller.filteredContent[index];
              return PremiumContentCard(
                item: item,
                onTap: () => _playItem(item),
                onFavoritePressed: () => item.isFavorite.toggle(),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      // Show loading while searching
      if (controller.isSearchLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: QuestionnaireTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: QuestionnaireTheme.titleMedium(),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords',
                style: QuestionnaireTheme.bodySmall(),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final item = controller.searchResults[index];
          return PremiumContentCard(
            item: item,
            onTap: () => _playItem(item),
            onFavoritePressed: () => item.isFavorite.toggle(),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshContent();
      },
      color: AppColors.primaryColor,
      backgroundColor: QuestionnaireTheme.cardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(Get.context!).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: QuestionnaireTheme.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  "No content in",
                  style: QuestionnaireTheme.bodyMedium(),
                ),
                Text(
                  controller.categories[controller.selectedCategory.value],
                  style: QuestionnaireTheme.titleMedium(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      initialSortIndex: controller.sortBy.value,
      onApply: (sortIndex) {
        controller.applyFilters(sort: sortIndex);
      },
    );
  }

  void _playItem(dynamic item) async {
    isNavigationLoading.value = true;
    await controller.playMeditation(
      item,
      item.contentType[Random().nextInt(item.contentType.length)],
      item.id,
    );
    isNavigationLoading.value = false;
  }
}
