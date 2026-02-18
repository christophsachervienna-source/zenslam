import 'dart:math';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'mirror_screen.dart';

/// Screen 1: "The Awakening"
/// Purpose: Hook emotionally, establish premium quality
/// Visual: Full-bleed image with golden light atmosphere
/// Copy: "Most men are distracted... You're different."
class AwakeningScreen extends StatefulWidget {
  const AwakeningScreen({super.key});

  @override
  State<AwakeningScreen> createState() => _AwakeningScreenState();
}

class _AwakeningScreenState extends State<AwakeningScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _parallaxController;

  late Animation<double> _backgroundFade;
  late Animation<double> _headlineFade;
  late Animation<double> _headlineSlide;
  late Animation<double> _subheadlineFade;
  late Animation<double> _socialProofFade;
  late Animation<double> _buttonFade;
  late Animation<double> _pulseAnimation;

  IntroAudioController? _audioController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isOnboardingCompleted =
        await SharedPrefHelper.getIsOnboardingCompleted();

    if (isOnboardingCompleted == true) {
      Get.offAll(
        () => NavBarScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      _initAudio();
      _mainController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  void _initAudio() {
    try {
      _audioController = Get.find<IntroAudioController>();
      _audioController?.playIntroAudio();
    } catch (_) {
      // Controller not available
    }
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    )..repeat(reverse: true);

    // Background fades in first
    _backgroundFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Headline appears with dramatic slide up
    _headlineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _headlineSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Subheadline with gold gradient
    _subheadlineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );

    // Social proof badges
    _socialProofFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
      ),
    );

    // Button
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse for atmosphere
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    Get.to(
      () => const MirrorScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _pulseController, _parallaxController]),
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background with subtle parallax
                _buildBackgroundImage(),

                // Gradient overlay for readability
                _buildGradientOverlay(),

                // Floating particles for premium feel
                _buildParticles(),

                // Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QuestionnaireTheme.paddingHorizontal,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Main headline
                        _buildHeadline(),

                        const SizedBox(height: 16),

                        // Gold subheadline
                        _buildSubheadline(),

                        const SizedBox(height: 40),

                        // Social proof pills
                        _buildSocialProof(),

                        const Spacer(flex: 2),

                        // CTA Button
                        _buildCTAButton(),

                        const SizedBox(height: 24),

                        // Subtle indicator
                        _buildBottomIndicator(),

                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Opacity(
      opacity: _backgroundFade.value.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/onboarding_bg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.3),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.7),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.4, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Transform.translate(
      offset: Offset(0, _headlineSlide.value),
      child: Opacity(
        opacity: _headlineFade.value.clamp(0.0, 1.0),
        child: Text(
          'Most men are\ndistracted...',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: QuestionnaireTheme.textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _buildSubheadline() {
    return Opacity(
      opacity: _subheadlineFade.value.clamp(0.0, 1.0),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              QuestionnaireTheme.accentGoldLight,
              QuestionnaireTheme.accentGold,
              QuestionnaireTheme.accentGoldLight,
            ],
          ).createShader(bounds);
        },
        child: Text(
          "You're different.",
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialProof() {
    return Opacity(
      opacity: _socialProofFade.value.clamp(0.0, 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProofPill(
            icon: Icons.play_circle_outline_rounded,
            text: '110+ Sessions',
          ),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          _buildProofPill(
            icon: Icons.psychology_outlined,
            text: 'Expert Designed',
          ),
        ],
      ),
    );
  }

  Widget _buildProofPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.7),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: QuestionnaireTheme.accentGold,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: QuestionnaireTheme.bodyMedium(
              color: QuestionnaireTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return Opacity(
      opacity: _buttonFade.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - _buttonFade.value)),
        child: PremiumButton(
          title: 'Begin Your Journey',
          onTap: _handleContinue,
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Opacity(
      opacity: _buttonFade.value.clamp(0.0, 1.0) * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 14,
            color: QuestionnaireTheme.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            'Takes 2 minutes',
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return Opacity(
      opacity: _backgroundFade.value.clamp(0.0, 1.0),
      child: CustomPaint(
        painter: _AwakeningParticlePainter(
          progress: _parallaxController.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Subtle floating particles for premium ambient effect
class _AwakeningParticlePainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42); // Fixed seed for consistent particles

  _AwakeningParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate subtle particles
    for (int i = 0; i < 15; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final particleProgress = (progress + i * 0.07) % 1.0;

      // Gentle floating motion
      final x = baseX + sin(particleProgress * pi * 2 + i) * 15;
      final y = baseY - particleProgress * size.height * 0.2;

      // Subtle opacity based on position
      final fadeY = (1.0 - (y / size.height).abs()).clamp(0.0, 1.0);
      final particleOpacity = fadeY * 0.25;

      paint.color = QuestionnaireTheme.accentGold.withValues(alpha: particleOpacity);

      final radius = 1.5 + _random.nextDouble() * 1.5;
      canvas.drawCircle(
        Offset(x, y.abs() % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AwakeningParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
