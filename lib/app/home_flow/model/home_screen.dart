import 'dart:math';

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/controller/explore_controller.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/explore_all_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/master_classes_controller.dart';
import 'package:zenslam/app/home_flow/view/explore_all_screen.dart';
import 'package:zenslam/app/home_flow/model/masterclasses_screen.dart';
import 'package:zenslam/app/home_flow/model/series_screen.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_screen.dart';
import 'package:zenslam/app/home_flow/widgets/bottom_card.dart';
import 'package:zenslam/app/home_flow/widgets/greeting_widget.dart';
import 'package:zenslam/app/home_flow/widgets/master_card.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/recommendation_controller.dart';
import 'package:zenslam/app/home_flow/controller/series_controller.dart';
import 'package:zenslam/app/home_flow/controller/todays_dilles_controller.dart';
import 'package:zenslam/app/home_flow/view/featured_screen.dart';
import 'package:zenslam/app/home_flow/widgets/feedback_bottom_sheet.dart';
import 'package:zenslam/app/home_flow/widgets/button_widget.dart';
import 'package:zenslam/app/home_flow/widgets/featured_card.dart';
import 'package:zenslam/app/home_flow/widgets/most_popular_card.dart';
import 'package:zenslam/app/home_flow/widgets/recomandation_card.dart';
import 'package:zenslam/app/home_flow/widgets/series_card.dart';
import 'package:zenslam/app/home_flow/widgets/todays_dilles_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.find<HomeController>();

  final RecommendationController recommedationController =
      Get.find<RecommendationController>();

  final TodaysDillesController dillesController =
      Get.find<TodaysDillesController>();

  final FeaturedController featuredController = Get.find<FeaturedController>();

  final SeriesController seriesController = Get.find<SeriesController>();

  final MostPopularController mostPopularController =
      Get.find<MostPopularController>();

  final MasterClassesController masterClassesController =
      Get.find<MasterClassesController>();

  final ExploreController exploreController = Get.find<ExploreController>();

  final ExploreAllController exploreAllController =
      Get.find<ExploreAllController>();
  final ProfileController profileController = Get.find<ProfileController>();

  final FavoriteController favoriteController = Get.put(FavoriteController());

  // Observable for tracking loading state
  final RxBool isNavigationLoading = false.obs;

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
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImagePath.appBg),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    recommedationController.fetchRecommendations(),
                    dillesController.fetchDailies(),
                    featuredController.fetchFeaturedItems(),
                    seriesController.fetchCategories(),
                    mostPopularController.fetchPopularItems(),
                    masterClassesController.fetchMasterClasses(),
                    profileController.loadProfile(),
                  ]);
                  controller.loadUserName();
                },
                color: AppColors.primaryColor,
                backgroundColor: Colors.transparent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 26,
                  ),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 25),
                        Obx(() => _buildPremiumBanner()),
                        const SizedBox(height: 24),
                        Obx(
                          () =>
                              controller.isLoggedIn.value &&
                                  recommedationController
                                      .recommendations
                                      .isNotEmpty
                              ? _buildRecommendations()
                              : SizedBox.shrink(),
                        ),
                        const SizedBox(height: 34),
                        Obx(
                          () => dillesController.dailies.isNotEmpty
                              ? _buildTodaysDailies()
                              : SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                        featuredController.featuredItems.isNotEmpty
                            ? _buildFeatured()
                            : SizedBox.shrink(),
                        const SizedBox(height: 20),

                        seriesController.categoriesList.isNotEmpty
                            ? _buildSeries()
                            : SizedBox.shrink(),
                        const SizedBox(height: 10),
                        mostPopularController.popularItems.isNotEmpty
                            ? _buildMostPopular()
                            : SizedBox.shrink(),
                        const SizedBox(height: 24),
                        _buildExploreAll(),
                        const SizedBox(height: 24),
                        Obx(
                          () => controller.isLoggedIn.value
                              ? _buildFeedbackBox(context)
                              : SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),
                        masterClassesController.featuredMasterClasses.isNotEmpty
                            ? _buildMasterclasses()
                            : SizedBox.shrink(),
                        const SizedBox(height: 20),
                        _buildAllExploreAll(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayerWidget()),
          // Loading Overlay
          Obx(
            () => isNavigationLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Row(
        children: [
          GreetingWidget(),
          Text(
            ", ${profileController.fullName.value}",
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    // Check if user is premium
    // We strictly rely on activeSubscription, which is now correctly parsed
    // from the subscription object in ProfileController (covering all plan types).
    final isPremium = profileController.activeSubscription.value;

    // If not logged in, or not premium, show the "Free/Upgrade" card
    final showUpgradeBanner = !controller.isLoggedIn.value || !isPremium;

    return showUpgradeBanner ? _buildFreeCard() : _buildPremiumUserCard();
  }

  Widget _buildFreeCard() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.to(() => const SubscriptionScreenV2()),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff94A3B8), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Image.asset(ImagePath.starImage, height: 56, width: 56),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Unlock everything with \nZenslam Pro",
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Image.asset(IconsPath.arrowFroward, height: 34, width: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUserCard() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.to(() => const SubscriptionScreenV2()),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Image.asset(ImagePath.starImage, height: 56, width: 56),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "You Are A Premium User",
                    style: globalTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Icon(Icons.done_all_rounded, color: AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final RxBool isNavigationLoading = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommendations For You",
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 135,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // Load more when reaching end of horizontal scroll
              if (scrollNotification.metrics.pixels ==
                      scrollNotification.metrics.maxScrollExtent &&
                  recommedationController.hasMore.value &&
                  !recommedationController.isLoadingMore.value) {
                recommedationController.loadMoreRecommendations();
              }
              return false;
            },
            child: Obx(() {
              if (recommedationController.isLoading.value &&
                  recommedationController.recommendations.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                );
              }

              if (recommedationController.errorMessage.value.isNotEmpty &&
                  recommedationController.recommendations.isEmpty) {
                return Center(
                  child: Text(
                    recommedationController.errorMessage.value,
                    style: TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (recommedationController.recommendations.isEmpty) {
                return Center(
                  child: Text(
                    "No recommendations available",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              // Calculate total items including loading indicator
              final itemCount =
                  recommedationController.recommendations.length +
                  (recommedationController.hasMore.value ? 1 : 0);

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                padding: const EdgeInsets.only(right: 16),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end
                  if (index >= recommedationController.recommendations.length) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      child: Center(
                        child: recommedationController.isLoadingMore.value
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final player = recommedationController.recommendations[index];
                  return GestureDetector(
                    onTap: () async {
                      isNavigationLoading.value = true;
                      recommedationController.playRecommendation(player);
                      isNavigationLoading.value = false;
                    },
                    child: RecomandationCard(
                      playerCard: player,
                      index: index,
                      controller: recommedationController,
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysDailies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Today's Dailies",
          onSeeAll: () {
            Get.to(
              () => TodaysDailiesScreen(isLoggedIn: controller.isLoggedIn),
            );
          },
        ),
        SizedBox(height: 16),
        Obx(() {
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dillesController.dailies.length > 3
                ? 3
                : dillesController.dailies.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  isNavigationLoading.value = true;
                  await dillesController.playDailies(
                    dillesController.dailies[index],
                    dillesController.dailies[index].contentType[Random()
                        .nextInt(
                          dillesController.dailies[index].contentType.length,
                        )],
                    dillesController.dailies[index].id,
                  );
                  isNavigationLoading.value = false;
                },
                child: TodaysDillesWidget(
                  key: ValueKey(dillesController.dailies[index].id),
                  cards: dillesController.dailies[index],
                  index: index,
                  isLoggedIn: controller.isLoggedIn,
                  activeSubscription:
                      profileController.activeSubscription.value,
                  isTrialExpired: profileController.isTrialExpired.value,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildFeatured() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Featured",
          onSeeAll: () =>
              Get.to(() => FeaturedScreen(isLoggedIn: controller.isLoggedIn)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 135,
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredController.featuredItems.length > 3
                  ? 3
                  : featuredController.featuredItems.length,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  isNavigationLoading.value = true;
                  await featuredController.playFeatured(
                    featuredController.featuredItems[index],
                    featuredController.featuredItems[index].contentType[Random()
                        .nextInt(
                          featuredController
                              .featuredItems[index]
                              .contentType
                              .length,
                        )],
                    featuredController.featuredItems[index].id,
                  );
                  isNavigationLoading.value = false;
                },
                child: FeaturedCard(
                  index: index,
                  isLoggedIn: controller.isLoggedIn,
                  activeSubscription:
                      profileController.activeSubscription.value,
                  isTrialExpired: profileController.isTrialExpired.value,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Series",
          onSeeAll: () {
            Get.to(() => SeriesScreen(isLoggedIn: controller.isLoggedIn));
          },
        ),
        const SizedBox(height: 20),
        Obx(
          () => Column(
            children: List.generate(
              seriesController.categoriesList.length > 3
                  ? 3
                  : seriesController.categoriesList.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () async {
                    isNavigationLoading.value = true;
                    await seriesController.handleSeriesTap(index);
                    isNavigationLoading.value = false;
                  },
                  child: SeriesCard(
                    index: index,
                    controller: seriesController,
                    isLoggedIn: controller.isLoggedIn,
                    activeSubscription:
                        profileController.activeSubscription.value,
                    isTrialExpired: profileController.isTrialExpired.value,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMostPopular() {
    final RxBool isNavigationLoading = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Most Popular",
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (mostPopularController.isLoading.value &&
              mostPopularController.popularItems.isEmpty) {
            return SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              ),
            );
          }

          if (mostPopularController.errorMessage.value.isNotEmpty &&
              mostPopularController.popularItems.isEmpty) {
            return SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mostPopularController.errorMessage.value,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => mostPopularController.refreshPopular(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (mostPopularController.popularItems.isEmpty) {
            return SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  "No popular items available",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            );
          }

          // Calculate total items including loading indicator
          final itemCount =
              mostPopularController.popularItems.length +
              (mostPopularController.hasMore.value ? 1 : 0);

          return SizedBox(
            height: 240,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                // Load more when reaching end of horizontal scroll
                if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent &&
                    mostPopularController.hasMore.value &&
                    !mostPopularController.isLoadingMore.value) {
                  mostPopularController.loadMorePopular();
                }
                return false;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                padding: const EdgeInsets.only(right: 20),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end
                  if (index >= mostPopularController.popularItems.length) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: mostPopularController.isLoadingMore.value
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final popularItem = mostPopularController.popularItems[index];
                  return GestureDetector(
                    onTap: () async {
                      isNavigationLoading.value = true;
                      await mostPopularController.playPopular(
                        popularItem,
                        popularItem.contentType[Random().nextInt(
                          popularItem.contentType.length,
                        )],
                        popularItem.id,
                      );
                      isNavigationLoading.value = false;
                    },
                    child: MostPopularCard(
                      index: index,
                      controller: mostPopularController,
                      isLoggedIn: mostPopularController.isLoggedIn,
                      activeSubscription:
                          profileController.activeSubscription.value,
                      isTrialExpired: profileController.isTrialExpired.value,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExploreAll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore All",
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          padding: EdgeInsets.symmetric(vertical: 0),
          children: [
            ServiceCard(
              iconPath: ImagePath.menu,
              title: "Meditation",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Meditation');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Meditation',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.fitnessicon,
              title: "Discipline",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Discipline');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Discipline',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.confidenticon,
              title: "Confidence",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Confidence');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Confidence',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.prossesicon,
              title: "Purpose",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Purpose');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Purpose',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.focusicon,
              title: "Focus",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Focus');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Focus',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.disiciplineicon,
              title: "Manhood",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Manhood');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Manhood',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.friendshipicon,
              title: "Relationship",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Relationship');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Relationship',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.datingicon,
              title: "Dating",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Dating');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Dating',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
            ServiceCard(
              iconPath: ImagePath.othersicon,
              title: "Others",
              onTap: () {
                final idx = exploreAllController.categories.indexOf('Others');
                Get.to(
                  () => ExploreAllScreen(
                    categoryName: 'Others',
                    categoryIndex: idx >= 0 ? idx : 0,
                    isLoggedIn: controller.isLoggedIn,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackBox(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xff575b5e), const Color(0xff4c473e)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffFFEFC9), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Help us make your \nexperience even better!",
              textAlign: TextAlign.center,
              style: globalTextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Share your feedback and tell us what \nyou need most — we listen.",
              style: globalTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FeedbackBottomSheet(),
                );
              },
              child: Container(
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: const Color(0xffF6CB62),
                  border: Border.all(color: const Color(0xffF6CB62)),
                ),
                child: Center(
                  child: Text(
                    "Share Feedback",
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterclasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Masterclasses",
          onSeeAll: () {
            Get.to(
              () => MasterclassesScreen(isLoggedIn: controller.isLoggedIn),
            );
          },
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(
            masterClassesController.masterList.length > 3
                ? 3
                : masterClassesController.masterList.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () async {
                  isNavigationLoading.value = true;
                  await masterClassesController.playMasterClass(
                    masterClassesController.masterList[index],
                    masterClassesController
                        .masterList[index]
                        .contentType[Random().nextInt(
                      masterClassesController
                          .masterList[index]
                          .contentType
                          .length,
                    )],
                    masterClassesController.masterList[index].id,
                  );
                  isNavigationLoading.value = false;
                },
                child: MasterCard(
                  index: index,
                  controller: masterClassesController,
                  isLoggedIn: controller.isLoggedIn,
                  activeSubscription:
                      profileController.activeSubscription.value,
                  isTrialExpired: profileController.isTrialExpired.value,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              "See All",
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAllExploreAll() {
    return Obx(() {
      if (!exploreAllController.hasAnyData &&
          !exploreAllController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "",
                style: globalTextStyle(color: Colors.white54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (exploreAllController.isLoading.value &&
          !exploreAllController.hasAnyData) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: exploreAllController.categories.length,
        itemBuilder: (context, categoryIndex) {
          final categoryName = exploreAllController.categories[categoryIndex];
          final categoryItems = exploreAllController.getItemsByCategory(
            categoryName,
          );

          if (categoryItems.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  categoryName,
                  onSeeAll: () {
                    exploreAllController.selectCategory(categoryIndex);
                    Get.to(
                      () => ExploreAllScreen(
                        categoryName: categoryName,
                        categoryIndex: categoryIndex,
                        isLoggedIn: controller.isLoggedIn,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryItems.length,
                    itemBuilder: (context, itemIndex) {
                      final item = categoryItems[itemIndex];
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.42,
                        margin: const EdgeInsets.only(right: 12),
                        child: BottomCard(
                          item: item,
                          isLoggedIn: controller.isLoggedIn,
                          activeSubscription:
                              profileController.activeSubscription.value,
                          isTrialExpired:
                              profileController.isTrialExpired.value,
                          onTap: () async {
                            isNavigationLoading.value = true;
                            await exploreAllController.playMeditation(
                              item,
                              item.contentType[Random().nextInt(
                                item.contentType.length,
                              )],
                              item.id,
                            );
                            isNavigationLoading.value = false;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
