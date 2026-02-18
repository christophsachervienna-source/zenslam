import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/profile_flow/controller/select_reason_controller.dart';
import 'package:zenslam/app/onboarding_flow/view/redesigned/time_commitment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class SelectReasonScreen extends StatelessWidget {
  SelectReasonScreen({super.key, this.isFromPreference = false});
  final bool isFromPreference;

  SelectReasonController controller = Get.put(SelectReasonController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && isFromPreference && result != true) {
          debugPrint('Back button pressed, resetting to initial selections');
          controller.resetToInitial();
        }
      },
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(
                      child: Text(
                        isFromPreference ? 'Update Reasons' : 'Your Reasons',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ),
                  ],
                ),
              ),

              // Title section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's your main reason for being here?",
                      style: QuestionnaireTheme.titleLarge(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select your reasons",
                      style: QuestionnaireTheme.bodyMedium(
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // List of reasons
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

                  if (controller.availableReasons.isEmpty) {
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
                            'No reasons available',
                            style: QuestionnaireTheme.titleMedium(),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.availableReasons.length,
                    itemBuilder: (context, index) {
                      final reason = controller.availableReasons[index];
                      return Obx(() {
                        final isSelected = controller.isSelected(reason.name);
                        return _buildOptionCard(
                          name: reason.name,
                          image: reason.image,
                          isSelected: isSelected,
                          onTap: () => controller.toggleReason(
                            reason.name,
                            reason.image,
                          ),
                        );
                      });
                    },
                  );
                }),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final selected = controller.reasonModel.value.selectedReasons;
                  final isEnabled = selected.isNotEmpty;
                  return _buildPremiumButton(
                    title: isFromPreference ? 'Done' : 'Next',
                    isEnabled: isEnabled,
                    onTap: isEnabled
                        ? () {
                            if (isFromPreference) {
                              Get.back(result: true);
                            } else {
                              Get.to(
                                () => TimeCommitmentScreen(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 350),
                              );
                            }
                          }
                        : null,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String name,
    required String image,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : QuestionnaireTheme.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Image/emoji
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : QuestionnaireTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: (image.startsWith('http') || image.startsWith('https'))
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image,
                          height: 28,
                          width: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 24,
                              color: QuestionnaireTheme.textTertiary,
                            );
                          },
                        ),
                      )
                    : Text(
                        image,
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: QuestionnaireTheme.titleMedium(
                  color: isSelected
                      ? QuestionnaireTheme.textPrimary
                      : QuestionnaireTheme.textSecondary,
                ),
              ),
            ),
            // Custom checkbox
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
      ),
    );
  }

  Widget _buildPremiumButton({
    required String title,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          child: Text(
            title,
            style: QuestionnaireTheme.titleMedium(
              color: isEnabled ? Colors.black : QuestionnaireTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
