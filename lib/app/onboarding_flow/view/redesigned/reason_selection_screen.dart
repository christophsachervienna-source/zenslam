import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zenslam/app/profile_flow/controller/select_reason_controller.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_selection_card.dart';
import 'time_commitment_screen.dart';

/// Redesigned reason selection screen
/// First question in the premium onboarding flow
class ReasonSelectionScreen extends StatelessWidget {
  const ReasonSelectionScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;

  @override
  Widget build(BuildContext context) {
    final SelectReasonController controller = Get.put(SelectReasonController());

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && isFromPreference && result != true) {
          controller.resetToInitial();
        }
      },
      child: Obx(() {
        final selectedReasons = controller.reasonModel.value.selectedReasons;
        final hasSelection = selectedReasons.isNotEmpty;

        return _ReasonSelectionContent(
          controller: controller,
          hasSelection: hasSelection,
          isFromPreference: isFromPreference,
        );
      }),
    );
  }
}

class _ReasonSelectionContent extends StatelessWidget {
  final SelectReasonController controller;
  final bool hasSelection;
  final bool isFromPreference;

  const _ReasonSelectionContent({
    required this.controller,
    required this.hasSelection,
    required this.isFromPreference,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with welcome message
                _buildHeader(),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QuestionnaireTheme.paddingHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          "Why are you here?",
                          style: QuestionnaireTheme.displayMedium(),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          "Select all that apply to personalize your journey",
                          style: QuestionnaireTheme.bodyLarge(
                            color: QuestionnaireTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Selection counter
                        _buildSelectionCounter(),

                        const SizedBox(height: 16),

                        // Options list
                        Expanded(child: _buildContent()),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                _buildBottomArea(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal,
        16,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Welcome badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.12),
              border: Border.all(
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.waving_hand_rounded,
                  size: 16,
                  color: QuestionnaireTheme.accentGold,
                ),
                const SizedBox(width: 8),
                Text(
                  "Let's begin",
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),

          // Step indicator
          Text(
            'STEP 1 OF 5',
            style: QuestionnaireTheme.caption(
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCounter() {
    return Obx(() {
      final count = controller.reasonModel.value.selectedReasons.length;
      return AnimatedContainer(
        duration: QuestionnaireTheme.animationMedium,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              count > 0 ? Icons.check_circle_rounded : Icons.touch_app_rounded,
              size: 16,
              color: count > 0
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              count > 0 ? '$count selected' : 'Select your reasons',
              style: QuestionnaireTheme.bodySmall(
                color: count > 0
                    ? QuestionnaireTheme.accentGold
                    : QuestionnaireTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    });
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

      if (controller.availableReasons.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 48,
                color: QuestionnaireTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No reasons available',
                style: QuestionnaireTheme.bodyLarge(
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.availableReasons.length,
        itemBuilder: (context, index) {
          final reason = controller.availableReasons[index];
          return Obx(() {
            final isSelected = controller.isSelected(reason.name);
            return PremiumSelectionCard(
              title: reason.name,
              emoji: reason.image.isNotEmpty ? reason.image : null,
              isSelected: isSelected,
              allowMultiple: true,
              onTap: () => controller.toggleReason(reason.name, reason.image),
              index: index,
            );
          });
        },
      );
    });
  }

  Widget _buildBottomArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal,
        16,
        QuestionnaireTheme.paddingHorizontal,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.8),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: _PremiumContinueButton(
        title: isFromPreference ? 'Done' : 'Continue',
        isEnabled: hasSelection,
        onTap: () {
          HapticFeedback.lightImpact();
          if (isFromPreference) {
            Get.back(result: true);
          } else {
            Get.to(
              () => TimeCommitmentScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 350),
            );
          }
        },
      ),
    );
  }
}

/// Premium button matching the questionnaire style
class _PremiumContinueButton extends StatefulWidget {
  final String title;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PremiumContinueButton({
    required this.title,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_PremiumContinueButton> createState() => _PremiumContinueButtonState();
}

class _PremiumContinueButtonState extends State<_PremiumContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (widget.isEnabled) _pressController.forward();
            },
            onTapUp: (_) => _pressController.reverse(),
            onTapCancel: () => _pressController.reverse(),
            onTap: widget.isEnabled ? widget.onTap : null,
            child: AnimatedContainer(
              duration: QuestionnaireTheme.animationMedium,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: widget.isEnabled
                    ? QuestionnaireTheme.accentGradient
                    : LinearGradient(
                        colors: [
                          QuestionnaireTheme.borderDefault,
                          QuestionnaireTheme.borderDefault.withValues(alpha: 0.8),
                        ],
                      ),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: QuestionnaireTheme.accentGold.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Shine overlay
                  if (widget.isEnabled)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Button content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: QuestionnaireTheme.label(
                            color: widget.isEnabled
                                ? QuestionnaireTheme.backgroundPrimary
                                : QuestionnaireTheme.textTertiary,
                          ),
                        ),
                        if (widget.isEnabled) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: QuestionnaireTheme.backgroundPrimary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
