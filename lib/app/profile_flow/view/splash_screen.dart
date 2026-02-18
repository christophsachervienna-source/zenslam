import 'dart:math' as math;
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashScreenController controller;

  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _loadingOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashScreenController());

    // Logo entrance animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Continuous pulse animation for the ring
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Fade in sequence
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Loading dots animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Logo scale with elastic effect
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo opacity
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text fade in (delayed)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    // Tagline fade in (more delayed)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Loading indicator fade in
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0C),
              const Color(0xFF0D0D10),
              const Color(0xFF101014),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle background pattern
            _buildBackgroundEffects(),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Animated logo
                    _buildAnimatedLogo(),

                    const SizedBox(height: 32),

                    // App name
                    _buildAppName(),

                    const SizedBox(height: 12),

                    // Tagline
                    _buildTagline(),

                    const Spacer(flex: 2),

                    // Loading indicator
                    _buildLoadingIndicator(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-left glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.08 + (_pulseAnimation.value * 0.04)),
                      AppColors.primaryColor.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-right glow
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.06 + (_pulseAnimation.value * 0.03)),
                      AppColors.primaryColor.withValues(alpha: 0.01),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        final pulseValue = _pulseAnimation.value;

        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  Container(
                    width: 140 + (20 * pulseValue),
                    height: 140 + (20 * pulseValue),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(
                          alpha: 0.3 * (1 - pulseValue),
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Second pulse ring (delayed)
                  Container(
                    width: 140 + (40 * pulseValue),
                    height: 140 + (40 * pulseValue),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(
                          alpha: 0.15 * (1 - pulseValue),
                        ),
                        width: 1,
                      ),
                    ),
                  ),

                  // Main circle with gradient border
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D0D10),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withValues(alpha: 0.8),
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'M',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: -2,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textOpacity.value)),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.9),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'Zenslam',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
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
      animation: _taglineOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - _taglineOpacity.value)),
            child: Text(
              'Elevate Your Mind',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textSecondary,
                letterSpacing: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: Listenable.merge([_loadingOpacity, _loadingController]),
      builder: (context, child) {
        return Opacity(
          opacity: _loadingOpacity.value,
          child: SizedBox(
            width: 60,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final animValue = ((_loadingController.value + delay) % 1.0);
                final scale = 0.5 + (math.sin(animValue * math.pi) * 0.5);
                final opacity = 0.3 + (math.sin(animValue * math.pi) * 0.7);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withValues(alpha: opacity),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: opacity * 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
