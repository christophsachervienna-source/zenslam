import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'challenge_selection_screen.dart';

/// Optimized welcome splash screen with social proof
/// Shows value proposition immediately to hook users
class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _contentFade;
  late Animation<double> _contentSlide;
  late Animation<double> _buttonFade;
  late Animation<double> _pulseAnimation;

  final IntroAudioController _audioController = Get.put(IntroAudioController());

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
      // Play intro audio and start animations
      _audioController.playIntroAudio();
      _mainController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    Get.to(
      () => const ChallengeSelectionScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([_mainController, _pulseController]),
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: QuestionnaireTheme.paddingHorizontal,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo with glow
                      _buildAnimatedLogo(),

                      const SizedBox(height: 32),

                      // Brand name and tagline
                      _buildBrandSection(),

                      const SizedBox(height: 40),

                      // Social proof badges
                      _buildSocialProof(),

                      const Spacer(flex: 2),

                      // Value propositions
                      _buildValueProps(),

                      const SizedBox(height: 32),

                      // CTA Button
                      _buildCTAButton(),

                      const SizedBox(height: 16),

                      // Time estimate
                      _buildTimeEstimate(),

                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
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

  Widget _buildAnimatedLogo() {
    return Transform.scale(
      scale: _logoScale.value,
      child: Opacity(
        opacity: _logoFade.value.clamp(0.0, 1.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                      QuestionnaireTheme.accentGold.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Main logo circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.25),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Transform.translate(
      offset: Offset(0, _contentSlide.value),
      child: Opacity(
        opacity: _contentFade.value.clamp(0.0, 1.0),
        child: Column(
          children: [
            ShaderMask(
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
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meditation Designed for Men',
              style: QuestionnaireTheme.bodyLarge(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialProof() {
    return Transform.translate(
      offset: Offset(0, _contentSlide.value * 0.5),
      child: Opacity(
        opacity: _contentFade.value.clamp(0.0, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProofBadge(
              icon: Icons.play_circle_outline_rounded,
              text: '110+ Sessions',
            ),
            const SizedBox(width: 16),
            _buildProofBadge(
              icon: Icons.psychology_outlined,
              text: 'Expert Designed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: QuestionnaireTheme.accentGold,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueProps() {
    return Opacity(
      opacity: _contentFade.value.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
          color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
          border: Border.all(
            color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            _buildValueItem(
              Icons.psychology_outlined,
              'Science-backed meditations',
            ),
            const SizedBox(height: 14),
            _buildValueItem(
              Icons.tune_rounded,
              'Personalized to your goals',
            ),
            const SizedBox(height: 14),
            _buildValueItem(
              Icons.timer_outlined,
              'Sessions from 5 to 30 minutes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.12),
          ),
          child: Icon(
            icon,
            color: QuestionnaireTheme.accentGold,
            size: 16,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: QuestionnaireTheme.bodyMedium(
              color: QuestionnaireTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return Opacity(
      opacity: _buttonFade.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - _buttonFade.value)),
        child: PremiumButton(
          title: 'Get Started',
          onTap: _handleContinue,
        ),
      ),
    );
  }

  Widget _buildTimeEstimate() {
    return Opacity(
      opacity: _buttonFade.value.clamp(0.0, 1.0),
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
            'Takes less than 2 minutes',
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
