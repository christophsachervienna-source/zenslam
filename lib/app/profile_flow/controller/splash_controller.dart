import 'dart:async';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/premium_onboarding_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/splash/controller/app_life_cycle_controller.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  var isClicked = false.obs;
  final IntroAudioController audioController = Get.find<IntroAudioController>();
  final AppLifecycleController lifecycleController =
      Get.find<AppLifecycleController>();

  void onButtonClick() {
    isClicked.value = true;
  }

  void checkIsLogin() async {
    // Check login status in parallel for faster startup
    final results = await Future.wait([
      SharedPrefHelper.getAccessToken(),
      SharedPrefHelper.getIsOnboardingCompleted(),
    ]);
    final token = results[0] as String?;
    final isOnboardingCompleted = results[1] as bool?;

    // Reduced delay from 3s to 1s for faster startup
    Timer(const Duration(seconds: 1), () async {
      if (token != null) {
        // User is logged in - go to main app
        // Initialize notifications in background (don't block)
        NotificationService.initialize();
        audioController.stopAudio();
        Get.offAll(() => NavBarScreen());
      } else if (token == null && isOnboardingCompleted == true) {
        // Returning user who completed onboarding but not subscribed - show paywall
        audioController.stopAudio();
        Get.offAll(() => const SubscriptionScreenV2());
      } else if (token == null && isOnboardingCompleted == false) {
        // New user - start onboarding flow
        audioController.stopAudio();
        Get.offAll(() => const PremiumOnboardingScreen());
      } else {
        // Fallback - start onboarding
        audioController.stopAudio();
        Get.offAll(() => const PremiumOnboardingScreen());
      }
    });
  }

  Future<void> _startAudio() async {
    try {
      // Only play audio if app is in foreground
      if (lifecycleController.isAppInForeground.value) {
        debugPrint('SplashScreen: Starting audio playback...');
        await audioController.playIntroAudio();
        debugPrint('SplashScreen: Audio playback started successfully');
      }
    } catch (e) {
      debugPrint('SplashScreen: Error starting audio: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkIsLogin();
    _startAudio();
  }
}
