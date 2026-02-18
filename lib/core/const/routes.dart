import 'package:zenslam/app/explore/view/audio_player_screen.dart';
import 'package:zenslam/app/meditation_timer/view/meditation_timer_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/premium_splash_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/premium_onboarding_screen.dart';
import 'package:zenslam/app/splash/cinematic_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Custom transition for audio player to prevent white flash
class CustomAudioPlayerTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Container(
      color: const Color(0xFF0A0A0C), // Match audio player background
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class AppRoutes {
  static const String splash = '/splash';
  static const String premiumSplash = '/premium-splash';
  static const String onboarding = '/onboarding';
  static const String premiumOnboarding = '/premium-onboarding';
  static const String audioPlayer = '/audio-player';
  static const String meditationTimer = '/meditation-timer';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const CinematicSplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: premiumSplash,
      page: () => const PremiumSplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => const PremiumOnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: premiumOnboarding,
      page: () => const PremiumOnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: audioPlayer,
      page: () => AudioPlayerScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 100),
      customTransition: CustomAudioPlayerTransition(),
    ),
    GetPage(
      name: meditationTimer,
      page: () => const MeditationTimerScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
