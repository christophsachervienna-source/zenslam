import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

class AppLifecycleController extends GetxService with WidgetsBindingObserver {
  final RxBool isAppInForeground = true.obs;
  final IntroAudioController audioController = Get.find<IntroAudioController>();
  final RxBool wasPlayingBeforePause = false.obs;
  final Rx<DateTime?> lastPauseTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🔄 App State: $state');

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      audioController.handleAppPause();
    } else if (state == AppLifecycleState.detached) {
      debugPrint('🛑 App Detached - Forcing Exit');
      exit(0);
    }

    // else if (state == AppLifecycleState.resumed) {
    //   audioController.handleAppResume();
    // }
  }
}
