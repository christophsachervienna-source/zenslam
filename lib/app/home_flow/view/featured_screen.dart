import 'dart:math';

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/home_flow/widgets/featured_card.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeaturedScreen extends StatelessWidget {
  FeaturedScreen({super.key, required this.isLoggedIn});

  final RxBool isLoggedIn;

  final controller = Get.find<FeaturedController>();
  final RxBool isNavigationLoading = false.obs;
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.appBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(text: "Featured"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 6),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        // Load more when reaching bottom
                        if (scrollNotification.metrics.pixels ==
                                scrollNotification.metrics.maxScrollExtent &&
                            controller.hasMore.value &&
                            !controller.isLoadingMore.value) {
                          controller.loadMoreFeatured();
                        }
                        return false;
                      },
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
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
        await controller.refreshFeatured();
      },
      color: AppColors.primaryColor,
      backgroundColor: Colors.transparent,
      child: Obx(() {
        // Show initial loading
        if (controller.isLoading.value && controller.featuredItems.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          );
        }

        // Show error message
        if (controller.errorMessage.value.isNotEmpty && controller.featuredItems.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading featured items",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refreshFeatured(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show empty state
        if (controller.featuredItems.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.6,
              child: Center(
                child: Text(
                  "No featured items available",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }

        // Calculate total items including loading indicator
        final itemCount = controller.featuredItems.length +
            (controller.hasMore.value ? 1 : 0);

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Show loading indicator at the end
            if (index >= controller.featuredItems.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: controller.isLoadingMore.value
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }

            final featuredItem = controller.featuredItems[index];
            return GestureDetector(
              onTap: () async {
                isNavigationLoading.value = true;
                await controller.playFeatured(
                  featuredItem,
                  featuredItem.contentType[Random().nextInt(
                    featuredItem.contentType.length,
                  )],
                  featuredItem.id,
                );
                isNavigationLoading.value = false;
              },
              child: FeaturedCard(
                index: index,
                isLoggedIn: isLoggedIn,
                activeSubscription:
                    profileController.activeSubscription.value,
                isTrialExpired:
                    profileController.isTrialExpired.value,
              ),
            );
          },
        );
      }),
    );
  }
}