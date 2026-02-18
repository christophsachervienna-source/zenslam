import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/profile_flow/controller/onboarding_preference_helper.dart';
import 'package:zenslam/app/profile_flow/controller/select_goal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/questionnaire_scaffold.dart';
import '../../widgets/premium_selection_card.dart';
import 'brand_showcase_screen.dart';

/// Redesigned goals selection screen
/// Final question (4) of onboarding questionnaire
class GoalsScreen extends StatelessWidget {
  GoalsScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;
  final SelectGoalController controller = Get.put(SelectGoalController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && isFromPreference && result != true) {
          controller.resetToInitial();
        }
      },
      child: Obx(() {
        final selectedGoals = controller.goalModel.value.selectedGoals;
        final hasSelection = selectedGoals.isNotEmpty;

        return QuestionnaireScaffold(
          currentStep: 4,
          totalSteps: 4,
          title: "What are your\ntop goals?",
          subtitle: "We'll curate content that helps you achieve them",
          buttonTitle: isFromPreference ? 'Save Changes' : 'Complete Setup',
          onContinue: hasSelection
              ? () async {
                  if (isFromPreference) {
                    Get.back(result: true);
                  } else {
                    // Save all preferences
                    await OnboardingPreferenceHelper.saveAllPreferences();
                    await SharedPrefHelper.saveIsOnboardingCompleted(true);

                    // Navigate to brand showcase
                    Get.to(
                      () => const BrandShowcaseScreen(),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                  }
                }
              : null,
          onBack: () => Get.back(),
          showBackButton: true,
          isLoading: controller.isLoading.value,
          content: _buildContent(),
        );
      }),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: QuestionnaireTheme.accentGold,
            strokeWidth: 2,
          ),
        );
      }

      if (controller.availableWants.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 48,
                color: QuestionnaireTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No goals available',
                style: QuestionnaireTheme.bodyLarge(
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection counter with animation
          Obx(() {
            final count = controller.goalModel.value.selectedGoals.length;
            return AnimatedContainer(
              duration: QuestionnaireTheme.animationMedium,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: count > 0
                    ? QuestionnaireTheme.accentGold.withValues(alpha: 0.12)
                    : QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
                border: Border.all(
                  color: count > 0
                      ? QuestionnaireTheme.accentGold.withValues(alpha: 0.3)
                      : QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: QuestionnaireTheme.animationFast,
                    child: Icon(
                      count > 0
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                      key: ValueKey(count > 0),
                      size: 16,
                      color: count > 0
                          ? QuestionnaireTheme.accentGold
                          : QuestionnaireTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: QuestionnaireTheme.animationFast,
                    child: Text(
                      count > 0 ? '$count selected' : 'Select your goals',
                      key: ValueKey(count),
                      style: QuestionnaireTheme.bodySmall(
                        color: count > 0
                            ? QuestionnaireTheme.accentGold
                            : QuestionnaireTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Goals list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.availableWants.length,
              itemBuilder: (context, index) {
                final goal = controller.availableWants[index];
                return Obx(() {
                  final isSelected = controller.isSelected(goal.name);
                  return PremiumSelectionCard(
                    title: goal.name,
                    emoji: goal.image.isNotEmpty ? goal.image : null,
                    isSelected: isSelected,
                    allowMultiple: true,
                    onTap: () => controller.toggleGoal(goal.name, goal.image),
                    index: index,
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }
}
