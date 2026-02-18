import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/challenge_selection_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/glass_morphism_card.dart';
import '../../widgets/animated_progress_dots.dart';

/// Premium Onboarding Screen with 3-step visual carousel
/// Designed to hook users with engaging visuals and messaging
class PremiumOnboardingScreen extends StatefulWidget {
  const PremiumOnboardingScreen({super.key});

  @override
  State<PremiumOnboardingScreen> createState() =>
      _PremiumOnboardingScreenState();
}

class _PremiumOnboardingScreenState extends State<PremiumOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers for page transitions
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Floating animation for icons
  late AnimationController _floatController;

  // Audio controller for intro audio
  IntroAudioController? _audioController;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Try to get audio controller if available
    try {
      _audioController = Get.find<IntroAudioController>();
    } catch (_) {
      // Audio controller not available, continue without it
    }
  }

  void _initAnimations() {
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _restartAnimation();
  }

  void _restartAnimation() {
    _contentController.reset();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    _audioController?.stopAudio();
    Get.offAll(
      () => const ChallengeSelectionScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _handleGetStarted() {
    HapticFeedback.lightImpact();
    _audioController?.stopAudio();
    Get.offAll(
      () => const ChallengeSelectionScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _handleSignIn() {
    HapticFeedback.lightImpact();
    _audioController?.stopAudio();
    Get.offAll(
      () => LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: QuestionnaireTheme.backgroundGradient,
              ),
            ),

            // Page content
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildStep0(),
                _buildStep1(),
                _buildStep2(),
              ],
            ),

            // Top bar with skip and progress
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button (hidden on last page)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _currentPage < 2 ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: _currentPage < 2 ? _handleSkip : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: QuestionnaireTheme.backgroundSecondary
                                .withValues(alpha:0.6),
                            border: Border.all(
                              color: QuestionnaireTheme.borderDefault
                                  .withValues(alpha:0.3),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: QuestionnaireTheme.label(
                              color: QuestionnaireTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Progress dots
                    AnimatedProgressDots(
                      totalSteps: 3,
                      currentStep: _currentPage,
                    ),

                    // Spacer for alignment
                    const SizedBox(width: 60),
                  ],
                ),
              ),
            ),

            // Bottom area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      QuestionnaireTheme.backgroundPrimary.withValues(alpha:0),
                      QuestionnaireTheme.backgroundPrimary.withValues(alpha:0.9),
                      QuestionnaireTheme.backgroundPrimary,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: _buildBottomActions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 0 - "The Awakening"
  Widget _buildStep0() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/onboarding_bg.png',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha:0.4),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // Radial gold glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      QuestionnaireTheme.accentGold.withValues(alpha:0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Golden leaves
            _buildGoldenLeaves(),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Main headline
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Most men are asleep...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: QuestionnaireTheme.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    QuestionnaireTheme.accentGoldLight,
                                    QuestionnaireTheme.accentGold,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                "You won't be.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Glass card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: GlassMorphismCard(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      QuestionnaireTheme.accentGold
                                          .withValues(alpha:0.3),
                                      QuestionnaireTheme.accentGoldDark
                                          .withValues(alpha:0.1),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: QuestionnaireTheme.accentGold,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Break free from mediocrity',
                                  style: QuestionnaireTheme.titleLarge(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Step 1 - "The Vision"
  Widget _buildStep1() {
    return AnimatedBuilder(
      animation: Listenable.merge([_contentController, _floatController]),
      builder: (context, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated logo with glow
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: QuestionnaireTheme.accentGold
                                    .withValues(alpha:0.4),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: QuestionnaireTheme.accentGold
                                    .withValues(alpha:0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app-logo2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Brand name with shimmer
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            QuestionnaireTheme.accentGoldLight,
                            QuestionnaireTheme.accentGold,
                            QuestionnaireTheme.accentGoldDark,
                            QuestionnaireTheme.accentGold,
                            QuestionnaireTheme.accentGoldLight,
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'ZENSLAM',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Meditation Designed for Men',
                      style: QuestionnaireTheme.bodyLarge(
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Value proposition cards
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildValueCard(
                          icon: Icons.science_outlined,
                          title: 'Science-backed meditations',
                        ),
                        const SizedBox(height: 12),
                        _buildValueCard(
                          icon: Icons.male_rounded,
                          title: 'Made for men only',
                        ),
                        const SizedBox(height: 12),
                        _buildValueCard(
                          icon: Icons.timer_outlined,
                          title: 'Sessions from 5-30 minutes',
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Step 2 - "The Call"
  Widget _buildStep2() {
    return AnimatedBuilder(
      animation: Listenable.merge([_contentController, _floatController]),
      builder: (context, child) {
        final floatValue = _floatController.value;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Floating category icons
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Confidence icon
                          Transform.translate(
                            offset: Offset(
                              -70,
                              -10 + (10 * math.sin(floatValue * math.pi * 2)),
                            ),
                            child: Transform.rotate(
                              angle: 0.1 * math.sin(floatValue * math.pi * 2),
                              child: _buildFloatingIcon(
                                'assets/images/confidenticon.png',
                                size: 60,
                              ),
                            ),
                          ),
                          // Focus icon
                          Transform.translate(
                            offset: Offset(
                              0,
                              5 +
                                  (10 *
                                      math.sin(
                                          (floatValue + 0.3) * math.pi * 2)),
                            ),
                            child: Transform.rotate(
                              angle: -0.05 *
                                  math.sin((floatValue + 0.3) * math.pi * 2),
                              child: _buildFloatingIcon(
                                'assets/images/focusicon.png',
                                size: 70,
                              ),
                            ),
                          ),
                          // Fitness icon
                          Transform.translate(
                            offset: Offset(
                              70,
                              -5 +
                                  (10 *
                                      math.sin(
                                          (floatValue + 0.6) * math.pi * 2)),
                            ),
                            child: Transform.rotate(
                              angle: 0.08 *
                                  math.sin((floatValue + 0.6) * math.pi * 2),
                              child: _buildFloatingIcon(
                                'assets/images/fitnessicon.png',
                                size: 60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Main headline
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Become the man you\nwere meant to be',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: QuestionnaireTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subheadline
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            QuestionnaireTheme.accentGoldLight,
                            QuestionnaireTheme.accentGold,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        "Let's personalize your journey",
                        textAlign: TextAlign.center,
                        style: QuestionnaireTheme.titleMedium(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Glass card
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GoldGlowCard(
                      isHighlighted: true,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  QuestionnaireTheme.accentGold.withValues(alpha:0.3),
                                  QuestionnaireTheme.accentGoldDark
                                      .withValues(alpha:0.1),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: QuestionnaireTheme.accentGold,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2 min setup',
                                  style: QuestionnaireTheme.titleMedium(),
                                ),
                                Text(
                                  'Personalized experience',
                                  style: QuestionnaireTheme.bodySmall(
                                    color: QuestionnaireTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoldenLeaves() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -20,
          child: Transform.rotate(
            angle: -0.2,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/icons/golden_leaf_left.png',
                width: 80,
                height: 80,
                color: QuestionnaireTheme.accentGold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 140,
          right: -20,
          child: Transform.rotate(
            angle: 0.2,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/icons/golden_leaf_right.png',
                width: 80,
                height: 80,
                color: QuestionnaireTheme.accentGold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: QuestionnaireTheme.cardBackground.withValues(alpha:0.6),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: QuestionnaireTheme.accentGold,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: QuestionnaireTheme.titleMedium(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(String assetPath, {double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: QuestionnaireTheme.accentGold.withValues(alpha:0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_currentPage < 2) {
      // For steps 0 and 1 - show next button
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty space for alignment
          const SizedBox(width: 100),

          // Next button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: QuestionnaireTheme.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold.withValues(alpha:0.4),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: QuestionnaireTheme.backgroundPrimary,
                size: 28,
              ),
            ),
          ),

          // Empty space for alignment
          const SizedBox(width: 100),
        ],
      );
    } else {
      // For step 2 - show Get Started and Sign In
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PremiumButton(
            title: 'Get Started',
            onTap: _handleGetStarted,
            showArrow: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: QuestionnaireTheme.bodyMedium(
                  color: QuestionnaireTheme.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: _handleSignIn,
                child: Text(
                  'Sign In',
                  style: QuestionnaireTheme.label(
                    color: QuestionnaireTheme.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
