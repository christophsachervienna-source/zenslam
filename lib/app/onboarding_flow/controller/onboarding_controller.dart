import 'package:zenslam/app/splash/controller/app_life_cycle_controller.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Observable variable to track current onboarding step
  RxInt currentStep = 0.obs;
  final IntroAudioController audioController = Get.find<IntroAudioController>();
  final AppLifecycleController lifecycleController =
      Get.find<AppLifecycleController>();

  // Onboarding content data
  final List<OnboardingContent> onboardingData = [
    OnboardingContent(
      // title: "Zenslam",
      subtitle:
          // "Welcome! Every step you take brings\nyou closer to your goals.Keep \npushing forward!",
          "Most men are asleep... \nYou won’t be!",
    ),
    OnboardingContent(
      title: "Zenslam",
      // subtitle: "Guided Meditations for Men",
      subtitle: "Awaken the real man within you...",
    ),
    OnboardingContent(
      title: "Become the man you\nwere meant to be...",
      subtitle: "Let's personalize your journey.",
    ),
  ];

  // Move to next step
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    } else {
      // When user completes onboarding and moves to next screen
      stopAudioAndNavigate();
    }
  }

  // Future<void> _startAudio() async {
  //   try {
  //     // Only play audio if app is in foreground
  //     if (lifecycleController.isAppInForeground.value) {
  //       debugPrint('SplashScreen: Starting audio playback...');
  //       await audioController.playIntroAudio();
  //       debugPrint('SplashScreen: Audio playback started successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('SplashScreen: Error starting audio: $e');
  //   }
  // }

  void stopAudioAndNavigate() async {
    audioController.stopAudio();
  }

  // Check if it's the last step
  bool get isLastStep => currentStep.value == 2;

  // Get current content
  OnboardingContent get currentContent => onboardingData[currentStep.value];
  @override
  void onClose() {
    audioController.stopAudio();
    super.onClose();
  }
}

class OnboardingContent {
  String? title;
  final String subtitle;

  OnboardingContent({this.title, required this.subtitle});
}
