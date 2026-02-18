import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import 'commitment_ritual_screen.dart';

/// Screen 5.5: "The Breath" (NEW)
/// Purpose: Create mindful moment, build anticipation
/// Visual: Simple breathing circle animation
/// Copy: "Let's take 3 breaths together"
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _breathCount = 0;
  static const int _totalBreaths = 3;
  String _breathPhase = 'Tap to Begin';
  bool _hasStarted = false;
  Timer? _phaseTimer;
  Timer? _cycleTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Single breath cycle: 4s in (expand) + 4s out (shrink)
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeController.forward();
  }

  void _startBreathing() {
    if (_hasStarted) return;

    setState(() {
      _hasStarted = true;
    });
    HapticFeedback.mediumImpact();
    _runBreathCycle();
  }

  void _runBreathCycle() {
    if (_breathCount >= _totalBreaths) {
      _navigateToNext();
      return;
    }

    // Inhale phase - circle expands
    setState(() {
      _breathPhase = 'Breathe In';
    });
    HapticFeedback.lightImpact();
    _breathController.forward(from: 0.0);

    // After 4 seconds, start exhale - circle shrinks
    _phaseTimer = Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() {
          _breathPhase = 'Breathe Out';
        });
        HapticFeedback.lightImpact();
        _breathController.reverse();
      }
    });

    // After 8 seconds (4 in + 4 out), increment count and repeat
    _cycleTimer = Timer(const Duration(milliseconds: 8000), () {
      if (mounted) {
        setState(() {
          _breathCount++;
        });
        _runBreathCycle();
      }
    });
  }

  void _navigateToNext() {
    HapticFeedback.mediumImpact();
    Get.off(
      () => const CommitmentRitualScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _cycleTimer?.cancel();
    _breathController.dispose();
    _fadeController.dispose();
    super.dispose();
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
              animation: Listenable.merge([_fadeController, _breathController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      // Header with skip
                      _buildHeader(),

                      // Main content
                      Expanded(
                        child: GestureDetector(
                          onTap: _hasStarted ? null : _startBreathing,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title
                              Text(
                                "Let's take 3 breaths\ntogether",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: QuestionnaireTheme.textPrimary,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Breathing circle
                              _buildBreathingCircle(),

                              const SizedBox(height: 32),

                              // Breath phase text
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _breathPhase,
                                  key: ValueKey(_breathPhase),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: _hasStarted
                                        ? QuestionnaireTheme.accentGold
                                        : QuestionnaireTheme.textSecondary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Progress dots (only show after started)
                              if (_hasStarted) _buildProgressDots(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
        QuestionnaireTheme.paddingHorizontal,
        12,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _navigateToNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Skip',
                style: QuestionnaireTheme.bodySmall(
                  color: QuestionnaireTheme.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle() {
    // Scale from 0.6 (small) to 1.0 (large)
    final scale = 0.6 + (_breathController.value * 0.4);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Transform.scale(
            scale: scale,
            child: Container(
              width: 180,
              height: 180,
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
          ),

          // Main circle
          Transform.scale(
            scale: scale,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),

          // Inner circle
          Transform.scale(
            scale: scale * 0.7 + 0.3,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalBreaths, (index) {
        final isCompleted = index < _breathCount;
        final isActive = index == _breathCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 12 : 8,
            height: isActive ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }
}
