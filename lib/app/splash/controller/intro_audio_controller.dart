// intro_audio_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class IntroAudioController extends GetxService {
  final AudioPlayer audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      debugPrint('🎵 Audio state: $state');
    });
  }

  Future<void> playIntroAudio() async {
    try {
      debugPrint('🎵 Starting audio...');
      await audioPlayer.play(AssetSource('audios/intro_audio.mp3'));
      debugPrint('🎵 Audio started');
    } catch (e) {
      debugPrint('🎵 Error: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      debugPrint('🎵 Stopping audio...');
      await audioPlayer.stop();
      debugPrint('🎵 Audio stopped');
    } catch (e) {
      debugPrint('🎵 Error: $e');
    }
  }

  Future<void> handleAppPause() async {
    debugPrint('🎵 App paused, stopping audio...');
    await stopAudio();
  }

  Future<void> handleAppResume() async {
    debugPrint('🎵 App resumed, restarting audio...');
    await playIntroAudio();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
