import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'time_selection_screen.dart';

/// Challenge selection screen - the most important personalization question
/// Uses single selection to reduce cognitive load and increase completion
class ChallengeSelectionScreen extends StatefulWidget {
  const ChallengeSelectionScreen({super.key, this.isFromPreference = false});

  final bool isFromPreference;

  @override
  State<ChallengeSelectionScreen> createState() =>
      _ChallengeSelectionScreenState();
}

class _ChallengeSelectionScreenState extends State<ChallengeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String? _selectedChallenge;

  // Challenges optimized for men's meditation app
  // Order matters - most common/relatable first
  final List<ChallengeOption> _challenges = [
    ChallengeOption(
      id: 'stress',
      title: 'Stress & Calm',
      subtitle: 'Find calm in the chaos',
      emoji: '😤',
      color: const Color(0xFFE57373),
    ),
    ChallengeOption(
      id: 'sleep',
      title: 'Better Sleep',
      subtitle: 'Rest deeply, wake refreshed',
      emoji: '😴',
      color: const Color(0xFF7986CB),
    ),
    ChallengeOption(
      id: 'focus',
      title: 'Focus & Clarity',
      subtitle: 'Sharpen your mind',
      emoji: '🎯',
      color: const Color(0xFF4FC3F7),
    ),
    ChallengeOption(
      id: 'confidence',
      title: 'Build Confidence',
      subtitle: 'Unlock your potential',
      emoji: '💪',
      color: const Color(0xFFFFB74D),
    ),
    ChallengeOption(
      id: 'purpose',
      title: 'Finding Purpose',
      subtitle: 'Discover what drives you',
      emoji: '🧭',
      color: const Color(0xFF81C784),
    ),
    ChallengeOption(
      id: 'anger',
      title: 'Managing Emotions',
      subtitle: 'Stay in control',
      emoji: '🌊',
      color: const Color(0xFFBA68C8),
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
    final savedChallenge = await SharedPrefHelper.getOnboardingChallenge();
    if (savedChallenge != null && mounted) {
      setState(() {
        _selectedChallenge = savedChallenge;
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
    if (_selectedChallenge == null) return;

    HapticFeedback.lightImpact();

    // Save the selected challenge
    await SharedPrefHelper.saveOnboardingChallenge(_selectedChallenge!);

    if (widget.isFromPreference) {
      // Return to preferences with result
      Get.back(result: true);
    } else {
      Get.to(
        () => const TimeSelectionScreen(),
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
                                  "What's your biggest\nchallenge right now?",
                                  style: QuestionnaireTheme.displayMedium(),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "We'll personalize your experience",
                                  style: QuestionnaireTheme.bodyLarge(
                                    color: QuestionnaireTheme.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Challenge options
                                Expanded(child: _buildChallengeList()),
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
        final isActive = index == 0;
        final isCompleted = index < 0;
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

  Widget _buildChallengeList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        final isSelected = _selectedChallenge == challenge.id;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: _buildChallengeCard(challenge, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(ChallengeOption challenge, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedChallenge = challenge.id;
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
            // Emoji container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? challenge.color.withValues(alpha: 0.2)
                    : QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Text(
                  challenge.emoji,
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
                  Text(
                    challenge.title,
                    style: QuestionnaireTheme.titleMedium(
                      color: QuestionnaireTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.subtitle,
                    style: QuestionnaireTheme.bodySmall(
                      color: isSelected
                          ? QuestionnaireTheme.accentGold
                          : QuestionnaireTheme.textTertiary,
                    ),
                  ),
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
        onTap: _selectedChallenge != null ? _handleContinue : null,
      ),
    );
  }
}

/// Model for challenge options
class ChallengeOption {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const ChallengeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}
