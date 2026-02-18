import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'personalized_plan_screen.dart';

/// Time commitment selection screen
/// Quick and essential for content recommendations
class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String? _selectedTime;

  // Time options with benefits - ordered from shortest to longest
  final List<TimeOption> _timeOptions = [
    TimeOption(
      id: '5min',
      title: '5 minutes',
      subtitle: 'Quick daily reset',
      emoji: '⚡',
      benefit: 'Perfect for busy schedules',
    ),
    TimeOption(
      id: '10min',
      title: '10 minutes',
      subtitle: 'Recommended for beginners',
      emoji: '🌱',
      benefit: 'Most popular choice',
      isRecommended: true,
    ),
    TimeOption(
      id: '15min',
      title: '15 minutes',
      subtitle: 'Deeper practice',
      emoji: '🧘',
      benefit: 'Ideal for stress management',
    ),
    TimeOption(
      id: '20min+',
      title: '20+ minutes',
      subtitle: 'Full transformation',
      emoji: '🏔️',
      benefit: 'Maximum benefits',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.isFromPreference) {
      _loadExistingSelection();
    }
  }

  Future<void> _loadExistingSelection() async {
    final savedTime = await SharedPrefHelper.getOnboardingTime();
    if (savedTime != null && mounted) {
      setState(() {
        _selectedTime = savedTime;
      });
    }
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  Future<void> _handleContinue() async {
    if (_selectedTime == null) return;

    HapticFeedback.lightImpact();

    // Save the selected time
    await SharedPrefHelper.saveOnboardingTime(_selectedTime!);

    if (widget.isFromPreference) {
      // Return to preferences with result
      Get.back(result: true);
    } else {
      Get.to(
        () => const PersonalizedPlanScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
      );
    }
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
                    // Header
                    _buildHeader(),

                    // Content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: QuestionnaireTheme.paddingHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // Question
                                Text(
                                  "How much time can\nyou commit daily?",
                                  style: QuestionnaireTheme.displayMedium(),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Even 5 minutes makes a difference",
                                  style: QuestionnaireTheme.bodyLarge(
                                    color: QuestionnaireTheme.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Time options
                                Expanded(child: _buildTimeOptions()),
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

          // Progress
          _buildProgress(),

          const Spacer(),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index == 1;
        final isCompleted = index < 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive || isCompleted
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeOptions() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _timeOptions.length,
      itemBuilder: (context, index) {
        final option = _timeOptions[index];
        final isSelected = _selectedTime == option.id;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: _buildTimeCard(option, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeCard(TimeOption option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTime = option.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    QuestionnaireTheme.cardSelectedBackground,
                    QuestionnaireTheme.cardBackground,
                  ],
                )
              : QuestionnaireTheme.cardGradient(),
          border: Border.all(
            color: isSelected
                ? QuestionnaireTheme.accentGold.withValues(alpha: 0.6)
                : QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji/icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
                    : QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.title,
                        style: QuestionnaireTheme.titleMedium(
                          color: QuestionnaireTheme.textPrimary,
                        ),
                      ),
                      if (option.isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            'Popular',
                            style: QuestionnaireTheme.caption(
                              color: QuestionnaireTheme.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: QuestionnaireTheme.bodySmall(
                      color: QuestionnaireTheme.textTertiary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.benefit,
                      style: QuestionnaireTheme.bodySmall(
                        color: QuestionnaireTheme.accentGold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? QuestionnaireTheme.accentGold
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? QuestionnaireTheme.accentGold
                      : QuestionnaireTheme.borderDefault,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: QuestionnaireTheme.backgroundPrimary,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
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
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.8),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: PremiumButton(
        title: widget.isFromPreference ? 'Done' : 'Continue',
        onTap: _selectedTime != null ? _handleContinue : null,
      ),
    );
  }
}

/// Model for time options
class TimeOption {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String benefit;
  final bool isRecommended;

  const TimeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.benefit,
    this.isRecommended = false,
  });
}
