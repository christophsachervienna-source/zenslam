import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/masterpiece/awakening_screen.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';

/// Minimal Splash Screen
/// Shows centered logo with subtle zoom, navigates as soon as app is ready
class CinematicSplashScreen extends StatefulWidget {
  const CinematicSplashScreen({super.key});

  @override
  State<CinematicSplashScreen> createState() => _CinematicSplashScreenState();
}

class _CinematicSplashScreenState extends State<CinematicSplashScreen>
    with SingleTickerProviderStateMixin {
  // Background color matching the logo background (pure black)
  static const Color _backgroundColor = Color(0xFF000000);

  // Subtle zoom animation controller
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  // Navigation state
  bool _isNavigating = false;
  Widget? _navigationTarget;

  // Audio controller
  IntroAudioController? _audioController;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initAudio();
    _checkLoginStatus();
  }

  void _initAudio() {
    try {
      _audioController = Get.find<IntroAudioController>();
      _audioController?.playIntroAudio();
    } catch (_) {
      // Controller not available, audio won't play
    }
  }

  void _initAnimation() {
    // Continuous subtle zoom (1.0 to 1.05 over 2 seconds, loops)
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the subtle zoom animation
    _zoomController.repeat(reverse: true);
  }

  Future<void> _checkLoginStatus() async {
    // Check login status in parallel for faster startup
    final results = await Future.wait([
      SharedPrefHelper.getAccessToken(),
      SharedPrefHelper.getIsOnboardingCompleted(),
    ]);
    final token = results[0] as String?;
    final isOnboardingCompleted = results[1] as bool?;

    if (token != null || isOnboardingCompleted == true) {
      // User is logged in or completed onboarding
      // Initialize notifications in background (don't block navigation)
      NotificationService.initialize();
      _navigationTarget = NavBarScreen();
    } else {
      // New user, go to masterpiece onboarding
      _navigationTarget = const AwakeningScreen();
    }

    // Navigate immediately when ready
    _navigateToTarget();
  }

  void _navigateToTarget() {
    if (_isNavigating || _navigationTarget == null) return;
    _isNavigating = true;

    // Small delay for smooth transition (just enough for visual continuity)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Get.off(
          () => _navigationTarget!,
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: _backgroundColor,
        systemNavigationBarColor: _backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: AnimatedBuilder(
            animation: _zoomAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _zoomAnimation.value,
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/app-logo2.png',
              width: 120,
              height: 120,
            ),
          ),
        ),
      ),
    );
  }
}
