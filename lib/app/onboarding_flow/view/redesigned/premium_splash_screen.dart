import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../optimized/challenge_selection_screen.dart';

/// Premium splash screen with cinematic entrance
/// Sets the luxurious tone for Zenslam experience
class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _ringController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _particleOpacity;

  final IntroAudioController _audioController = Get.put(IntroAudioController());
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Ring pulse animation
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _ringScale = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _startSequence() async {
    // Start intro audio
    _audioController.playIntroAudio();

    // Animate logo
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _particleController.forward();

    // Start ring animation loop
    await Future.delayed(const Duration(milliseconds: 600));
    _ringController.repeat();

    // Animate text
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Auto-navigate after delay
    await Future.delayed(const Duration(milliseconds: 3500));
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    if (_isNavigating) return;
    _isNavigating = true;

    // Check onboarding status
    final isOnboardingCompleted =
        await SharedPrefHelper.getIsOnboardingCompleted();

    if (isOnboardingCompleted == true) {
      Get.offAll(
        () => NavBarScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      Get.off(
        () => const ChallengeSelectionScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _ringController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: GestureDetector(
          onTap: _handleNavigation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: QuestionnaireTheme.backgroundGradient,
            ),
            child: Stack(
              children: [
                // Animated background particles
                _buildBackgroundParticles(),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Logo with rings
                      _buildAnimatedLogo(),

                      const SizedBox(height: 40),

                      // Brand name
                      _buildBrandName(),

                      const SizedBox(height: 12),

                      // Tagline
                      _buildTagline(),

                      const Spacer(flex: 3),

                      // Bottom indicator
                      _buildBottomIndicator(),

                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return AnimatedBuilder(
      animation: _particleOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: (_particleOpacity.value * 0.4).clamp(0.0, 1.0),
          child: Stack(
            children: [
              // Subtle gradient orbs
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.width * 0.1,
                child: _buildGlowOrb(80, 0.15),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: MediaQuery.of(context).size.width * 0.05,
                child: _buildGlowOrb(60, 0.1),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.25,
                left: MediaQuery.of(context).size.width * 0.15,
                child: _buildGlowOrb(50, 0.08),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.35,
                right: MediaQuery.of(context).size.width * 0.2,
                child: _buildGlowOrb(70, 0.12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowOrb(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            QuestionnaireTheme.accentGold.withValues(alpha:opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _ringController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringOpacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: QuestionnaireTheme.accentGold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Inner glow ring
            Transform.scale(
              scale: _logoScale.value,
              child: Opacity(
                opacity: _logoOpacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        QuestionnaireTheme.accentGold.withValues(alpha:0.15),
                        QuestionnaireTheme.accentGold.withValues(alpha:0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Main logo circle
            Transform.scale(
              scale: _logoScale.value,
              child: Opacity(
                opacity: _logoOpacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuestionnaireTheme.cardBackground,
                    border: Border.all(
                      color: QuestionnaireTheme.accentGold.withValues(alpha:0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: QuestionnaireTheme.accentGold.withValues(alpha:0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            QuestionnaireTheme.accentGoldLight,
                            QuestionnaireTheme.accentGold,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'M',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandName() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: SlideTransition(
            position: _textSlide,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    QuestionnaireTheme.textPrimary,
                    QuestionnaireTheme.accentGoldLight,
                    QuestionnaireTheme.textPrimary,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                'ZENSLAM',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: SlideTransition(
            position: _textSlide,
            child: Text(
              'The Meditation App for Men',
              style: QuestionnaireTheme.bodyLarge(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: Column(
            children: [
              Text(
                'TAP TO CONTINUE',
                style: QuestionnaireTheme.caption(
                  color: QuestionnaireTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: QuestionnaireTheme.accentGold.withValues(alpha:0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
