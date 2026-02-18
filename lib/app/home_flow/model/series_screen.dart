import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/home_flow/controller/series_controller.dart';
import 'package:zenslam/app/home_flow/widgets/series_card.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeriesScreen extends StatelessWidget {
  SeriesScreen({super.key, required this.isLoggedIn});
  final RxBool isLoggedIn;
  final SeriesController seriesController = Get.find<SeriesController>();
  final RxBool isNavigationLoading = false.obs;
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Premium header - matching Explore page style
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
                        'Series',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent &&
                          seriesController.hasMore.value &&
                          !seriesController.isLoadingMore.value) {
                        seriesController.loadMoreCategories();
                      }
                      return false;
                    },
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(),
            ),
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
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await seriesController.refreshCategories();
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.transparent,
      child: Obx(() {
        // Show initial loading
        if (seriesController.isLoading.value &&
            seriesController.categoriesList.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          );
        }

        // Show error message
        if (seriesController.errorMessage.value.isNotEmpty &&
            seriesController.categoriesList.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.7,
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
                      'Failed to load series',
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        seriesController.errorMessage.value,
                        style: QuestionnaireTheme.bodySmall(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => seriesController.refreshCategories(),
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

        // Show empty state
        if (seriesController.categoriesList.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: QuestionnaireTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Series Available',
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new content',
                      style: QuestionnaireTheme.bodySmall(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Calculate total items including loading indicator
        final itemCount =
            seriesController.categoriesList.length +
            (seriesController.hasMore.value ? 1 : 0);

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Show loading indicator at the end
            if (index >= seriesController.categoriesList.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: seriesController.isLoadingMore.value
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => seriesController.handleSeriesTap(index),
                child: SeriesCard(
                  index: index,
                  controller: seriesController,
                  isLoggedIn: isLoggedIn,
                  activeSubscription:
                      profileController.activeSubscription.value,
                  isTrialExpired: profileController.isTrialExpired.value,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
