// Final 10/10 Paywall Design - Zenslam
// High-converting premium paywall with all conversion optimizations

import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/core/services/revenuecat_service.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/onboarding_flow/controller/subcription_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreenV2 extends StatefulWidget {
  const SubscriptionScreenV2({super.key});

  @override
  State<SubscriptionScreenV2> createState() => _SubscriptionScreenV2State();
}

class _SubscriptionScreenV2State extends State<SubscriptionScreenV2>
    with TickerProviderStateMixin {
  final SubscriptionController controller = Get.put(SubscriptionController());
  final ProfileController profileController = Get.find<ProfileController>();

  // Premium colors
  static Color goldPrimary = AppColors.primaryColor;
  static const Color goldLight = Color(0xFFE8CFA3);
  static const Color goldDark = Color(0xFFB89B6A);
  static const Color bgPrimary = Color(0xFF0F1318);
  static const Color bgCard = Color(0xFF1E242C);
  static const Color textSecondary = Color(0xFFCFCFCF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);

  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _initializePlans();
  }

  void _initializePlans() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileController.plans.isNotEmpty) {
        final annualPlans = profileController.plans
            .where((plan) => plan.subscriptionType.toUpperCase() == 'YEARLY')
            .toList();

        if (annualPlans.isNotEmpty) {
          final planIndex = profileController.plans.indexWhere(
            (p) => p.id == annualPlans.first.id,
          );
          if (planIndex != -1) {
            profileController.selectPlan(planIndex);
          }
          controller.selectPlan(annualPlans.first.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      body: Stack(
        children: [
          // Animated ambient background
          _buildAmbientBackground(),

          // Main content
          Obx(() {
            if (profileController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: goldPrimary),
              );
            }

            final monthlyPlans = profileController.plans
                .where((plan) => plan.subscriptionType.toUpperCase() == 'MONTHLY')
                .toList();
            final annualPlans = profileController.plans
                .where((plan) => plan.subscriptionType.toUpperCase() == 'YEARLY')
                .toList();
            final lifetimePlans = profileController.plans
                .where((plan) => plan.subscriptionType.toUpperCase() == 'LIFETIME')
                .toList();

            // RevenueCat offerings are the source of truth for store prices.
            // Backend plans only provide metadata; RC provides the real pricing.
            final offerings = profileController.rcOfferings.value;
            final hasRcOfferings = offerings?.current != null;

            // Determine which RC-only fallback cards to show (plan exists in
            // RC but not in the backend list).
            final hasMonthlyFallback = monthlyPlans.isEmpty &&
                offerings?.current?.monthly != null;
            final hasAnnualFallback = annualPlans.isEmpty &&
                offerings?.current?.annual != null;
            final hasLifetimeFallback = lifetimePlans.isEmpty &&
                offerings?.current?.lifetime != null;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildHeader(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildHeroSection(),
                              const SizedBox(height: 16),
                              _buildSocialProof(),
                              const SizedBox(height: 20),
                              _buildFeatures(),
                              const SizedBox(height: 12),

                              // When RC offerings failed to load, show retry
                              if (!hasRcOfferings) ...[
                                const SizedBox(height: 20),
                                _buildPricingUnavailable(),
                                const SizedBox(height: 20),
                              ],

                              // Plans with proper ordering — prices come from
                              // RevenueCat only; cards auto-hide when no
                              // store product is available.
                              ...monthlyPlans.map((plan) => Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 4),
                                child: _buildPlanCard(
                                  plan: plan,
                                  badge: 'subscription.flexible'.tr(),
                                  isRecommended: false,
                                ),
                              )),
                              if (hasMonthlyFallback)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: _buildRcFallbackCard(
                                    package: offerings!.current!.monthly!,
                                    label: 'subscription.monthly'.tr(),
                                    badge: 'subscription.flexible'.tr(),
                                    isRecommended: false,
                                  ),
                                ),
                              ...annualPlans.map((plan) => Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 4),
                                child: _buildPlanCard(
                                  plan: plan,
                                  badge: '\u{1F525} ${'subscription.most_popular'.tr()}',
                                  isRecommended: true,
                                  showTrial: profileController.isTrialEligible.value,
                                ),
                              )),
                              if (hasAnnualFallback)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: _buildRcFallbackCard(
                                    package: offerings!.current!.annual!,
                                    label: 'subscription.yearly'.tr(),
                                    badge: 'subscription.most_popular'.tr(),
                                    isRecommended: true,
                                    showTrial: profileController.isTrialEligible.value,
                                  ),
                                ),
                              ...lifetimePlans.map((plan) => Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 4),
                                child: _buildPlanCard(
                                  plan: plan,
                                  badge: 'subscription.best_value'.tr(),
                                  isRecommended: false,
                                ),
                              )),
                              if (hasLifetimeFallback)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: _buildRcFallbackCard(
                                    package: offerings!.current!.lifetime!,
                                    label: 'subscription.lifetime'.tr(),
                                    badge: 'subscription.best_value'.tr(),
                                    isRecommended: false,
                                  ),
                                ),

                              const SizedBox(height: 16),
                              _buildTestimonial(),
                              const SizedBox(height: 130),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          // Sticky CTA Button anchored at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgPrimary.withValues(alpha: 0.0),
                    bgPrimary.withValues(alpha: 0.9),
                    bgPrimary,
                  ],
                  stops: const [0.0, 0.35, 0.5],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCTAButton(),
                      const SizedBox(height: 10),
                      Obx(() {
                        final trialEligible = profileController.isTrialEligible.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (trialEligible) ...[
                              Icon(Icons.verified_user_rounded, color: successGreen, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'subscription.try_risk_free'.tr(),
                                style: globalTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: successLight,
                                ),
                              ),
                              Text(
                                '  \u2022  ',
                                style: globalTextStyle(fontSize: 12, color: textMuted),
                              ),
                            ],
                            Text(
                              'subscription.cancel_anytime'.tr(),
                              style: globalTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.05);
        return Stack(
          children: [
            Positioned(
              top: -180,
              left: -100,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        goldPrimary.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -120,
              child: Transform.scale(
                scale: 1.0 + ((1 - _pulseController.value) * 0.05),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        goldDark.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          _buildHeaderButton(
            icon: Icons.close_rounded,
            onTap: () => Get.offAll(() => NavBarScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: textSecondary, size: 18),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Text(
          'subscription.transform_your_mind'.tr(),
          style: globalTextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: goldPrimary,
          ).copyWith(letterSpacing: 3),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'subscription.become_the_man'.tr()),
              TextSpan(
                text: 'subscription.meant_to_be'.tr(),
                style: TextStyle(
                  color: goldPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'subscription.join_description'.tr(),
          textAlign: TextAlign.center,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            lineHeight: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProof() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProofItem('subscription.members_count'.tr(), 'subscription.members_label'.tr()),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
          _buildProofItem('subscription.rating_value'.tr(), 'subscription.rating_label'.tr()),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
          _buildProofItem('subscription.calmer_percent'.tr(), 'subscription.calmer_label'.tr()),
        ],
      ),
    );
  }

  Widget _buildProofItem(String value, String label, {bool showStar = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStar) ...[
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: globalTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: globalTextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textMuted,
          ).copyWith(letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {'icon': Icons.all_inclusive_rounded, 'text': 'subscription.feature_unlimited'.tr()},
      {'icon': Icons.school_rounded, 'text': 'subscription.feature_expert'.tr()},
      {'icon': Icons.download_rounded, 'text': 'subscription.feature_offline'.tr()},
      {'icon': Icons.star_rounded, 'text': 'subscription.feature_new_sessions'.tr()},
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldPrimary.withValues(alpha: 0.12),
                    goldPrimary.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: goldPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                feature['text'] as String,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  /// Shown when RevenueCat offerings failed to load so the user can retry
  /// instead of seeing wrong Stripe/backend prices.
  Widget _buildPricingUnavailable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: textMuted, size: 32),
          const SizedBox(height: 12),
          Text(
            'Unable to load pricing',
            style: globalTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: globalTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => profileController.getPackage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: goldPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldPrimary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Retry',
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: goldPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required dynamic plan,
    required String badge,
    required bool isRecommended,
    bool showTrial = false,
  }) {
    final isMonthly = plan.subscriptionType.toUpperCase() == 'MONTHLY';
    final isYearly = plan.subscriptionType.toUpperCase() == 'YEARLY';
    final isLifetime = plan.subscriptionType.toUpperCase() == 'LIFETIME';

    // Prices must come from RevenueCat (i.e. the real Apple/Google store
    // prices).  Backend prices are for Stripe/web and do NOT match the stores.
    final offerings = profileController.rcOfferings.value;
    StoreProduct? storeProduct;

    if (offerings?.current != null) {
      if (isMonthly && offerings!.current!.monthly != null) {
        storeProduct = offerings.current!.monthly!.storeProduct;
      } else if (isYearly && offerings!.current!.annual != null) {
        storeProduct = offerings.current!.annual!.storeProduct;
      } else if (isLifetime && offerings!.current!.lifetime != null) {
        storeProduct = offerings.current!.lifetime!.storeProduct;
      }
    }

    // Fallback: use directly-fetched store products when RC offering
    // doesn't include the package (Android base plan ID mismatch).
    if (storeProduct == null && isMonthly) {
      storeProduct = profileController.fallbackMonthlyProduct.value;
    } else if (storeProduct == null && isYearly) {
      storeProduct = profileController.fallbackAnnualProduct.value;
    }

    // If we don't have a store product, don't render this card — showing
    // backend/Stripe prices in the mobile paywall would be misleading.
    if (storeProduct == null) return const SizedBox.shrink();

    String displayPrice = '';
    String weeklyPrice = '';
    String? originalPrice;
    String? savings;
    String planBadge = '';

    final currencyFormat = NumberFormat.simpleCurrency(
      name: storeProduct.currencyCode,
    );

    if (isMonthly) {
      displayPrice = '${storeProduct.priceString}${'subscription.per_month'.tr()}';
      final weeklyNum = storeProduct.price / 4.33;
      weeklyPrice = 'subscription.per_week_billed_monthly'.tr(
        namedArgs: {'price': currencyFormat.format(weeklyNum)},
      );
      planBadge = 'subscription.flexible'.tr();
    } else if (isYearly) {
      displayPrice = '${storeProduct.priceString}${'subscription.per_year'.tr()}';
      final weeklyNum = storeProduct.price / 52;
      weeklyPrice = 'subscription.per_week_best_deal'.tr(
        namedArgs: {'price': currencyFormat.format(weeklyNum)},
      );
      // Only show savings when we have the actual monthly price from the store.
      final monthlyProduct = offerings?.current?.monthly?.storeProduct;
      if (monthlyProduct != null) {
        final monthlyAnnualized = monthlyProduct.price * 12;
        if (monthlyAnnualized > storeProduct.price) {
          final savingsPercent = ((monthlyAnnualized - storeProduct.price) / monthlyAnnualized * 100).round();
          originalPrice = currencyFormat.format(monthlyAnnualized);
          savings = 'subscription.save_percent'.tr(
            namedArgs: {'percent': savingsPercent.toString()},
          );
        }
      }
      planBadge = 'subscription.most_popular'.tr();
    } else if (isLifetime) {
      displayPrice = '${storeProduct.priceString} ${'subscription.once'.tr()}';
      weeklyPrice = 'subscription.pay_once_forever'.tr();
      planBadge = 'subscription.best_value'.tr();
    }

    return Obx(() {
      final isSelected = controller.selectedPlan.value == plan.id;

      return GestureDetector(
        onTap: () {
          final planIndex = profileController.plans.indexWhere((p) => p.id == plan.id);
          if (planIndex != -1) {
            profileController.selectPlan(planIndex);
          }
          controller.selectPlan(plan.id);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: showTrial ? 14 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isRecommended
                    ? const Color(0xFF1A1E24)
                    : bgCard,
                border: Border.all(
                  color: isRecommended
                      ? goldPrimary
                      : Colors.white.withValues(alpha: 0.06),
                  width: isRecommended ? 2 : 1,
                ),
                boxShadow: isRecommended
                    ? [
                        BoxShadow(
                          color: goldPrimary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name row with radio
                  Row(
                    children: [
                      // Radio button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? goldPrimary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? goldPrimary
                                : Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bgPrimary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Plan name
                      Text(
                        isMonthly ? 'subscription.monthly'.tr() : isYearly ? 'subscription.yearly'.tr() : 'subscription.lifetime'.tr(),
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Price row
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        Text(
                          displayPrice,
                          style: globalTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: goldPrimary,
                          ),
                        ),
                        if (originalPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 13,
                              color: textMuted,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: textMuted,
                            ),
                          ),
                        ],
                        if (savings != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: successGreen,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              savings,
                              style: globalTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Weekly price
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      weeklyPrice,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                      ),
                    ),
                  ),
                  // Trial banner for yearly
                  if (showTrial) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, color: successLight, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'subscription.free_trial_banner'.tr(namedArgs: {
                              'days': profileController.trialDays.value > 0
                                  ? profileController.trialDays.value.toString()
                                  : '14',
                            }),
                            style: globalTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: successLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Badge positioned at top right
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isRecommended
                      ? goldPrimary
                      : const Color(0xFF484E56),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: isRecommended
                          ? goldPrimary.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  planBadge,
                  style: globalTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRecommended ? bgPrimary : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Fallback plan card built directly from a RevenueCat Package when the
  /// backend doesn't have a matching plan entry.
  Widget _buildRcFallbackCard({
    required Package package,
    required String label,
    required String badge,
    required bool isRecommended,
    bool showTrial = false,
  }) {
    final product = package.storeProduct;
    final isYearly = package.identifier == profileController.rcOfferings.value?.current?.annual?.identifier;
    final isMonthly = package.identifier == profileController.rcOfferings.value?.current?.monthly?.identifier;

    final currencyFormat = NumberFormat.simpleCurrency(name: product.currencyCode);

    String displayPrice = '';
    String weeklyPrice = '';

    if (isMonthly) {
      displayPrice = '${product.priceString}${'subscription.per_month'.tr()}';
      final weeklyNum = product.price / 4.33;
      weeklyPrice = 'subscription.per_week_billed_monthly'.tr(
        namedArgs: {'price': currencyFormat.format(weeklyNum)},
      );
    } else if (isYearly) {
      displayPrice = '${product.priceString}${'subscription.per_year'.tr()}';
      final weeklyNum = product.price / 52;
      weeklyPrice = 'subscription.per_week_best_deal'.tr(
        namedArgs: {'price': currencyFormat.format(weeklyNum)},
      );
    } else {
      displayPrice = '${product.priceString} ${'subscription.once'.tr()}';
      weeklyPrice = 'subscription.pay_once_forever'.tr();
    }

    final packageId = package.identifier;

    return Obx(() {
      final isSelected = controller.selectedPlan.value == packageId;

      return GestureDetector(
        onTap: () {
          // Use the RC package identifier as the selection key
          profileController.selectedIndex.value = -1;
          controller.selectPlan(packageId);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: showTrial ? 14 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isRecommended ? const Color(0xFF1A1E24) : bgCard,
                border: Border.all(
                  color: isRecommended
                      ? goldPrimary
                      : Colors.white.withValues(alpha: 0.06),
                  width: isRecommended ? 2 : 1,
                ),
                boxShadow: isRecommended
                    ? [
                        BoxShadow(
                          color: goldPrimary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? goldPrimary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? goldPrimary
                                : Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bgPrimary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      displayPrice,
                      style: globalTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: goldPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      weeklyPrice,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                      ),
                    ),
                  ),
                  if (showTrial) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, color: successLight, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'subscription.free_trial_banner'.tr(namedArgs: {
                              'days': profileController.trialDays.value > 0
                                  ? profileController.trialDays.value.toString()
                                  : '14',
                            }),
                            style: globalTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: successLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isRecommended ? goldPrimary : const Color(0xFF484E56),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: isRecommended
                          ? goldPrimary.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: globalTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRecommended ? bgPrimary : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCTAButton() {
    return Obx(() {
      final selectedPlan = profileController.plans.firstWhereOrNull(
        (plan) => plan.id == controller.selectedPlan.value,
      );

      // Determine if the selection is a fallback RC package
      final selectedId = controller.selectedPlan.value;
      final offerings = profileController.rcOfferings.value;
      Package? fallbackPackage;
      if (selectedPlan == null && selectedId.isNotEmpty && offerings?.current != null) {
        for (final pkg in offerings!.current!.availablePackages) {
          if (pkg.identifier == selectedId) {
            fallbackPackage = pkg;
            break;
          }
        }
      }

      final isAnnualSelected = selectedPlan?.subscriptionType.toUpperCase() == 'YEARLY' ||
          (fallbackPackage != null && fallbackPackage.identifier == offerings?.current?.annual?.identifier);
      final isLifetimeSelected = selectedPlan?.subscriptionType.toUpperCase() == 'LIFETIME' ||
          (fallbackPackage != null && fallbackPackage.identifier == offerings?.current?.lifetime?.identifier);

      String buttonText = 'subscription.continue'.tr();
      if (isAnnualSelected && profileController.isTrialEligible.value) {
        buttonText = 'subscription.start_free_trial_days'.tr(namedArgs: {
          'days': profileController.trialDays.value > 0
              ? profileController.trialDays.value.toString()
              : '14',
        });
      } else if (isLifetimeSelected) {
        buttonText = 'subscription.get_lifetime_access'.tr();
      }

      return GestureDetector(
        onTap: controller.isButtonEnabled
            ? () async {
                if (selectedPlan != null) {
                  await profileController.handlePayment(selectedPlan);
                } else if (fallbackPackage != null) {
                  // Purchase directly via RevenueCat for fallback cards
                  profileController.isProcessing.value = true;
                  try {
                    final customerInfo = await RevenueCatService.instance.purchasePackage(fallbackPackage);
                    if (customerInfo != null &&
                        customerInfo.entitlements.active.containsKey('Zenslam Pro')) {
                      profileController.activeSubscription.value = true;
                      profileController.refreshProfile();
                      Get.offAll(() => NavBarScreen());
                    }
                  } catch (e) {
                    debugPrint('Fallback purchase error: $e');
                  } finally {
                    profileController.isProcessing.value = false;
                  }
                }
              }
            : null,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: controller.isButtonEnabled
                    ? LinearGradient(
                        colors: [goldPrimary, goldLight, goldPrimary],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : null,
                color: controller.isButtonEnabled ? null : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(14),
                boxShadow: controller.isButtonEnabled
                    ? [
                        BoxShadow(
                          color: goldPrimary.withValues(alpha: 0.3 + (_pulseController.value * 0.25)),
                          blurRadius: 20 + (_pulseController.value * 10),
                          spreadRadius: _pulseController.value * 2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  if (controller.isButtonEnabled)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Transform.translate(
                          offset: Offset(
                            (_shimmerController.value * 2 - 0.5) * 400,
                            0,
                          ),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      buttonText,
                      style: globalTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: controller.isButtonEnabled ? bgPrimary : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, color: textMuted, size: 11),
        const SizedBox(width: 4),
        Text(
          'subscription.secure'.tr(),
          style: globalTextStyle(fontSize: 10, color: textMuted),
        ),
        Text('  \u2022  ', style: globalTextStyle(fontSize: 10, color: textMuted)),
        Text(
          'subscription.cancel_anytime'.tr(),
          style: globalTextStyle(fontSize: 10, color: textMuted),
        ),
        Text('  \u2022  ', style: globalTextStyle(fontSize: 10, color: textMuted)),
        GestureDetector(
          onTap: () => _openTermsOfService(),
          child: Text(
            'subscription.terms'.tr(),
            style: globalTextStyle(fontSize: 10, color: textMuted),
          ),
        ),
        Text('  \u2022  ', style: globalTextStyle(fontSize: 10, color: textMuted)),
        GestureDetector(
          onTap: () => _restorePurchases(),
          child: Text(
            'subscription.restore'.tr(),
            style: globalTextStyle(fontSize: 10, color: textMuted),
          ),
        ),
      ],
    );
  }

  void _openTermsOfService() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'subscription.terms_of_service'.tr(),
              style: globalTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '''Terms of Service for Zenslam

Last updated: January 2025

1. Acceptance of Terms
By accessing or using Zenslam, you agree to be bound by these Terms of Service.

2. Subscription Terms
- Monthly subscriptions renew automatically unless cancelled
- Yearly subscriptions include a 14-day free trial for new users
- Lifetime access is a one-time purchase with no recurring charges

3. Cancellation Policy
- You may cancel your subscription at any time
- Cancellation takes effect at the end of the current billing period
- No refunds for partial billing periods

4. Content Usage
- All content is for personal, non-commercial use only
- Downloading is permitted for offline personal use
- Redistribution of content is prohibited

5. Privacy
Your privacy is important to us. Please review our Privacy Policy for details on how we collect and use your information.

6. Contact
For questions about these terms, contact support@zenslam.com''',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    lineHeight: 1.6,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldPrimary,
                      foregroundColor: bgPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'subscription.close'.tr(),
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: bgPrimary,
                      ),
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

  void _restorePurchases() async {
    // Show loading indicator
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: goldPrimary),
                const SizedBox(height: 16),
                Text(
                  'subscription.restoring_purchases'.tr(),
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final customerInfo = await RevenueCatService.instance.restorePurchases();

      Get.back(); // Close loading dialog

      final isPremium = customerInfo?.entitlements.active.containsKey('Zenslam Pro') ?? false;

      if (isPremium) {
        profileController.activeSubscription.value = true;
        Get.snackbar(
          'subscription.success'.tr(),
          'subscription.subscription_restored'.tr(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
        // Navigate to home after successful restore
        Get.offAll(() => NavBarScreen());
      } else {
        Get.snackbar(
          'subscription.no_purchases_found'.tr(),
          'subscription.no_active_subscriptions'.tr(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: bgCard,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'subscription.error'.tr(),
        'subscription.restore_error'.tr(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildTestimonial() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'subscription.testimonial_text'.tr(),
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [goldDark, goldPrimary]),
                ),
                child: Center(
                  child: Text(
                    'JM',
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: bgPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'subscription.testimonial_author'.tr(),
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'subscription.testimonial_info'.tr(),
                    style: globalTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
