import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumPlan extends StatelessWidget {
  PremiumPlan({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Premium header
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
                    'subscription.premium_plan'.tr(),
                    style: QuestionnaireTheme.headline(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  );
                }

                if (controller.plans.isEmpty) {
                  return _buildEmptyState();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.15),
                              AppColors.primaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'subscription.unlock_premium'.tr(),
                                    style: QuestionnaireTheme.titleLarge(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'subscription.get_unlimited_access'.tr(),
                                    style: QuestionnaireTheme.bodySmall(
                                      color: QuestionnaireTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'subscription.select_your_plan'.tr(),
                        style: QuestionnaireTheme.titleMedium(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: controller.plans.length,
                          itemBuilder: (context, index) {
                            final plan = controller.plans[index];

                            return Obx(() {
                              final isSelected =
                                  controller.selectedIndex.value == index;
                              final isActive = plan.purchaseSubscriptions.any(
                                (sub) => sub.isActive,
                              );

                              return _buildPlanCard(
                                planName: plan.planName,
                                price: plan.price,
                                subscriptionType: plan.subscriptionType,
                                badge: plan.badge,
                                savings: plan.savings?.toInt(),
                                isSelected: isSelected,
                                isActive: isActive,
                                onTap: () {
                                  debugPrint(
                                    'Tapping plan at index: $index - ${plan.planName}',
                                  );
                                  controller.selectPlan(index);
                                },
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildUpgradeButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: QuestionnaireTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'subscription.no_plans_available'.tr(),
            style: QuestionnaireTheme.titleMedium(),
          ),
          const SizedBox(height: 8),
          Text(
            'subscription.please_try_later'.tr(),
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Get the locale-aware price string from RevenueCat for the given plan type,
  /// falling back to a formatted price from the backend.
  String _getDisplayPrice(double price, String subscriptionType) {
    final offerings = controller.rcOfferings.value;
    final type = subscriptionType.toUpperCase();
    StoreProduct? storeProduct;

    if (offerings?.current != null) {
      if (type == 'MONTHLY') {
        storeProduct = offerings!.current!.monthly?.storeProduct;
      } else if (type == 'YEARLY') {
        storeProduct = offerings!.current!.annual?.storeProduct;
      } else if (type == 'LIFETIME') {
        storeProduct = offerings!.current!.lifetime?.storeProduct;
      }
    }

    // Fallback to directly-fetched products on Android
    storeProduct ??= type == 'MONTHLY'
        ? controller.fallbackMonthlyProduct.value
        : type == 'YEARLY'
            ? controller.fallbackAnnualProduct.value
            : null;

    if (storeProduct != null) {
      return storeProduct.priceString;
    }
    return NumberFormat.simpleCurrency(name: 'USD').format(price);
  }

  Widget _buildPlanCard({
    required String planName,
    required double price,
    required String subscriptionType,
    String? badge,
    int? savings,
    required bool isSelected,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.15),
                    AppColors.primaryColor.withValues(alpha: 0.05),
                  ],
                )
              : QuestionnaireTheme.cardGradient(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : QuestionnaireTheme.borderDefault,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      planName,
                      style: QuestionnaireTheme.titleLarge(),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'subscription.active'.tr(),
                              style: QuestionnaireTheme.bodySmall(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : QuestionnaireTheme.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.black,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getDisplayPrice(price, subscriptionType),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '/ $subscriptionType',
                    style: QuestionnaireTheme.bodyMedium(
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (badge != null || savings != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: QuestionnaireTheme.bodySmall(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (savings != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      'subscription.save_percent'.tr(namedArgs: {'percent': savings.toString()}),
                      style: QuestionnaireTheme.bodyMedium(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Obx(() {
      final hasActiveSub = controller.activeSubscription.value;
      final isProcessing = controller.isProcessing.value;
      final isEnabled = !isProcessing && !hasActiveSub;

      return GestureDetector(
        onTap: isEnabled
            ? () async {
                final selected = controller.selectedIndex.value;
                if (selected == -1) {
                  Get.snackbar(
                    'subscription.select_plan'.tr(),
                    'subscription.choose_plan_first'.tr(),
                    backgroundColor: QuestionnaireTheme.cardBackground,
                    colorText: Colors.white,
                  );
                  return;
                }
                final plan = controller.plans[selected];
                await controller.handlePayment(plan);
              }
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.85),
                    ]
                  : [
                      QuestionnaireTheme.textTertiary.withValues(alpha: 0.3),
                      QuestionnaireTheme.textTertiary.withValues(alpha: 0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isProcessing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : Text(
                    hasActiveSub ? 'subscription.plan_active'.tr() : 'subscription.upgrade_plan'.tr(),
                    style: QuestionnaireTheme.titleMedium(
                      color: isEnabled
                          ? Colors.black
                          : QuestionnaireTheme.textTertiary,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
