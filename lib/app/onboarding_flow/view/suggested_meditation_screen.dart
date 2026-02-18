import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';

import 'package:zenslam/app/favorite_flow/controller/feedback_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/home_flow/widgets/suggested_meditation_card.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuggestedMeditationScreen extends StatelessWidget {
  SuggestedMeditationScreen({super.key});
  // final RecommendationController controller = Get.put(
  //   RecommendationController(),
  // );
  final ratingController = Get.put(FeedbackController());
  final ProfileController profileController = Get.find<ProfileController>();
  // final favoriteController = Get.put(FavoriteController(), permanent: true);

  Future<void> _precacheWelcomeImage(BuildContext context) async {
    try {
      await precacheImage(AssetImage(ImagePath.subcriptions), context);
    } catch (e) {
      debugPrint('Error pre-caching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheWelcomeImage(context);
    });
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePath.appBg),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 24),
                        Center(
                          child: Text(
                            "Meditations Picked for you",
                            style: globalTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            "Based on your answers, try these Meditations",
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9A9A9E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// Meditation Grid
                        _buildMostPopular(),

                        const SizedBox(height: 32),
                        const GreateValueWidget(
                          title: "Greatest Value",
                          subtitle: "Meditation App for Men",
                        ),
                        const SizedBox(height: 32),

                        Obx(() {
                          if (ratingController.isLoading.value &&
                              ratingController.ratingsList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (ratingController.ratingsList.isEmpty) {
                            return const SizedBox(
                              height: 150,
                              child: Center(child: Text('')),
                            );
                          }

                          return SizedBox(
                            height: 300,
                            child: PageView.builder(
                              itemCount: ratingController.ratingsList.length,
                              itemBuilder: (context, index) {
                                final rating =
                                    ratingController.ratingsList[index];
                                return _buildRatingCard(
                                  rating['title'],
                                  (rating['rating'] as num).round(),
                                  rating['description'] ?? "",
                                  " ${rating['user']['fullName'] ?? 'Anonymous'}",
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 35),

                        CustomButton(
                          title: "Continue",
                          onTap: () {
                            Get.to(() => const SubscriptionScreenV2());
                            //Get.to(() => NavBarScreen());
                          },
                        ),
                        const SizedBox(height: 40.0),
                      ],
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100,
                      child: MiniPlayerWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMostPopular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          final controller = Get.find<MostPopularController>();

          if (controller.isLoading.value) {
            return SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          debugPrint('Most Popular Length: ${controller.popularItems.length}');

          final itemsToShow = controller.popularItems.take(4).toList();

          return Align(
            alignment: Alignment.center,
            child: GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 9 / 6,

              children: itemsToShow
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        // controller.playPopular(
                        //   item,
                        //   item.contentType[Random().nextInt(
                        //     item.contentType.length,
                        //   )],
                        //   item.id,
                        // );
                      },
                      child: SuggestedMeditationCard(
                        index: itemsToShow.indexOf(item),
                        controller: controller,
                        isLoggedIn: controller.isLoggedIn,
                        activeSubscription:
                            profileController.activeSubscription.value,
                        isTrialExpired: profileController.isTrialExpired.value,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }),
      ],
    );
  }
}

Widget _buildRatingCard(
  String title,
  int rating,
  String description,
  String author,
) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xffFFEFC9), width: 1.5),
      gradient: const LinearGradient(
        colors: [Color(0xff4e4b45), Color(0xff575a5e)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (index) => Image.asset(
                IconsPath.starIcon,
                height: 24,
                width: 24,
                fit: BoxFit.contain,
                color: index < rating ? const Color(0xffb88b2f) : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "\"$description\"",
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9A9A9E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "---$author",
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

class GreateValueWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const GreateValueWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              IconsPath.leafLeft,
              height: 55,
              width: 55,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 166),
            Image.asset(
              IconsPath.leafRight,
              height: 55,
              width: 55,
              fit: BoxFit.contain,
            ),
          ],
        ),
        Positioned(
          bottom: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  lineHeight: 1.3,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                  lineHeight: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
