import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:zenslam/app/splash/controller/app_life_cycle_controller.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/premium_onboarding_screen.dart';

/// Premium Splash Screen with engaging visuals, animations, and social proof
/// This is the first screen users see - designed to hook them immediately
class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({super.key});

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  // Audio and lifecycle controllers
  IntroAudioController? _audioController;
  AppLifecycleController? _lifecycleController;

  // State for login check
  bool _isCheckingLogin = true;

  // Logo animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;

  // Brand text animations
  late Animation<double> _brandFade;
  late Animation<Offset> _brandSlide;

  // Tagline animations
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  // Hero image animations
  late Animation<double> _heroFade;
  late Animation<double> _heroScale;

  // Social proof animations
  late Animation<double> _socialProofFade;
  late Animation<Offset> _socialProofSlide;

  // CTA button animations
  late Animation<double> _ctaFade;
  late Animation<Offset> _ctaSlide;

  // Continuous pulse for logo
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initControllers();
    _checkLoginStatus();
  }

  void _initControllers() {
    try {
      _audioController = Get.find<IntroAudioController>();
      _lifecycleController = Get.find<AppLifecycleController>();
    } catch (_) {
      // Controllers not available, continue without them
    }
  }

  Future<void> _checkLoginStatus() async {
    final token = await SharedPrefHelper.getAccessToken();
    final isOnboardingCompleted =
        await SharedPrefHelper.getIsOnboardingCompleted();

    if (token != null) {
      // User is logged in, go to NavBarScreen
      await NotificationService.initialize();
      _audioController?.stopAudio();
      Get.offAll(() => NavBarScreen());
    } else if (isOnboardingCompleted == true) {
      // User completed onboarding but not logged in
      _audioController?.stopAudio();
      Get.offAll(() => NavBarScreen());
    } else {
      // New user, show the premium splash screen
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
        _startAnimations();
        _startAudio();
      }
    }
  }

  Future<void> _startAudio() async {
    try {
      if (_lifecycleController?.isAppInForeground.value ?? true) {
        await _audioController?.playIntroAudio();
      }
    } catch (e) {
      debugPrint('Error starting audio: $e');
    }
  }

  void _initAnimations() {
    // Logo animation controller (0-400ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Content animation controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Continuous pulse controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo fade + scale (0-400ms)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // Brand text reveal (200-600ms)
    _brandFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );

    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline animations (300-700ms)
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Hero image fade in (400-900ms)
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _heroScale = Tween<double>(begin: 1.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Social proof slide up (600-1100ms)
    _socialProofFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );

    _socialProofSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // CTA button appear (900-1400ms)
    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous pulse animation
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBegin() {
    HapticFeedback.lightImpact();
    _audioController?.stopAudio();
    Get.off(
      () => const PremiumOnboardingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Show loading state while checking login
    if (_isCheckingLogin) {
      return Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      QuestionnaireTheme.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

            // Hero image with gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _heroFade.value,
                    child: Transform.scale(
                      scale: _heroScale.value,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/welcome_screen_image.jpg',
                      width: size.width,
                      height: size.height * 0.55,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              QuestionnaireTheme.backgroundPrimary,
                              QuestionnaireTheme.backgroundPrimary
                                  .withValues(alpha:0.8),
                              QuestionnaireTheme.backgroundPrimary
                                  .withValues(alpha:0.0),
                              QuestionnaireTheme.backgroundPrimary
                                  .withValues(alpha:0.5),
                              QuestionnaireTheme.backgroundPrimary,
                            ],
                            stops: const [0.0, 0.15, 0.4, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Golden leaf decorations
            _buildGoldenLeaves(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo section
                  _buildLogoSection(),

                  const Spacer(),

                  // Bottom section with social proof and CTA
                  _buildBottomSection(bottomPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldenLeaves() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroFade.value * 0.7,
          child: child,
        );
      },
      child: Stack(
        children: [
          // Left leaf
          Positioned(
            top: 80,
            left: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Image.asset(
                'assets/icons/golden_leaf_left.png',
                width: 100,
                height: 100,
                color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
              ),
            ),
          ),
          // Right leaf
          Positioned(
            top: 120,
            right: -20,
            child: Transform.rotate(
              angle: 0.2,
              child: Image.asset(
                'assets/icons/golden_leaf_right.png',
                width: 100,
                height: 100,
                color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return Column(
          children: [
            // Logo with glow effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Opacity(
                  opacity: _logoGlow.value * (0.5 + 0.3 * _pulseAnimation.value),
                  child: Container(
                    width: 100 + (20 * _pulseAnimation.value),
                    height: 100 + (20 * _pulseAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: QuestionnaireTheme.accentGold.withValues(alpha:0.4),
                          blurRadius: 40 + (20 * _pulseAnimation.value),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                // Logo
                Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                QuestionnaireTheme.accentGold.withValues(alpha:0.3),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Brand name with shimmer effect
            SlideTransition(
              position: _brandSlide,
              child: FadeTransition(
                opacity: _brandFade,
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
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tagline
            SlideTransition(
              position: _taglineSlide,
              child: FadeTransition(
                opacity: _taglineFade,
                child: Text(
                  'Winning the Mental Game of Tennis',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: QuestionnaireTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSection(double bottomPadding) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
          child: Column(
            children: [
              // Social proof badges
              SlideTransition(
                position: _socialProofSlide,
                child: FadeTransition(
                  opacity: _socialProofFade,
                  child: _buildSocialProof(),
                ),
              ),

              const SizedBox(height: 32),

              // CTA Button
              SlideTransition(
                position: _ctaSlide,
                child: FadeTransition(
                  opacity: _ctaFade,
                  child: PremiumButton(
                    title: 'Begin Your Training',
                    onTap: _handleBegin,
                    showArrow: true,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer text
              FadeTransition(
                opacity: _ctaFade,
                child: Text(
                  'Takes less than 2 minutes',
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialProof() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialBadge(
          icon: Icons.play_circle_outline,
          value: '120+',
          label: 'Sessions',
        ),
        Container(
          width: 1,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: QuestionnaireTheme.borderDefault.withValues(alpha:0.5),
        ),
        _buildSocialBadge(
          icon: Icons.sports_tennis,
          value: 'Tennis',
          label: 'Focused',
        ),
      ],
    );
  }

  Widget _buildSocialBadge({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: QuestionnaireTheme.accentGold,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: QuestionnaireTheme.titleMedium(
                color: QuestionnaireTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: QuestionnaireTheme.caption(
                color: QuestionnaireTheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
