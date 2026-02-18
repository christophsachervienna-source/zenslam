import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Duration picker with quick presets and custom wheel picker
class DurationPicker extends StatelessWidget {
  const DurationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      final selectedDuration = controller.duration.value;
      final isRunning = controller.isRunning.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: QuestionnaireTheme.accentGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: QuestionnaireTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick presets
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MeditationTimerController.durationPresets.length + 1,
              itemBuilder: (context, index) {
                // Last item is custom picker
                if (index ==
                    MeditationTimerController.durationPresets.length) {
                  return _CustomDurationButton(
                    isSelected: !MeditationTimerController.durationPresets
                        .contains(selectedDuration),
                    currentDuration: selectedDuration,
                    isDisabled: isRunning,
                  );
                }

                final duration =
                    MeditationTimerController.durationPresets[index];
                final isSelected = duration == selectedDuration;

                return Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: _DurationChip(
                    duration: duration,
                    isSelected: isSelected,
                    isDisabled: isRunning,
                    onTap: () {
                      if (!isRunning) {
                        HapticFeedback.selectionClick();
                        controller.setDuration(duration);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

/// Duration preset chip
class _DurationChip extends StatelessWidget {
  final int duration;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _DurationChip({
    required this.duration,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          '$duration min',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? QuestionnaireTheme.accentGold
                : isDisabled
                    ? QuestionnaireTheme.textTertiary
                    : QuestionnaireTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Custom duration button that opens wheel picker
class _CustomDurationButton extends StatelessWidget {
  final bool isSelected;
  final int currentDuration;
  final bool isDisabled;

  const _CustomDurationButton({
    required this.isSelected,
    required this.currentDuration,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () => _showDurationPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
              : QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: isSelected
                ? QuestionnaireTheme.accentGold
                : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: isSelected
                  ? QuestionnaireTheme.accentGold
                  : isDisabled
                      ? QuestionnaireTheme.textTertiary
                      : QuestionnaireTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              isSelected ? '$currentDuration min' : 'Custom',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? QuestionnaireTheme.accentGold
                    : isDisabled
                        ? QuestionnaireTheme.textTertiary
                        : QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _DurationPickerSheet(),
    );
  }
}

/// Bottom sheet with wheel picker for custom duration
class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet();

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late FixedExtentScrollController _scrollController;
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MeditationTimerController>();
    _selectedMinutes = controller.duration.value;
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedMinutes - 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Custom Duration',
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

            // Wheel picker
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Selection highlight
                  Center(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                        border: Border.all(
                          color: QuestionnaireTheme.accentGold
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),

                  // Wheel
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedMinutes = index + 1;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) {
                        final minutes = index + 1;
                        final isSelected = minutes == _selectedMinutes;

                        return Center(
                          child: Text(
                            '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
                            style: GoogleFonts.dmSans(
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? QuestionnaireTheme.accentGold
                                  : QuestionnaireTheme.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  final controller = Get.find<MeditationTimerController>();
                  controller.setDuration(_selectedMinutes);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: QuestionnaireTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color:
                            QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Set Duration',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.backgroundPrimary,
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
}
