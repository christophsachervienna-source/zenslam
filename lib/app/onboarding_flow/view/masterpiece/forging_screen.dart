import 'dart:async';
import 'dart:math';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import 'gateway_screen.dart';

/// Screen 7: "The Forging" (NEW)
/// Purpose: Build anticipation, justify personalization
/// Visual: Cinematic loading with imagery
/// Copy: "Forging Your Path..."
class ForgingScreen extends StatefulWidget {
  const ForgingScreen({super.key});

  @override
  State<ForgingScreen> createState() => _ForgingScreenState();
}

class _ForgingScreenState extends State<ForgingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _textController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  String? _challenge;
  String _userName = '';
  int _currentTextIndex = 0;
  Timer? _textTimer;
  double _progress = 0.0;

  final List<String> _loadingTexts = [
    'Analyzing your profile...',
    'Selecting meditations for you...',
    'Calibrating session lengths...',
    'Preparing your journey...',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initAnimations();
    _startLoadingSequence();
  }

  Future<void> _loadUserData() async {
    _challenge = await SharedPrefHelper.getOnboardingChallenge();
    _userName = await SharedPrefHelper.getOnboardingName() ?? '';

    // Update text based on challenge
    if (_challenge != null) {
      setState(() {
        _loadingTexts[1] = 'Selecting meditations for ${_getChallengeLabel()}...';
      });
    }
  }

  String _getChallengeLabel() {
    switch (_challenge) {
      case 'stress':
        return 'Stress Management';
      case 'sleep':
        return 'Better Sleep';
      case 'focus':
        return 'Focus';
      case 'confidence':
        return 'Confidence';
      case 'purpose':
        return 'Purpose';
      case 'anger':
        return 'Inner Peace';
      default:
        return 'Growth';
    }
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _textController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _progressController.forward();
    _textController.forward();

    _progressController.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });
  }

  void _startLoadingSequence() {
    // Change text every 800ms
    _textTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_currentTextIndex < _loadingTexts.length - 1) {
        _textController.reset();
        setState(() {
          _currentTextIndex++;
        });
        _textController.forward();
        HapticFeedback.selectionClick();
      } else {
        timer.cancel();
      }
    });

    // Navigate after loading completes
    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) {
        HapticFeedback.mediumImpact();
        Get.off(
          () => const GatewayScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 600),
        );
      }
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _fadeController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _textController.dispose();
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
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _fadeController,
            _progressController,
            _particleController,
            _textController,
          ]),
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                _buildBackgroundImage(),

                // Gradient overlay
                _buildGradientOverlay(),

                // Particle effect
                _buildParticles(),

                // Content
                SafeArea(
                  child: Opacity(
                    opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: QuestionnaireTheme.paddingHorizontal,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Main headline
                          _buildHeadline(),

                          const SizedBox(height: 48),

                          // Progress ring
                          _buildProgressRing(),

                          const SizedBox(height: 40),

                          // Animated loading text
                          _buildLoadingText(),

                          const Spacer(flex: 2),

                          // Progress bar
                          _buildProgressBar(),

                          const SizedBox(height: 24),
                        ],
                      ),
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
      opacity: 0.3 * _fadeAnimation.value,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/onboarding_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
              BlendMode.overlay,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.7),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.9),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: _ParticlePainter(
        progress: _particleController.value,
        opacity: _fadeAnimation.value,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        ShaderMask(
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
            'Forging Your Path...',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (_userName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _userName,
            style: QuestionnaireTheme.bodyLarge(
              color: QuestionnaireTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressRing() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3 * _progress),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Background ring
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(
                QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Progress ring
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation<Color>(
                QuestionnaireTheme.accentGold,
              ),
            ),
          ),

          // Percentage text
          Text(
            '${(_progress * 100).toInt()}%',
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: QuestionnaireTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Row(
        key: ValueKey(_currentTextIndex),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                QuestionnaireTheme.accentGold.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _loadingTexts[_currentTextIndex],
            style: QuestionnaireTheme.bodyMedium(
              color: QuestionnaireTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                QuestionnaireTheme.accentGold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Creating your personalized experience',
          style: QuestionnaireTheme.bodySmall(
            color: QuestionnaireTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Particle painter for ambient effect
class _ParticlePainter extends CustomPainter {
  final double progress;
  final double opacity;
  final Random _random = Random(42); // Fixed seed for consistent particles

  _ParticlePainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QuestionnaireTheme.accentGold.withValues(alpha: 0.4 * opacity)
      ..style = PaintingStyle.fill;

    // Generate particles
    for (int i = 0; i < 20; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final particleProgress = (progress + i * 0.05) % 1.0;

      // Floating upward motion
      final x = baseX + sin(particleProgress * pi * 2 + i) * 20;
      final y = baseY - particleProgress * size.height * 0.3;

      // Fade particles at edges
      final fadeY = 1.0 - (y / size.height).clamp(0.0, 1.0);
      final particleOpacity = fadeY * 0.6;

      paint.color = QuestionnaireTheme.accentGold.withValues(alpha: particleOpacity * opacity);

      final radius = 2.0 + _random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y % size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress || opacity != oldDelegate.opacity;
}
