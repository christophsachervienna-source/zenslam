import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sound picker for ambient meditation sounds
class SoundPicker extends StatelessWidget {
  const SoundPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 18,
                    color: QuestionnaireTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ambient Sound',
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
                onTap: () => _showSoundPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: QuestionnaireTheme.cardBackground,
                    border: Border.all(
                      color:
                          QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
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

        // Sound options row
        _buildSoundRow(),
      ],
    );
  }

  Widget _buildSoundRow() {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      if (controller.isLoadingSounds.isTrue) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: QuestionnaireTheme.accentGold,
              ),
            ),
          ),
        );
      }

      final selectedSound = controller.selectedSound.value;
      final displaySounds = controller.ambientSounds.take(4).toList();

      return Row(
        children: displaySounds.map((sound) {
          final isSelected = sound.id == selectedSound.id;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SoundChip(
                sound: sound,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectSound(sound);
                },
                onLongPress: () {
                  if (sound.id != 'silence') {
                    HapticFeedback.lightImpact();
                    controller.previewSound(sound);
                  }
                },
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _showSoundPicker(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _SoundPickerSheet(),
    );
  }
}

/// Sound option chip
class _SoundChip extends StatelessWidget {
  final AmbientSound sound;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SoundChip({
    required this.sound,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sound.icon,
              size: 24,
              color: isSelected
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              sound.name,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? QuestionnaireTheme.accentGold
                    : QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full sound picker bottom sheet with volume control
class _SoundPickerSheet extends StatelessWidget {
  const _SoundPickerSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: QuestionnaireTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                    'Ambient Sounds',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.stopPreview();
                      Navigator.pop(context);
                    },
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

            // Scrollable sound list + volume
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Sound options
                  Obx(() {
                    if (controller.isLoadingSounds.isTrue) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: QuestionnaireTheme.accentGold,
                          ),
                        ),
                      );
                    }

                    final selectedSound = controller.selectedSound.value;

                    return Column(
                      children: controller.ambientSounds.map((sound) {
                        final isSelected = sound.id == selectedSound.id;

                        return _SoundListTile(
                          sound: sound,
                          isSelected: isSelected,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.selectSound(sound);
                          },
                          onPreview: () {
                            if (sound.id != 'silence') {
                              HapticFeedback.lightImpact();
                              controller.previewSound(sound);
                            }
                          },
                        );
                      }).toList(),
                    );
                  }),

                  // Volume control
                  Obx(() {
                    final selectedSound = controller.selectedSound.value;
                    final volume = controller.ambientVolume.value;

                    if (selectedSound.id == 'silence') {
                      return const SizedBox(height: 20);
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Volume',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: QuestionnaireTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${(volume * 100).round()}%',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: QuestionnaireTheme.accentGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: QuestionnaireTheme.accentGold,
                              inactiveTrackColor:
                                  QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                              thumbColor: QuestionnaireTheme.accentGold,
                              overlayColor:
                                  QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: volume,
                              onChanged: (value) {
                                controller.setAmbientVolume(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sound option list tile
class _SoundListTile extends StatelessWidget {
  final AmbientSound sound;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  const _SoundListTile({
    required this.sound,
    required this.isSelected,
    required this.onTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                sound.icon,
                size: 24,
                color: isSelected
                    ? QuestionnaireTheme.accentGold
                    : QuestionnaireTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(
                sound.name,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? QuestionnaireTheme.textPrimary
                      : QuestionnaireTheme.textSecondary,
                ),
              ),
            ),

            // Preview button
            if (sound.id != 'silence')
              GestureDetector(
                onTap: onPreview,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuestionnaireTheme.cardBackground,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ),

            // Selected indicator
            if (isSelected) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.check_circle,
                size: 24,
                color: QuestionnaireTheme.accentGold,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
