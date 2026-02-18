import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/meditation_timer/widgets/breathing_guide.dart';
import 'package:zenslam/app/meditation_timer/widgets/breathing_pattern_picker.dart';
import 'package:zenslam/app/meditation_timer/widgets/duration_picker.dart';
import 'package:zenslam/app/meditation_timer/widgets/sound_picker.dart';
import 'package:zenslam/app/meditation_timer/widgets/timer_display.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// Premium meditation timer screen with breathing guide
class MeditationTimerScreen extends StatefulWidget {
  const MeditationTimerScreen({super.key});

  @override
  State<MeditationTimerScreen> createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late MeditationTimerController controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    controller = Get.put(MeditationTimerController());

    // Setup animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: QuestionnaireTheme.backgroundGradient,
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Obx(() {
                    final isRunning = controller.isRunning.value;
                    final isComplete = controller.isComplete.value;

                    if (isComplete) {
                      return _buildCompletionView();
                    }

                    if (isRunning) {
                      return _buildMeditationView();
                    }

                    return _buildSetupView();
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Setup view - Configure meditation before starting
  Widget _buildSetupView() {
    return Column(
      children: [
        // Header
        _buildHeader(),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Timer display (preview)
                const TimerDisplay(size: 200),

                const SizedBox(height: 32),

                // Duration picker
                const DurationPicker(),

                const SizedBox(height: 24),

                // Breathing pattern picker
                const BreathingPatternPicker(),

                const SizedBox(height: 24),

                // Sound picker
                const SoundPicker(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Start button
        _buildStartButton(),
      ],
    );
  }

  /// Meditation view - Active meditation session
  Widget _buildMeditationView() {
    return Obx(() {
      final isCountingDown = controller.isCountingDown.value;

      if (isCountingDown) {
        return _buildCountdownView();
      }

      return Stack(
        children: [
          // Main content
          Column(
            children: [
              // Minimal header
              _buildMinimalHeader(),

              // Breathing guide or timer display
              Expanded(
                child: Center(
                  child: Obx(() {
                    final pattern = controller.selectedPattern.value;

                    if (pattern.id != 'none') {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const BreathingGuide(size: 280),
                          const SizedBox(height: 40),
                          const CompactTimerDisplay(),
                        ],
                      );
                    }

                    return const TimerDisplay(size: 320);
                  }),
                ),
              ),

              // Controls
              _buildMeditationControls(),
            ],
          ),
        ],
      );
    });
  }

  /// Countdown view - Shows 5, 4, 3, 2, 1 before meditation starts
  Widget _buildCountdownView() {
    return Column(
      children: [
        // Minimal header with close option
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.stopTimer();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuestionnaireTheme.cardBackground.withValues(alpha: 0.8),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 22,
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 44),
              const SizedBox(width: 44),
            ],
          ),
        ),

        // Countdown display
        Expanded(
          child: Center(
            child: Obx(() {
              final count = controller.countdownValue.value;
              return TweenAnimationBuilder<double>(
                key: ValueKey(count),
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return TweenAnimationBuilder<double>(
                    key: ValueKey('opacity_$count'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, opacity, _) {
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Countdown number
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      QuestionnaireTheme.accentGold
                                          .withValues(alpha: 0.3),
                                      QuestionnaireTheme.accentGold
                                          .withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                  border: Border.all(
                                    color: QuestionnaireTheme.accentGold
                                        .withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: QuestionnaireTheme.accentGold
                                          .withValues(alpha: 0.3),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Text(
                                      '$count',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w600,
                                        color: QuestionnaireTheme.accentGold,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // "Get ready" text
                              Text(
                                'Get Ready',
                                style: GoogleFonts.dmSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: QuestionnaireTheme.textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ),

        // Bottom spacer
        const SizedBox(height: 100),
      ],
    );
  }

  /// Completion view - Session finished
  Widget _buildCompletionView() {
    return Column(
      children: [
        const Spacer(),

        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: QuestionnaireTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 60,
            color: QuestionnaireTheme.backgroundPrimary,
          ),
        ),

        const SizedBox(height: 32),

        // Congratulations text
        Text(
          'Session Complete',
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: QuestionnaireTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'You meditated for ${controller.duration.value} minutes',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: QuestionnaireTheme.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        // Motivational message
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
            border: Border.all(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _getMotivationalMessage(),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: QuestionnaireTheme.accentGold,
            ),
          ),
        ),

        const Spacer(),

        // Action buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // New session button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  controller.reset();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                    'Start New Session',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.backgroundPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Close button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: QuestionnaireTheme.cardBackground,
                    border: Border.all(
                      color:
                          QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'Done',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color:
                      QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: QuestionnaireTheme.textPrimary,
              ),
            ),
          ),

          // Title
          Text(
            'Meditation Timer',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: QuestionnaireTheme.textPrimary,
            ),
          ),

          // Spacer for alignment
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showExitConfirmation();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground.withValues(alpha: 0.8),
              ),
              child: const Icon(
                Icons.close,
                size: 22,
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ),

          // Pattern indicator
          const CompactBreathingPatternPicker(),

          // Spacer
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.startTimer();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: QuestionnaireTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                size: 24,
                color: QuestionnaireTheme.backgroundPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Begin Meditation',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: QuestionnaireTheme.backgroundPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationControls() {
    return Obx(() {
      final isPaused = controller.isPaused.value;

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stop button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showExitConfirmation();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.cardBackground,
                  border: Border.all(
                    color:
                        QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.stop_rounded,
                  size: 28,
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Play/Pause button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (isPaused) {
                  controller.resumeTimer();
                } else {
                  controller.pauseTimer();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: QuestionnaireTheme.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color:
                          QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 40,
                  color: QuestionnaireTheme.backgroundPrimary,
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Skip forward (optional - add 1 minute)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Could add skip functionality here
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: QuestionnaireTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'End Session?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: QuestionnaireTheme.textPrimary,
            ),
          ),
          content: Text(
            'Your meditation session is still in progress. Are you sure you want to end it?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: QuestionnaireTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continue',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.stopTimer();
                Get.back();
              },
              child: Text(
                'End Session',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage() {
    final messages = [
      'Every breath is a fresh start.',
      'You invested in your peace today.',
      'The mind is your most powerful ally.',
      'Stillness cultivates strength.',
      'One moment at a time, you grow stronger.',
    ];
    return messages[DateTime.now().minute % messages.length];
  }
}
