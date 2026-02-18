import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/nav_controller.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/view/favorite_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteController controller = Get.find<FavoriteController>();
  final NavController navController = Get.find<NavController>();
  Worker? _tabListener;

  @override
  void initState() {
    super.initState();
    // Refresh favorites when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshFavorites();
    });

    // Listen for tab changes to refresh when favorites tab is selected
    _tabListener = ever(navController.currentIndex, (index) {
      if (index == 2) {
        // Favorites tab index
        controller.refreshFavorites();
      }
    });
  }

  @override
  void dispose() {
    _tabListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: () {
                          final navController = Get.find<NavController>();
                          navController.changeTab(0);
                        },
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
                        'Favorites',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                // Content Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        // Load more when reaching bottom
                        if (scrollNotification.metrics.pixels ==
                                scrollNotification.metrics.maxScrollExtent &&
                            controller.hasMore.value &&
                            !controller.isLoadingMore.value) {
                          controller.loadMoreFavorites();
                        }
                        return false;
                      },
                      child: _buildContent(context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshFavorites();
      },
      backgroundColor: Colors.transparent,
      color: AppColors.primaryColor,
      child: Obx(() {
        // Access ALL observable variables in one place
        final isLoading = controller.isLoading.value;
        final isLoadingMore = controller.isLoadingMore.value;
        final error = controller.error.value;
        final favorites = controller.favorites.value;
        final hasMore = controller.hasMore.value;

        // Not logged in state
        if (!controller.isLoggedIn.value) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 36,
                        color: AppColors.primaryColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Save Your Favorites',
                      style: QuestionnaireTheme.titleLarge(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Sign in to save meditations and build your personal collection',
                        style: QuestionnaireTheme.bodyMedium(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Loading state
        if (isLoading && favorites == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        // Error state
        if (error.isNotEmpty && favorites == null) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load favorites',
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error,
                        style: QuestionnaireTheme.bodySmall(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => controller.refreshFavorites(),
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
          );
        }

        // Empty state
        if (favorites == null || favorites.data.data.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: QuestionnaireTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Favorites Yet',
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon to save content here',
                      style: QuestionnaireTheme.bodySmall(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Calculate total items including loading indicator
        final itemCount = favorites.data.data.length + (hasMore ? 1 : 0);

        // Data state with pagination
        return GridView.builder(
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
            // Show loading indicator at the end
            if (index >= favorites.data.data.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLoadingMore
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }

            final item = favorites.data.data[index];
            return FavoriteCard(
              item: item,
              onTap: () => controller.playMeditation(item),
            );
          },
        );
      }),
    );
  }
}
