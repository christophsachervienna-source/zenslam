import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Breathing pattern picker widget
class BreathingPatternPicker extends StatelessWidget {
  const BreathingPatternPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with More button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.air,
                    size: 18,
                    color: QuestionnaireTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Breathing Pattern',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showMorePatterns(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: QuestionnaireTheme.cardBackground,
                    border: Border.all(
                      color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: QuestionnaireTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pattern options
        _buildPatternGrid(),
      ],
    );
  }

  void _showMorePatterns(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _ExtendedPatternSheet(),
    );
  }

  Widget _buildPatternGrid() {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      final selectedPattern = controller.selectedPattern.value;
      final isRunning = controller.isRunning.value;

      // Check if selected pattern is from extended list
      final isExtendedSelected = MeditationTimerController.extendedBreathingPatterns
          .any((p) => p.id == selectedPattern.id);

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          // Main patterns
          ...MeditationTimerController.breathingPatterns.map((pattern) {
            final isSelected = pattern.id == selectedPattern.id;

            return _PatternChip(
              pattern: pattern,
              isSelected: isSelected,
              isDisabled: isRunning,
              onTap: () {
                if (!isRunning) {
                  HapticFeedback.selectionClick();
                  controller.selectPattern(pattern);
                }
              },
            );
          }),
          // Show selected extended pattern if one is selected
          if (isExtendedSelected)
            _PatternChip(
              pattern: selectedPattern,
              isSelected: true,
              isDisabled: isRunning,
              onTap: () {
                if (!isRunning) {
                  HapticFeedback.selectionClick();
                  _showMorePatterns(Get.context!);
                }
              },
            ),
        ],
      );
    });
  }
}

/// Extended patterns bottom sheet
class _ExtendedPatternSheet extends StatelessWidget {
  const _ExtendedPatternSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Container(
      decoration: const BoxDecoration(
        color: QuestionnaireTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: QuestionnaireTheme.borderDefault,
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'More Patterns',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: QuestionnaireTheme.backgroundSecondary,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Extended pattern options
            Obx(() {
              final selectedPattern = controller.selectedPattern.value;

              return Column(
                children: MeditationTimerController.extendedBreathingPatterns
                    .map((pattern) {
                  final isSelected = pattern.id == selectedPattern.id;

                  return _PatternListTile(
                    pattern: pattern,
                    isSelected: isSelected,
                    isDisabled: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectPattern(pattern);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Pattern option chip
class _PatternChip extends StatelessWidget {
  final BreathingPattern pattern;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PatternChip({
    required this.pattern,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
              : QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: isSelected
                ? QuestionnaireTheme.accentGold
                : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPatternIcon(pattern.id),
                  size: 16,
                  color: isSelected
                      ? QuestionnaireTheme.accentGold
                      : isDisabled
                          ? QuestionnaireTheme.textTertiary
                          : QuestionnaireTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  pattern.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? QuestionnaireTheme.accentGold
                        : isDisabled
                            ? QuestionnaireTheme.textTertiary
                            : QuestionnaireTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              pattern.description,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? QuestionnaireTheme.accentGold.withValues(alpha: 0.8)
                    : QuestionnaireTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPatternIcon(String patternId) {
    switch (patternId) {
      case 'box':
        return Icons.crop_square;
      case '478':
        return Icons.auto_awesome;
      case 'relaxing':
        return Icons.spa;
      case 'none':
        return Icons.timer_outlined;
      case 'coherent':
        return Icons.favorite_outline;
      case 'resonant':
        return Icons.waves;
      case 'extended_box':
        return Icons.square_outlined;
      case 'deep_calm':
        return Icons.self_improvement;
      case 'triangle':
        return Icons.change_history;
      case 'physiological_sigh':
        return Icons.air;
      case 'ocean_breath':
        return Icons.water;
      default:
        return Icons.air;
    }
  }
}

/// Compact pattern picker shown at bottom of screen
class CompactBreathingPatternPicker extends StatelessWidget {
  const CompactBreathingPatternPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      final selectedPattern = controller.selectedPattern.value;

      return GestureDetector(
        onTap: () => _showPatternPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: QuestionnaireTheme.cardBackground,
            border: Border.all(
              color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.air,
                size: 16,
                color: QuestionnaireTheme.accentGold,
              ),
              const SizedBox(width: 8),
              Text(
                selectedPattern.name,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: QuestionnaireTheme.textSecondary,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showPatternPicker(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _PatternPickerSheet(),
    );
  }
}

/// Full pattern picker bottom sheet
class _PatternPickerSheet extends StatelessWidget {
  const _PatternPickerSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Container(
      decoration: const BoxDecoration(
        color: QuestionnaireTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: QuestionnaireTheme.borderDefault,
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Breathing Pattern',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: QuestionnaireTheme.backgroundSecondary,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pattern options
            Obx(() {
              final selectedPattern = controller.selectedPattern.value;
              final isRunning = controller.isRunning.value;

              return Column(
                children:
                    MeditationTimerController.breathingPatterns.map((pattern) {
                  final isSelected = pattern.id == selectedPattern.id;

                  return _PatternListTile(
                    pattern: pattern,
                    isSelected: isSelected,
                    isDisabled: isRunning,
                    onTap: () {
                      if (!isRunning) {
                        HapticFeedback.selectionClick();
                        controller.selectPattern(pattern);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Pattern option list tile
class _PatternListTile extends StatelessWidget {
  final BreathingPattern pattern;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PatternListTile({
    required this.pattern,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.1)
              : QuestionnaireTheme.backgroundSecondary,
          border: Border.all(
            color: isSelected
                ? QuestionnaireTheme.accentGold.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? QuestionnaireTheme.accentGold.withValues(alpha: 0.2)
                    : QuestionnaireTheme.cardBackground,
              ),
              child: Icon(
                _getPatternIcon(pattern.id),
                size: 24,
                color: isSelected
                    ? QuestionnaireTheme.accentGold
                    : isDisabled
                        ? QuestionnaireTheme.textTertiary
                        : QuestionnaireTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),

            // Name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? QuestionnaireTheme.textPrimary
                          : isDisabled
                              ? QuestionnaireTheme.textTertiary
                              : QuestionnaireTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pattern.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: QuestionnaireTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24,
                color: QuestionnaireTheme.accentGold,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPatternIcon(String patternId) {
    switch (patternId) {
      case 'box':
        return Icons.crop_square;
      case '478':
        return Icons.auto_awesome;
      case 'relaxing':
        return Icons.spa;
      case 'none':
        return Icons.timer_outlined;
      case 'coherent':
        return Icons.favorite_outline;
      case 'resonant':
        return Icons.waves;
      case 'extended_box':
        return Icons.square_outlined;
      case 'deep_calm':
        return Icons.self_improvement;
      case 'triangle':
        return Icons.change_history;
      case 'physiological_sigh':
        return Icons.air;
      case 'ocean_breath':
        return Icons.water;
      default:
        return Icons.air;
    }
  }
}
