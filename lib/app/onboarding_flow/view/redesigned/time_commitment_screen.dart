import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/select_time_controller.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/questionnaire_scaffold.dart';
import '../../widgets/premium_selection_card.dart';
import 'priorities_screen.dart';

/// Redesigned time commitment selection screen
/// Question 1 of onboarding questionnaire
class TimeCommitmentScreen extends StatelessWidget {
  TimeCommitmentScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;
  final SelectTimeController controller = Get.put(SelectTimeController());

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
        final selectedTimes = controller.timeModel.value.selectedTimes;
        final hasSelection = selectedTimes.isNotEmpty;

        return QuestionnaireScaffold(
          currentStep: 1,
          totalSteps: 4,
          title: "How much time\ncan you commit?",
          subtitle: "We'll personalize your daily practice accordingly",
          buttonTitle: isFromPreference ? 'Done' : 'Continue',
          onContinue: hasSelection
              ? () {
                  if (isFromPreference) {
                    Get.back(result: true);
                  } else {
                    Get.to(
                      () => PrioritiesScreen(),
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

      if (controller.availableTimes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: QuestionnaireTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No time options available',
                style: QuestionnaireTheme.bodyLarge(
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.availableTimes.length,
        itemBuilder: (context, index) {
          final time = controller.availableTimes[index];
          return Obx(() {
            final isSelected = controller.isSelected(time.name);
            return PremiumSelectionCard(
              title: time.name,
              emoji: time.image.isNotEmpty ? time.image : null,
              isSelected: isSelected,
              allowMultiple: false, // Single selection for time
              onTap: () => controller.toggleTime(time.name),
              index: index,
            );
          });
        },
      );
    });
  }
}
