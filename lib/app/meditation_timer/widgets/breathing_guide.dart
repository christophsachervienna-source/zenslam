import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated breathing guide circle that expands and contracts
/// based on the selected breathing pattern
class BreathingGuide extends StatefulWidget {
  final double size;

  const BreathingGuide({
    super.key,
    this.size = 280,
  });

  @override
  State<BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends State<BreathingGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  final MeditationTimerController controller =
      Get.find<MeditationTimerController>();

  String _lastPhase = '';
  double _currentScale = 0.6; // Start contracted
  double _targetScale = 0.6; // Initially at rest state
  bool _isFirstAnimation = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 0.6).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen for phase changes
    ever(controller.currentBreathPhase, _onPhaseChange);
    ever(controller.isRunning, _onRunningChange);
    ever(controller.isCountingDown, _onCountdownChange);
    ever(controller.isPaused, _onPausedChange);

    // Check if meditation is already running when widget is built
    // This handles the case where the widget is created after countdown ends
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isRunning.value &&
          !controller.isPaused.value &&
          !controller.isCountingDown.value) {
        final phase = controller.currentBreathPhase.value;
        if (phase.isNotEmpty && phase != _lastPhase) {
          _lastPhase = phase;
          _isFirstAnimation = true;
          _currentScale = 0.6;
          _animateToPhase(phase);
        }
      }
    });
  }

  void _onPausedChange(bool isPaused) {
    if (isPaused) {
      // Pause the animation at current position
      _animationController.stop();
    } else if (controller.isRunning.value && !controller.isCountingDown.value) {
      // Resume from current position
      if (_animationController.status == AnimationStatus.forward) {
        // Continue the animation
        _animationController.forward();
      } else if (!_isFirstAnimation) {
        // Animation was stopped, restart from current scale
        _animateToPhase(controller.currentBreathPhase.value);
      }
    }
  }

  void _onPhaseChange(String phase) {
    if (!controller.isRunning.value || controller.isPaused.value || controller.isCountingDown.value) {
      return;
    }

    if (phase != _lastPhase) {
      _lastPhase = phase;
      _animateToPhase(phase);
    }
  }

  void _onCountdownChange(bool isCountingDown) {
    // Reset animation state when countdown ends (meditation about to start)
    if (!isCountingDown && controller.isRunning.value) {
      _isFirstAnimation = true;
      _currentScale = 0.6;
      _targetScale = 0.6;
      _lastPhase = '';

      // Trigger the first animation after a small delay to ensure UI is ready
      Future.microtask(() {
        if (controller.isRunning.value &&
            !controller.isPaused.value &&
            !controller.isCountingDown.value) {
          final phase = controller.currentBreathPhase.value;
          if (phase.isNotEmpty && phase != _lastPhase) {
            _lastPhase = phase;
            _animateToPhase(phase);
          }
        }
      });
    }
  }

  void _onRunningChange(bool running) {
    if (!running) {
      _animationController.stop();
      _animationController.reset();
      // Reset to initial state
      _isFirstAnimation = true;
      _currentScale = 0.6;
      _targetScale = 0.6;
      _lastPhase = '';
    }
  }

  void _animateToPhase(String phase) {
    final pattern = controller.selectedPattern.value;
    if (pattern.id == 'none') return;

    Duration duration;
    double newTarget;

    switch (phase) {
      case 'inhale':
        duration = Duration(seconds: pattern.inhale);
        newTarget = 1.0;
        break;
      case 'holdIn':
        duration = Duration(seconds: pattern.holdIn);
        newTarget = 1.0;
        break;
      case 'exhale':
        duration = Duration(seconds: pattern.exhale);
        newTarget = 0.6;
        break;
      case 'holdOut':
        duration = Duration(seconds: pattern.holdOut);
        newTarget = 0.6;
        break;
      default:
        return;
    }

    // For the first animation, start from contracted state (0.6)
    if (_isFirstAnimation) {
      _currentScale = 0.6;
      _isFirstAnimation = false;
    } else {
      _currentScale = _targetScale;
    }
    _targetScale = newTarget;

    // Create smooth animations with better curves
    _scaleAnimation = Tween<double>(
      begin: _currentScale,
      end: _targetScale,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        // Use smoother curves for breathing - ease in/out sine feels more natural
        curve: phase == 'inhale' ? Curves.easeOutSine :
               phase == 'exhale' ? Curves.easeInSine : Curves.linear,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: phase == 'inhale' ? 0.3 : phase == 'exhale' ? 0.5 : (_currentScale > 0.8 ? 0.5 : 0.3),
      end: phase == 'inhale' || phase == 'holdIn' ? 0.6 : 0.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.duration = duration;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pattern = controller.selectedPattern.value;
      final isRunning = controller.isRunning.value;
      final isPaused = controller.isPaused.value;

      if (pattern.id == 'none') {
        // Show simple pulsing circle when no breathing guide
        return _buildSimpleCircle();
      }

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = isRunning && !isPaused
              ? _scaleAnimation.value
              : 0.8;
          final glowIntensity = isRunning && !isPaused
              ? _glowAnimation.value
              : 0.3;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: widget.size * scale * 1.2,
                height: widget.size * scale * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold
                          .withValues(alpha: glowIntensity * 0.4),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

              // Main breathing circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: widget.size * scale,
                height: widget.size * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      QuestionnaireTheme.accentGold
                          .withValues(alpha: glowIntensity * 0.6),
                      QuestionnaireTheme.accentGold
                          .withValues(alpha: glowIntensity * 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: QuestionnaireTheme.accentGold
                        .withValues(alpha: 0.6 + glowIntensity * 0.4),
                    width: 2,
                  ),
                ),
              ),

              // Inner circle with gradient
              Container(
                width: widget.size * scale * 0.7,
                height: widget.size * scale * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QuestionnaireTheme.accentGold
                          .withValues(alpha: glowIntensity * 0.4),
                      QuestionnaireTheme.accentGold.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),

              // Breath instruction text
              if (isRunning && !isPaused)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.breathInstruction,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: QuestionnaireTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.breathPhaseRemaining.value}',
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: QuestionnaireTheme.accentGold,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      );
    });
  }

  Widget _buildSimpleCircle() {
    return Obx(() {
      final isRunning = controller.isRunning.value;
      final isPaused = controller.isPaused.value;

      return TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0.85,
          end: isRunning && !isPaused ? 1.0 : 0.85,
        ),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: widget.size * scale * 1.1,
                height: widget.size * scale * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // Main circle
              Container(
                width: widget.size * scale,
                height: widget.size * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                      QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
              ),

              // Center dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.accentGold,
                  boxShadow: [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
