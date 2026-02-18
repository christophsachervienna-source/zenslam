import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/selected_controller.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/questionnaire_scaffold.dart';
import '../../widgets/premium_selection_card.dart';
import 'name_entry_screen.dart';

/// Redesigned priorities selection screen
/// Question 2 of onboarding questionnaire
class PrioritiesScreen extends StatelessWidget {
  PrioritiesScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;
  final SelectedController controller = Get.put(SelectedController());

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
        final selectedItems = controller.importantModel.value.selectedImportants;
        final hasSelection = selectedItems.isNotEmpty;

        return QuestionnaireScaffold(
          currentStep: 2,
          totalSteps: 4,
          title: "What matters most\nto you right now?",
          subtitle: "Select all that resonate with your current journey",
          buttonTitle: isFromPreference ? 'Done' : 'Continue',
          onContinue: hasSelection
              ? () {
                  if (isFromPreference) {
                    Get.back(result: true);
                  } else {
                    Get.to(
                      () => const NameEntryScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 350),
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

      if (controller.availableMatters.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 48,
                color: QuestionnaireTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No options available',
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
          // Selection hint
          Obx(() {
            final count =
                controller.importantModel.value.selectedImportants.length;
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
                  Icon(
                    count > 0
                        ? Icons.check_circle_rounded
                        : Icons.touch_app_rounded,
                    size: 16,
                    color: count > 0
                        ? QuestionnaireTheme.accentGold
                        : QuestionnaireTheme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count > 0 ? '$count selected' : 'Select multiple',
                    style: QuestionnaireTheme.bodySmall(
                      color: count > 0
                          ? QuestionnaireTheme.accentGold
                          : QuestionnaireTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Options list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.availableMatters.length,
              itemBuilder: (context, index) {
                final matter = controller.availableMatters[index];
                return Obx(() {
                  final isSelected = controller.isSelected(matter.name);
                  return PremiumSelectionCard(
                    title: matter.name,
                    emoji: matter.image.isNotEmpty ? matter.image : null,
                    isSelected: isSelected,
                    allowMultiple: true,
                    onTap: () =>
                        controller.toggleImportant(matter.name, matter.image),
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
