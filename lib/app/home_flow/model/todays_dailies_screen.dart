import 'dart:math';

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/home_flow/controller/todays_dilles_controller.dart';
import 'package:zenslam/app/home_flow/widgets/todays_dilles_widget.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodaysDailiesScreen extends StatelessWidget {
  TodaysDailiesScreen({super.key, required this.isLoggedIn});

  final RxBool isLoggedIn;

  final TodaysDillesController dillesController =
      Get.find<TodaysDillesController>();

  final ProfileController profileController = Get.find();

  final RxBool isNavigationLoading = false.obs;

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
                        "Today's Dailies",
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        // Load more when reaching bottom
                        if (scrollNotification.metrics.pixels ==
                                scrollNotification.metrics.maxScrollExtent &&
                            dillesController.hasMore.value &&
                            !dillesController.isLoadingMore.value) {
                          dillesController.loadMoreDailies();
                        }
                        return false;
                      },
                      child: _buildContent(),
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
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await dillesController.refreshDailies();
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.transparent,
      child: Obx(() {
        // Show initial loading
        if (dillesController.isLoading.value &&
            dillesController.dailies.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          );
        }

        // Show error message
        if (dillesController.errorMessage.value.isNotEmpty &&
            dillesController.dailies.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.6,
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
                      "Error loading dailies",
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        dillesController.errorMessage.value,
                        style: QuestionnaireTheme.bodySmall(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => dillesController.refreshDailies(),
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
        if (dillesController.dailies.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today_outlined,
                      size: 64,
                      color: QuestionnaireTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No dailies available",
                      style: QuestionnaireTheme.titleMedium(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Check back later for new content",
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
            dillesController.dailies.length +
            (dillesController.hasMore.value ? 1 : 0);

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 120),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Show loading indicator at the end
            if (index >= dillesController.dailies.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: dillesController.isLoadingMore.value
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }

            final card = dillesController.dailies[index];
            return GestureDetector(
              onTap: () async {
                isNavigationLoading.value = true;
                await dillesController.playDailies(
                  card,
                  card.contentType[Random().nextInt(card.contentType.length)],
                  card.id,
                );
                isNavigationLoading.value = false;
              },
              child: TodaysDillesWidget(
                key: ValueKey(card.id),
                cards: card,
                index: index,
                isLoggedIn: isLoggedIn,
                activeSubscription: profileController.activeSubscription.value,
                isTrialExpired: profileController.isTrialExpired.value,
              ),
            );
          },
        );
      }),
    );
  }
}
