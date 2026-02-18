import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/explore_all_controller.dart';
import 'package:zenslam/core/widgets/premium_cached_image.dart';
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/master_classes_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/recommendation_controller.dart';
import 'package:zenslam/app/home_flow/controller/series_controller.dart';
import 'package:zenslam/app/home_flow/controller/todays_dilles_controller.dart';
import 'package:zenslam/app/home_flow/model/masterclasses_screen.dart';
import 'package:zenslam/app/home_flow/model/series_screen.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_screen.dart';
import 'package:zenslam/app/home_flow/view/explore_all_screen.dart';
import 'package:zenslam/app/home_flow/widgets/duration_display.dart';
import 'package:zenslam/app/home_flow/widgets/feedback_bottom_sheet.dart';
import 'package:zenslam/app/meditation_timer/view/meditation_timer_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/core/widgets/no_internet_widget.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Redesigned Home Screen with Premium Aesthetic
/// Dark theme with champagne gold accents for a refined masculine experience
class RedesignedHomeScreen extends StatefulWidget {
  const RedesignedHomeScreen({super.key});

  @override
  State<RedesignedHomeScreen> createState() => _RedesignedHomeScreenState();
}

class _RedesignedHomeScreenState extends State<RedesignedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Hero carousel
  late PageController _heroPageController;
  final RxInt _currentHeroPage = 0.obs;
  Timer? _heroAutoScrollTimer;

  final HomeController controller = Get.find<HomeController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final RecommendationController recommendationController =
      Get.find<RecommendationController>();
  final TodaysDillesController dailiesController =
      Get.find<TodaysDillesController>();
  final FeaturedController featuredController = Get.find<FeaturedController>();
  final SeriesController seriesController = Get.find<SeriesController>();
  final MostPopularController mostPopularController =
      Get.find<MostPopularController>();
  final MasterClassesController masterClassesController =
      Get.find<MasterClassesController>();
  final ExploreAllController exploreAllController =
      Get.find<ExploreAllController>();
  final FavoriteController favoriteController = Get.put(FavoriteController());

  final ScrollController _scrollController = ScrollController();
  final RxDouble _scrollOffset = 0.0.obs;
  final RxBool _isConnected = true.obs;
  final RxBool _isCheckingConnection = false.obs;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _heroPageController = PageController(viewportFraction: 0.92);
    _startHeroAutoScroll();

    // Preload images after a brief delay to allow controllers to load cached data
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _preloadHomeScreenImages();
      }
    });
  }

  void _startHeroAutoScroll() {
    _heroAutoScrollTimer?.cancel();
    _heroAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_heroPageController.hasClients) {
        final itemCount = featuredController.featuredItems.length.clamp(0, 5);
        if (itemCount > 0) {
          final nextPage = (_currentHeroPage.value + 1) % itemCount;
          _heroPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    _isCheckingConnection.value = true;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      _isConnected.value = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      _isConnected.value = false;
    }
    _isCheckingConnection.value = false;
  }

  Future<void> _refreshData() async {
    await _checkConnectivity();
    if (_isConnected.value) {
      await Future.wait([
        recommendationController.fetchRecommendations(),
        dailiesController.fetchDailies(),
        featuredController.fetchFeaturedItems(),
        seriesController.fetchCategories(),
        mostPopularController.fetchPopularItems(),
        masterClassesController.fetchMasterClasses(),
        profileController.loadProfile(),
      ]);

      // Preload images for faster display
      _preloadHomeScreenImages();
    }
  }

  /// Preload images for all home screen content to improve perceived performance
  void _preloadHomeScreenImages() {
    final imageUrls = <String>[];

    // Featured items (hero carousel)
    imageUrls.addAll(
      featuredController.featuredItems.take(5).map((e) => e.imageUrl),
    );

    // Recommendations
    imageUrls.addAll(
      recommendationController.recommendations.take(6).map((e) => e.imageUrl),
    );

    // Today's dailies
    imageUrls.addAll(
      dailiesController.dailies.take(3).map((e) => e.imageUrl),
    );

    // Most popular
    imageUrls.addAll(
      mostPopularController.popularItems.take(6).map((e) => e.imageUrl),
    );

    // Series thumbnails
    imageUrls.addAll(
      seriesController.categoriesList.take(3).map((e) => e.thumbnail),
    );

    // Masterclasses
    imageUrls.addAll(
      masterClassesController.masterList.take(3).map((e) => e.imageUrl),
    );

    // Filter out empty URLs and preload
    final validUrls = imageUrls.where((url) => url.isNotEmpty).toList();
    if (validUrls.isNotEmpty) {
      debugPrint('🖼️ Preloading ${validUrls.length} home screen images...');
      ImagePreloader().preloadImages(validUrls);
    }
  }

  void _initAnimations() {
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _headerAnimController.forward();
  }

  void _onScroll() {
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _scrollController.dispose();
    _heroPageController.dispose();
    _heroAutoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: QuestionnaireTheme.backgroundGradient,
              ),
            ),

            // Main content with SafeArea for status bar only
            SafeArea(
              bottom: false,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  overscroll: false,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      _buildSimpleHeader(),

                      // Content sections
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildPremiumBanner(),
                            const SizedBox(height: 16),
                            // Show no internet placeholder if disconnected and no data
                            Obx(() => _buildConnectionAwareContent()),
                          ],
                        ),
                      ),

                      // Bottom spacing for mini player
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Mini player at bottom
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

  /// Build content based on connection status
  Widget _buildConnectionAwareContent() {
    // Check if we have any data loaded
    final hasAnyData = dailiesController.dailies.isNotEmpty ||
        featuredController.featuredItems.isNotEmpty ||
        seriesController.categoriesList.isNotEmpty ||
        mostPopularController.popularItems.isNotEmpty ||
        masterClassesController.masterList.isNotEmpty;

    // If no connection and no cached data, show the no internet placeholder
    if (!_isConnected.value && !hasAnyData) {
      return NoInternetWidget(
        onRetry: () async {
          HapticFeedback.lightImpact();
          await _refreshData();
        },
      );
    }

    // Otherwise show the normal content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCarousel(),
        const SizedBox(height: 36),
        _buildRecommendations(),
        const SizedBox(height: 36),
        _buildTodaysDailies(),
        const SizedBox(height: 36),
        _buildNewReleases(),
        const SizedBox(height: 36),
        _buildSeries(),
        const SizedBox(height: 36),
        _buildMostPopular(),
        const SizedBox(height: 36),
        _buildExploreCategories(),
        const SizedBox(height: 36),
        _buildMasterclasses(),
        const SizedBox(height: 36),
        // Individual category sections
        _buildCategorySection('Forehand', Icons.sports_tennis),
        _buildCategorySection('Backhand', Icons.swap_horiz),
        _buildCategorySection('Serve', Icons.arrow_upward),
        _buildCategorySection('Confidence', Icons.psychology),
        _buildCategorySection('Focus', Icons.center_focus_strong),
        _buildCategorySection('Flow State', Icons.waves),
        _buildCategorySection('Critical Moments', Icons.bolt),
        _buildCategorySection('Winning', Icons.emoji_events),
        const SizedBox(height: 36),
        _buildFeedbackSection(),
        const SizedBox(height: 36),
        _buildCommunitySection(),
      ],
    );
  }

  Widget _buildSimpleHeader() {
    return AnimatedBuilder(
      animation: _headerAnimController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildGreetingSection()),
                      const SizedBox(width: 16),
                      _buildUserAvatar(),
                    ],
                  ),
                  _buildMotivationalQuote(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny_outlined;
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_sunny;
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
      icon = Icons.nights_stay_outlined;
    } else {
      greeting = 'Good Night';
      icon = Icons.bedtime_outlined;
    }

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.12),
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: QuestionnaireTheme.accentGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    greeting,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              profileController.fullName.value.isNotEmpty
                  ? profileController.fullName.value
                  : 'Player',
              style: GoogleFonts.bebasNeue(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ));
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to meditation timer
        Get.to(() => const MeditationTimerScreen());
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.self_improvement_rounded,
            size: 26,
            color: QuestionnaireTheme.accentGold,
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    final quotes = [
      "Champions adjust. You will too.",
      "The point starts before the serve.",
      "Play the ball, not the scoreboard.",
      "Trust your swing.",
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: QuestionnaireTheme.cardBackground.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 16,
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              quote,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Obx(() {
      if (featuredController.featuredItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final items = featuredController.featuredItems.take(5).toList();

      return Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _heroPageController,
              onPageChanged: (index) => _currentHeroPage.value = index,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _HeroCard(
                  title: item.title,
                  category: item.category,
                  duration: item.duration,
                  imageUrl: item.imageUrl,
                  isLocked: item.isLocked,
                  isLoggedIn: controller.isLoggedIn.value,
                  isPremium: profileController.activeSubscription.value,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    featuredController.playFeatured(
                      item,
                      item.contentType[Random().nextInt(item.contentType.length)],
                      item.id,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Page indicators
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentHeroPage.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentHeroPage.value == index
                          ? QuestionnaireTheme.accentGold
                          : QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              )),
        ],
      );
    });
  }

  Widget _buildPremiumBanner() {
    return Obx(() {
      final isPremium = profileController.activeSubscription.value;
      final showUpgrade = !controller.isLoggedIn.value || !isPremium;

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(() => const SubscriptionScreenV2());
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: showUpgrade
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1610),
                      const Color(0xFF0D0B08),
                    ],
                  )
                : QuestionnaireTheme.accentGradient,
            border: Border.all(
              color: QuestionnaireTheme.accentGold.withValues(alpha: showUpgrade ? 0.4 : 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: QuestionnaireTheme.accentGold.withValues(alpha: showUpgrade ? 0.15 : 0.3),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated icon container with glow
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: showUpgrade
                      ? RadialGradient(
                          colors: [
                            QuestionnaireTheme.accentGold.withValues(alpha: 0.25),
                            QuestionnaireTheme.accentGold.withValues(alpha: 0.05),
                          ],
                        )
                      : RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                  border: Border.all(
                    color: showUpgrade
                        ? QuestionnaireTheme.accentGold.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  showUpgrade ? Icons.workspace_premium_rounded : Icons.verified_rounded,
                  size: 30,
                  color: showUpgrade
                      ? QuestionnaireTheme.accentGold
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showUpgrade ? 'UNLOCK FULL ACCESS' : 'PREMIUM MEMBER',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: showUpgrade
                            ? QuestionnaireTheme.textPrimary
                            : Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showUpgrade
                          ? 'Transform your mind with Zenslam Pro'
                          : 'All content unlocked',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: showUpgrade
                            ? QuestionnaireTheme.textSecondary
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: showUpgrade
                      ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: showUpgrade
                      ? QuestionnaireTheme.accentGold
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentYellow,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSeeAll();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: QuestionnaireTheme.accentGold,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Obx(() {
      if (!controller.isLoggedIn.value ||
          recommendationController.recommendations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('For You'),
          const SizedBox(height: 16),
          SizedBox(
            height: 210, // 180 + 30 for shadow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: recommendationController.recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendationController.recommendations[index];
                return _PremiumContentCard(
                  title: item.title,
                  category: item.category,
                  duration: item.duration,
                  imageUrl: item.imageUrl,
                  isLocked: item.isLocked,
                  isLoggedIn: controller.isLoggedIn.value,
                  isPremium: profileController.activeSubscription.value,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    recommendationController.playRecommendation(item);
                  },
                  itemId: item.id,
                  width: 160,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTodaysDailies() {
    return Obx(() {
      if (dailiesController.dailies.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            "Today's Dailies",
            onSeeAll: () {
              Get.to(() => TodaysDailiesScreen(isLoggedIn: controller.isLoggedIn));
            },
          ),
          const SizedBox(height: 16),
          ...List.generate(
            dailiesController.dailies.length > 3
                ? 3
                : dailiesController.dailies.length,
            (index) {
              final item = dailiesController.dailies[index];
              return _PremiumListTile(
                title: item.title,
                subtitle: '${item.category} • ${DurationDisplay.parseDuration(item.duration)}',
                imageUrl: item.imageUrl,
                isLocked: item.isLocked,
                isLoggedIn: controller.isLoggedIn.value,
                isPremium: profileController.activeSubscription.value,
                index: index,
                onTap: () {
                  HapticFeedback.lightImpact();
                  dailiesController.playDailies(
                    item,
                    item.contentType[Random().nextInt(item.contentType.length)],
                    item.id,
                  );
                },
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildSeries() {
    return Obx(() {
      if (seriesController.categoriesList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Series',
            onSeeAll: () {
              Get.to(() => SeriesScreen(isLoggedIn: controller.isLoggedIn));
            },
          ),
          const SizedBox(height: 16),
          ...List.generate(
            seriesController.categoriesList.length > 3
                ? 3
                : seriesController.categoriesList.length,
            (index) {
              final series = seriesController.categoriesList[index];
              return _PremiumSeriesCard(
                title: series.title,
                description: series.description,
                episodeCount: 0, // Episodes loaded on tap
                imageUrl: series.thumbnail,
                index: index,
                onTap: () {
                  HapticFeedback.lightImpact();
                  seriesController.handleSeriesTap(index);
                },
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildMostPopular() {
    return Obx(() {
      if (mostPopularController.popularItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Most Popular'),
          const SizedBox(height: 16),
          SizedBox(
            height: 270, // 240 + 30 for shadow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: mostPopularController.popularItems.length > 6
                  ? 6
                  : mostPopularController.popularItems.length,
              itemBuilder: (context, index) {
                final item = mostPopularController.popularItems[index];
                return _PremiumContentCard(
                  title: item.title,
                  category: item.category,
                  duration: item.duration,
                  imageUrl: item.imageUrl,
                  isLocked: item.isLocked,
                  isLoggedIn: controller.isLoggedIn.value,
                  isPremium: profileController.activeSubscription.value,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    mostPopularController.playPopular(
                      item,
                      item.contentType[Random().nextInt(item.contentType.length)],
                      item.id,
                    );
                  },
                  itemId: item.id,
                  width: 170,
                  height: 240,
                  showRank: true,
                  rank: index + 1,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildExploreCategories() {
    final categories = [
      _CategoryItem('Forehand', Icons.sports_tennis),
      _CategoryItem('Backhand', Icons.swap_horiz),
      _CategoryItem('Serve', Icons.arrow_upward),
      _CategoryItem('Confidence', Icons.psychology),
      _CategoryItem('Focus', Icons.center_focus_strong),
      _CategoryItem('Flow State', Icons.waves),
      _CategoryItem('Critical Moments', Icons.bolt),
      _CategoryItem('Winning', Icons.emoji_events),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Explore'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _PremiumCategoryChip(
              title: category.name,
              icon: category.icon,
              onTap: () {
                HapticFeedback.lightImpact();
                final categoryIndex = exploreAllController.categories.indexOf(category.name);
                Get.to(() => ExploreAllScreen(
                      categoryName: category.name,
                      categoryIndex: categoryIndex >= 0 ? categoryIndex : 0,
                      isLoggedIn: controller.isLoggedIn,
                    ));
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Obx(() {
      if (!profileController.isLoggedIn.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
              QuestionnaireTheme.cardBackground,
            ],
          ),
          border: Border.all(
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 40,
              color: QuestionnaireTheme.accentGold,
            ),
            const SizedBox(height: 16),
            Text(
              'HELP US IMPROVE',
              style: GoogleFonts.bebasNeue(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We want to make your experience even better. Share suggestions, feedback, or request meditation topics.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: QuestionnaireTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FeedbackBottomSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: QuestionnaireTheme.accentGradient,
                ),
                child: Text(
                  'Share Your Thoughts',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: QuestionnaireTheme.backgroundPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommunitySection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Image.asset(
                'assets/images/community_banner.png',
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlay
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coming Soon badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: QuestionnaireTheme.accentGradient,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 14,
                          color: QuestionnaireTheme.backgroundPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COMING SOON',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: QuestionnaireTheme.backgroundPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    'ZENSLAM COMMUNITY',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Join a brotherhood of men committed to growth. Connect, share experiences, and evolve together.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pre-register button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showCommunityPreRegistration();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: QuestionnaireTheme.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            size: 18,
                            color: QuestionnaireTheme.backgroundPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pre-Register Now',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: QuestionnaireTheme.backgroundPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommunityPreRegistration() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommunityPreRegistrationSheet(),
    );
  }

  Widget _buildNewReleases() {
    return Obx(() {
      // Get all items from featured and sort by views (lower views = newer)
      final allItems = [...featuredController.featuredItems];
      if (allItems.isEmpty) {
        return const SizedBox.shrink();
      }

      // Take first 6 items as "new releases"
      final newItems = allItems.take(6).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('New Releases'),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: newItems.length,
              itemBuilder: (context, index) {
                final item = newItems[index];
                return _PremiumContentCard(
                  title: item.title,
                  category: item.category,
                  duration: item.duration,
                  imageUrl: item.imageUrl,
                  isLocked: item.isLocked,
                  isLoggedIn: controller.isLoggedIn.value,
                  isPremium: profileController.activeSubscription.value,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    featuredController.playFeatured(
                      item,
                      item.contentType[Random().nextInt(item.contentType.length)],
                      item.id,
                    );
                  },
                  itemId: item.id,
                  width: 150,
                  height: 180,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategorySection(String categoryName, IconData icon) {
    return Obx(() {
      final items = exploreAllController.categoryContent[categoryName] ?? [];
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    categoryName.toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: QuestionnaireTheme.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final categoryIndex = exploreAllController.categories.indexOf(categoryName);
                  Get.to(() => ExploreAllScreen(
                        categoryName: categoryName,
                        categoryIndex: categoryIndex >= 0 ? categoryIndex : 0,
                        isLoggedIn: controller.isLoggedIn,
                      ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                    border: Border.all(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'See All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length > 6 ? 6 : items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _PremiumContentCard(
                  title: item.title,
                  category: item.category,
                  duration: item.duration,
                  imageUrl: item.thumbnail,
                  isLocked: item.isLocked,
                  isLoggedIn: controller.isLoggedIn.value,
                  isPremium: profileController.activeSubscription.value,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    exploreAllController.playMeditation(
                      item,
                      item.contentType[Random().nextInt(item.contentType.length)],
                      item.id,
                    );
                  },
                  itemId: item.id,
                  width: 150,
                  height: 180,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMasterclasses() {
    return Obx(() {
      if (masterClassesController.masterList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Masterclasses',
            onSeeAll: () {
              Get.to(() => MasterclassesScreen(isLoggedIn: controller.isLoggedIn));
            },
          ),
          const SizedBox(height: 16),
          ...List.generate(
            masterClassesController.masterList.length > 3
                ? 3
                : masterClassesController.masterList.length,
            (index) {
              final item = masterClassesController.masterList[index];
              return _PremiumListTile(
                title: item.title,
                subtitle: '${item.category} • ${DurationDisplay.parseDuration(item.duration)}',
                imageUrl: item.imageUrl,
                isLocked: item.isLocked,
                isLoggedIn: controller.isLoggedIn.value,
                isPremium: profileController.activeSubscription.value,
                index: index,
                isMasterclass: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  masterClassesController.playMasterClass(
                    item,
                    item.contentType[Random().nextInt(item.contentType.length)],
                    item.id,
                  );
                },
              );
            },
          ),
        ],
      );
    });
  }
}

/// Premium content card widget
class _PremiumContentCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final String imageUrl;
  final bool isLocked;
  final bool isLoggedIn;
  final bool isPremium;
  final VoidCallback onTap;
  final String? itemId; // Item ID for reactive favorite functionality
  final double width;
  final double? height;
  final bool showRank;
  final int? rank;

  const _PremiumContentCard({
    required this.title,
    required this.category,
    required this.duration,
    required this.imageUrl,
    required this.isLocked,
    required this.isLoggedIn,
    required this.isPremium,
    required this.onTap,
    this.itemId,
    this.width = 160,
    this.height,
    this.showRank = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized lock logic for consistent behavior
    final showLock = ContentLockHelper.instance.shouldShowLockIcon(isPaidContent: isLocked);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            // Gold glow shadow
            BoxShadow(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            // Black shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: QuestionnaireTheme.cardBackground,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: QuestionnaireTheme.accentGold,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: QuestionnaireTheme.cardBackground,
                  child: Icon(
                    Icons.image_not_supported,
                    color: QuestionnaireTheme.textTertiary,
                  ),
                ),
              ),

              // Gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ),
                ),
              ),

              // Glass effect with smooth fade (matching Explore page)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 90,
                child: Stack(
                  children: [
                    // Gradient mask for smooth blur fade
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    // Dark gradient overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0A0A0C).withValues(alpha: 0.4),
                            const Color(0xFF0A0A0C).withValues(alpha: 0.85),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Rank badge (top-left for Most Popular)
              if (showRank && rank != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: QuestionnaireTheme.accentGradient,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: QuestionnaireTheme.backgroundPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

              // Favorite button - top-left normally, top-right when rank badge present
              if (itemId != null && !showLock)
                Positioned(
                  top: 12,
                  left: (showRank && rank != null) ? null : 12,
                  right: (showRank && rank != null) ? 12 : null,
                  child: _FavoriteButton(itemId: itemId!),
                ),

              // Lock icon (gold color, top-right)
              if (showLock)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                ),

              // Content info (matching Explore page layout)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row with play button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Title - takes available space
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Play button
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: QuestionnaireTheme.accentGradient,
                            boxShadow: [
                              BoxShadow(
                                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Category and duration row
                    Row(
                      children: [
                        // Category badge - constrained to prevent overflow
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.25),
                            ),
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: QuestionnaireTheme.accentGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Duration with clock icon
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          DurationDisplay.parseDuration(duration),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reactive favorite button widget
class _FavoriteButton extends StatelessWidget {
  final String itemId;

  const _FavoriteButton({required this.itemId});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      // Force observation of reactive variables for immediate UI updates
      final _ = favoriteController.favorites.value;
      final __ = favoriteController.optimisticToggledItems.length;
      final ___ = favoriteController.pendingFavoriteOperations.length;

      final isFavorite = favoriteController.isItemInFavorites(itemId);
      final isPending = favoriteController.pendingFavoriteOperations.contains(itemId);

      return GestureDetector(
        onTap: () {
          if (!isPending) {
            HapticFeedback.lightImpact();
            favoriteController.addFavorites(itemId);
          }
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            boxShadow: isFavorite
                ? [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isPending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isFavorite ? QuestionnaireTheme.accentGold : Colors.white,
                  ),
          ),
        ),
      );
    });
  }
}

/// Premium list tile widget
class _PremiumListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isLocked;
  final bool isLoggedIn;
  final bool isPremium;
  final int index;
  final VoidCallback onTap;
  final bool isMasterclass;

  const _PremiumListTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isLocked,
    required this.isLoggedIn,
    required this.isPremium,
    required this.index,
    required this.onTap,
    this.isMasterclass = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized lock logic for consistent behavior
    final showLock = ContentLockHelper.instance.shouldShowLockIcon(isPaidContent: isLocked);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: QuestionnaireTheme.borderDefault.withValues(alpha:0.5),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: QuestionnaireTheme.backgroundSecondary,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: QuestionnaireTheme.accentGold,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: QuestionnaireTheme.backgroundSecondary,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: QuestionnaireTheme.textTertiary,
                        ),
                      ),
                    ),
                    // Play button overlay
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: QuestionnaireTheme.accentGold.withValues(alpha:0.9),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: QuestionnaireTheme.backgroundPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMasterclass)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: QuestionnaireTheme.accentGradient,
                      ),
                      child: Text(
                        'MASTERCLASS',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: QuestionnaireTheme.backgroundPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Lock or arrow
            if (showLock)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.backgroundSecondary,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: QuestionnaireTheme.textTertiary,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: QuestionnaireTheme.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Premium series card widget
class _PremiumSeriesCard extends StatelessWidget {
  final String title;
  final String description;
  final int episodeCount;
  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  const _PremiumSeriesCard({
    required this.title,
    required this.description,
    required this.episodeCount,
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: QuestionnaireTheme.cardBackground,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: QuestionnaireTheme.cardBackground,
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha:0.85),
                        Colors.black.withValues(alpha:0.4),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                episodeCount > 0 ? '$episodeCount EPISODES' : 'SERIES',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: QuestionnaireTheme.accentGold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuestionnaireTheme.accentGold,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 22,
                          color: QuestionnaireTheme.backgroundPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium category chip widget
class _PremiumCategoryChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _PremiumCategoryChip({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: QuestionnaireTheme.borderDefault.withValues(alpha:0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.accentGold.withValues(alpha:0.12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: QuestionnaireTheme.accentGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for category items
class _CategoryItem {
  final String name;
  final IconData icon;

  _CategoryItem(this.name, this.icon);
}

/// Hero carousel card widget
class _HeroCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final String imageUrl;
  final bool isLocked;
  final bool isLoggedIn;
  final bool isPremium;
  final VoidCallback onTap;

  const _HeroCard({
    required this.title,
    required this.category,
    required this.duration,
    required this.imageUrl,
    required this.isLocked,
    required this.isLoggedIn,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized lock logic for consistent behavior
    final showLock = ContentLockHelper.instance.shouldShowLockIcon(isPaidContent: isLocked);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: QuestionnaireTheme.cardBackground,
                  child: Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: QuestionnaireTheme.cardBackground,
                  child: Icon(
                    Icons.image_not_supported,
                    color: QuestionnaireTheme.textTertiary,
                    size: 40,
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.2, 0.5, 1.0],
                  ),
                ),
              ),

              // Featured badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: QuestionnaireTheme.accentGradient,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: QuestionnaireTheme.backgroundPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'FEATURED',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: QuestionnaireTheme.backgroundPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lock indicator
              if (showLock)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bebasNeue(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DurationDisplay.parseDuration(duration),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Play button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: QuestionnaireTheme.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 32,
                        color: QuestionnaireTheme.backgroundPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Community Pre-Registration Bottom Sheet
class _CommunityPreRegistrationSheet extends StatefulWidget {
  @override
  State<_CommunityPreRegistrationSheet> createState() =>
      _CommunityPreRegistrationSheetState();
}

class _CommunityPreRegistrationSheetState
    extends State<_CommunityPreRegistrationSheet> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isRegistered = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitPreRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call - replace with actual API endpoint
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isRegistered = true;
    });

    // Show success and close after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        Get.snackbar(
          'Welcome to the Brotherhood',
          "You'll be notified when the community launches!",
          backgroundColor: QuestionnaireTheme.cardBackground,
          colorText: QuestionnaireTheme.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QuestionnaireTheme.backgroundPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: QuestionnaireTheme.textTertiary.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),

              if (_isRegistered) ...[
                // Success state
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: QuestionnaireTheme.accentGradient,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: QuestionnaireTheme.backgroundPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "YOU'RE IN!",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: QuestionnaireTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We'll notify you when the Zenslam Community launches. Get ready to connect with like-minded men.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: QuestionnaireTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ] else ...[
                // Registration form
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 36,
                    color: QuestionnaireTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'JOIN THE COMMUNITY',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: QuestionnaireTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Be the first to know when the Zenslam Community launches. Connect with men on the same path of growth.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: QuestionnaireTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Features list
                _buildFeatureItem(
                  Icons.forum_rounded,
                  'Discussion Forums',
                  'Share experiences and learn from others',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  Icons.event_rounded,
                  'Live Events',
                  'Join group meditations and workshops',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  Icons.psychology_rounded,
                  'Expert Guidance',
                  'Access to mentors and coaches',
                ),
                const SizedBox(height: 28),

                // Email input
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.outfit(
                      color: QuestionnaireTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.outfit(
                        color: QuestionnaireTheme.textTertiary,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: QuestionnaireTheme.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: QuestionnaireTheme.accentGold,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: QuestionnaireTheme.textTertiary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                GestureDetector(
                  onTap: _isLoading ? null : _submitPreRegistration,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: QuestionnaireTheme.accentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: QuestionnaireTheme.backgroundPrimary,
                              ),
                            )
                          : Text(
                              'Get Early Access',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: QuestionnaireTheme.backgroundPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy note
                Text(
                  "We'll only use your email to notify you about the community launch.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: QuestionnaireTheme.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
            ),
            child: Icon(
              icon,
              size: 22,
              color: QuestionnaireTheme.accentGold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: QuestionnaireTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
