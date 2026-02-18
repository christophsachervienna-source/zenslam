import 'dart:convert';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'naming_screen.dart';

/// Screen 4: "The Identity" (NEW)
/// Purpose: Create deep investment, gather preferences
/// Visual: Dark, focused, elegant sliders
/// Copy: "Help us understand you"
class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Slider values (0.0 to 1.0)
  double _rechargeValue = 0.5;
  double _thinkActValue = 0.5;
  double _structureValue = 0.5;
  double _logicInstinctValue = 0.5;

  final List<PersonalitySlider> _sliders = [
    PersonalitySlider(
      id: 'recharge',
      leftLabel: 'Alone',
      rightLabel: 'With Others',
      leftIcon: Icons.person_outline_rounded,
      rightIcon: Icons.groups_outlined,
    ),
    PersonalitySlider(
      id: 'think_act',
      leftLabel: 'Think First',
      rightLabel: 'Act First',
      leftIcon: Icons.psychology_outlined,
      rightIcon: Icons.bolt_rounded,
    ),
    PersonalitySlider(
      id: 'structure',
      leftLabel: 'Structure',
      rightLabel: 'Flexibility',
      leftIcon: Icons.grid_on_rounded,
      rightIcon: Icons.waves_rounded,
    ),
    PersonalitySlider(
      id: 'logic_instinct',
      leftLabel: 'Logic',
      rightLabel: 'Instinct',
      leftIcon: Icons.calculate_outlined,
      rightIcon: Icons.favorite_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  double _getSliderValue(int index) {
    switch (index) {
      case 0:
        return _rechargeValue;
      case 1:
        return _thinkActValue;
      case 2:
        return _structureValue;
      case 3:
        return _logicInstinctValue;
      default:
        return 0.5;
    }
  }

  void _setSliderValue(int index, double value) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (index) {
        case 0:
          _rechargeValue = value;
          break;
        case 1:
          _thinkActValue = value;
          break;
        case 2:
          _structureValue = value;
          break;
        case 3:
          _logicInstinctValue = value;
          break;
      }
    });
  }

  Future<void> _handleContinue() async {
    HapticFeedback.mediumImpact();

    // Save personality preferences
    final personalityData = {
      'recharge': _rechargeValue,
      'think_act': _thinkActValue,
      'structure': _structureValue,
      'logic_instinct': _logicInstinctValue,
    };

    await SharedPrefHelper.savePersonalityPreferences(jsonEncode(personalityData));

    Get.to(
      () => const NamingScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

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
            child: AnimatedBuilder(
              animation: _entryController,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with progress
                    _buildHeader(),

                    // Content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: QuestionnaireTheme.paddingHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // Question headline
                                _buildHeadline(),

                                const SizedBox(height: 32),

                                // Personality sliders
                                ..._buildSliders(),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom button
                    _buildBottomArea(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal - 8,
        12,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: QuestionnaireTheme.textPrimary,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          // Progress indicator (8 steps, currently on step 3)
          _buildProgress(currentStep: 2, totalSteps: 8),

          const Spacer(),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildProgress({required int currentStep, required int totalSteps}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive || isCompleted
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Help us\nunderstand you",
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 8),
        Text(
          "Move the sliders to match your nature",
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSliders() {
    return List.generate(_sliders.length, (index) {
      final slider = _sliders[index];
      final value = _getSliderValue(index);

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 450 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Transform.translate(
            offset: Offset(0, 25 * (1 - animValue)),
            child: Opacity(
              opacity: animValue.clamp(0.0, 1.0),
              child: _buildSliderCard(slider, value, index),
            ),
          );
        },
      );
    });
  }

  Widget _buildSliderCard(PersonalitySlider slider, double value, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        gradient: QuestionnaireTheme.cardGradient(),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSliderLabel(
                icon: slider.leftIcon,
                label: slider.leftLabel,
                isActive: value < 0.4,
                isLeft: true,
              ),
              const SizedBox(width: 16),
              _buildSliderLabel(
                icon: slider.rightIcon,
                label: slider.rightLabel,
                isActive: value > 0.6,
                isLeft: false,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Custom slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: _GoldThumbShape(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              activeTrackColor: QuestionnaireTheme.accentGold,
              inactiveTrackColor: QuestionnaireTheme.backgroundSecondary,
              overlayColor: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
              trackShape: _RoundedTrackShape(),
            ),
            child: Slider(
              value: value,
              onChanged: (newValue) => _setSliderValue(index, newValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderLabel({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isLeft,
  }) {
    final iconWidget = Icon(
      icon,
      size: 16,
      color: isActive
          ? QuestionnaireTheme.accentGold
          : QuestionnaireTheme.textTertiary,
    );

    final textWidget = Flexible(
      child: Text(
        label,
        style: QuestionnaireTheme.bodySmall(
          color: isActive
              ? QuestionnaireTheme.accentGold
              : QuestionnaireTheme.textSecondary,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.right,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    return Expanded(
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: isLeft
            ? [iconWidget, const SizedBox(width: 6), textWidget]
            : [textWidget, const SizedBox(width: 6), iconWidget],
      ),
    );
  }

  Widget _buildBottomArea() {
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
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.9),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: PremiumButton(
        title: 'Continue',
        onTap: _handleContinue,
      ),
    );
  }
}

/// Model for personality slider
class PersonalitySlider {
  final String id;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;

  const PersonalitySlider({
    required this.id,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIcon,
    required this.rightIcon,
  });
}

/// Custom thumb shape for the slider
class _GoldThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = QuestionnaireTheme.accentGold.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 14, glowPaint);

    // Main thumb
    final thumbPaint = Paint()
      ..color = QuestionnaireTheme.accentGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, thumbPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = QuestionnaireTheme.accentGoldLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center.translate(-2, -2), 4, highlightPaint);
  }
}

/// Custom track shape for rounded ends
class _RoundedTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final trackRadius = Radius.circular(trackRect.height / 2);
    final activeTrackRRect = RRect.fromLTRBR(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
      trackRadius,
    );
    final inactiveTrackRRect = RRect.fromLTRBR(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      trackRadius,
    );

    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!;
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    context.canvas.drawRRect(inactiveTrackRRect, inactivePaint);
    context.canvas.drawRRect(activeTrackRRect, activePaint);
  }
}
