import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/series_model.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/onboarding_flow/controller/download_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart'; // Add this
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeriesPlayerController extends GetxController {
  final AudioService _audioService =
      Get.find<AudioService>(); // Use global service
  final SeriesModel series;
  EpisodeModel episode;

  SeriesPlayerController({required this.series, required this.episode});

  // Player state - now reading from global service
  var isLoading = false.obs;
  var isBuffering = false.obs;
  var isLocked = false.obs;
  var isFavorite = false.obs;
  var isDownloaded = false.obs;
  RxBool isLoggedIn = false.obs;

  // Episode navigation
  var currentEpisodeIndex = 0.obs;
  var hasNextEpisode = false.obs;
  var hasPreviousEpisode = false.obs;

  // UI state
  var isDescriptionExpanded = false.obs;

  // Getters for global audio state
  bool get isPlaying => _audioService.isPlaying.value;
  int get currentPosition => _audioService.currentPosition.value;
  int get totalDuration => _audioService.totalDuration.value;
  bool get hasActiveAudio => _audioService.hasActiveAudio.value;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() async {
    try {
      _initializeEpisode();
      await checkIsLoggedIn();
      await _checkLockStatus();

      // Check if this is the same episode already playing
      final bool isSameEpisodePlaying =
          hasActiveAudio &&
          _audioService.currentTitle.value == episode.title &&
          _audioService.currentAudioData.value?['id'] == episode.id;

      if (!isLocked.value && isLoggedIn.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isSameEpisodePlaying) {
            _preloadAndPlayAudio();
          } else {
            debugPrint('🎵 Same episode already playing globally - Syncing UI');
            isLoading.value = false;
          }
        });
      }

      debugPrint(
        '🎵 SeriesPlayer initialized - isLoggedIn: ${isLoggedIn.value}, isLocked: ${isLocked.value}',
      );
    } catch (e) {
      debugPrint('❌ Error initializing SeriesPlayerController: $e');
    }
  }

  Future<void> checkIsLoggedIn() async {
    try {
      final token = await SharedPrefHelper.getAccessToken();
      isLoggedIn.value = (token != null && token.isNotEmpty);
      debugPrint('✅ Login check complete: ${isLoggedIn.value}');
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      isLoggedIn.value = false;
    }
  }

  Future<void> _checkLockStatus() async {
    try {
      bool isItemIntrinsicallyLocked = episode.accessType == 'PAID';

      if (!isLoggedIn.value) {
        // Guest user: Locked if item is PAID
        isLocked.value = isItemIntrinsicallyLocked;
      } else {
        // Logged in user: Check subscription
        bool hasActiveSubscription = false;
        bool isTrialActive = false;

        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          hasActiveSubscription =
              profileController.activeSubscription.value == true;
          isTrialActive = profileController.isTrialExpired.value == false;
        }

        if (hasActiveSubscription || isTrialActive) {
          isLocked.value = false; // Unlock everything for subscribers
        } else {
          isLocked.value = isItemIntrinsicallyLocked;
        }
      }

      debugPrint('🔒 Lock status: ${isLocked.value}');
    } catch (e) {
      debugPrint('❌ Error checking lock status: $e');
      // Fallback safe default
      if (episode.accessType == 'PAID') isLocked.value = true;
    }
  }

  void _initializeEpisode() {
    _updateEpisodeNavigation();
    checkIfDownloaded();
  }

  @override
  void onClose() {
    // Don't stop audio when closing - let AudioService manage it globally
    debugPrint(
      '🎵 SeriesPlayerController closed - Audio continues playing globally',
    );
    super.onClose();
  }

  void _updateEpisodeNavigation() {
    currentEpisodeIndex.value = series.episodes.indexWhere(
      (ep) => ep.id == episode.id,
    );

    if (currentEpisodeIndex.value == -1) {
      currentEpisodeIndex.value = 0;
    }

    hasPreviousEpisode.value = currentEpisodeIndex.value > 0;
    hasNextEpisode.value =
        currentEpisodeIndex.value < series.episodes.length - 1;
  }

  void togglePlayPause() async {
    if (isLocked.value || !isLoggedIn.value) {
      _showPremiumRequired();
      return;
    }

    try {
      if (_audioService.isPlaying.value) {
        await _audioService.pauseAudio();
        debugPrint('⏸️ Audio paused through global service');
      } else {
        // If audio was stopped, restart it
        if (!_audioService.hasActiveAudio.value) {
          _preloadAndPlayAudio();
        } else {
          await _audioService.resumeAudio();
          debugPrint('▶️ Audio resumed through global service');
        }
      }
    } catch (e) {
      debugPrint('❌ Play/Pause error: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle playback',
       
      );
    }
  }

  void _preloadAndPlayAudio() async {
    if (isLocked.value || !isLoggedIn.value) {
      debugPrint(
        '⚠️ Cannot play audio - Locked: ${isLocked.value}, LoggedIn: ${isLoggedIn.value}',
      );
      return;
    }

    isLoading.value = true;
    try {
      // Create complete audio data for series episode
      final fullAudioData = {
        'id': episode.id,
        'title': episode.title,
        'author': episode.author,
        'imageUrl': episode.thumbnail,
        'description': episode.description,
        'audio': episode.content,
        'duration': totalDuration ~/ 60,
        'contentType': 'series',
        'seriesId': series.id,
        'seriesTitle': series.title,
        'episodeNumber': currentEpisodeIndex.value + 1,
        'totalEpisodes': series.episodes.length,
        'series': series,
        'episode': episode,
      };

      await _audioService.playAudio(
        url: episode.content,
        title: episode.title,
        author: episode.author,
        imageUrl: episode.thumbnail,
        fullAudioData: fullAudioData,
      );

      isLoading.value = false;
      debugPrint(
        '✅ Audio playback started successfully through global service',
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Audio playback error: $e');
      Get.snackbar(
        'Error',
        'Failed to load audio',
      
      );
    }
  }

  void seekTo(double value) async {
    if (isLocked.value) return;

    try {
      final newPosition = (value * _audioService.totalDuration.value).round();
      await _audioService.seekTo(newPosition);
      debugPrint('🔍 Seeked to position: $newPosition seconds');
    } catch (e) {
      debugPrint('❌ Error seeking: $e');
      Get.snackbar(
        'Error',
        'Failed to seek',
      
      );
    }
  }

  void skipForward() async {
    if (isLocked.value) return;
    await _skip(15);
  }

  void skipBackward() async {
    if (isLocked.value) return;
    await _skip(-15);
  }

  Future<void> _skip(int seconds) async {
    try {
      final newPosition = (_audioService.currentPosition.value + seconds).clamp(
        0,
        _audioService.totalDuration.value,
      );
      await _audioService.seekTo(newPosition);
      debugPrint(
        '⏩ Skipped ${seconds > 0 ? 'forward' : 'backward'} by ${seconds.abs()} seconds',
      );
    } catch (e) {
      debugPrint('❌ Error skipping: $e');
      Get.snackbar(
        'Error',
        'Failed to skip',
       
      );
    }
  }

  void playNextEpisode() async {
    if (!hasNextEpisode.value) return;
    final nextEpisode = series.episodes[currentEpisodeIndex.value + 1];
    await playEpisode(nextEpisode);
  }

  void playPreviousEpisode() async {
    if (!hasPreviousEpisode.value) return;
    final prevEpisode = series.episodes[currentEpisodeIndex.value - 1];
    await playEpisode(prevEpisode);
  }

  Future<void> playEpisode(EpisodeModel newEpisode) async {
    try {
      final token = await SharedPrefHelper.getAccessToken();

      if (token == null) {
        Get.snackbar(
          'Error',
          'Please login to continue',
        
        );
        return;
      }

      isLoading.value = true;

      // Track progress
      final response = await ApiService.post(
        endpoint: 'series/progress',
        body: {"seriesId": newEpisode.id, "categoryId": series.id},
        token: token,
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Progress tracked for episode: ${newEpisode.id}');
        await _switchToEpisode(newEpisode);
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Failed to track progress',
        
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Error playing episode: $e');
      Get.snackbar(
        'Error',
        'Failed to play episode: $e',
      );
    }
  }

  Future<void> _switchToEpisode(EpisodeModel newEpisode) async {
    try {
      debugPrint('🔄 Switching to episode: ${newEpisode.title}');

      // Update episode
      episode = newEpisode;

      // Re-initialize for new episode
      _initializeEpisode();
      await _checkLockStatus(); // Check lock status for new episode

      // Update UI
      update();

      // Small delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Start playing new audio through global service
      if (!isLocked.value && isLoggedIn.value) {
        _preloadAndPlayAudio();
      }

      debugPrint('✅ Successfully switched to episode: ${newEpisode.title}');
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Episode switch error: $e');
      Get.snackbar(
        'Error',
        'Failed to switch episode',
      );
    }
  }

  void downloadAudio() async {
    if (isLocked.value) {
      _showPremiumRequired();
      return;
    }

    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Downloading Audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      Map<String, dynamic> audioData = {
        'id': episode.id,
        'title': episode.title,
        'description': episode.description,
        'content': episode.content,
        'thumbnail': episode.thumbnail,
        'category': episode.content,
        'duration': totalDuration,
      };

      bool success = await SimpleAudioStorage.saveAudio(audioData);
      Get.back();

      if (success) {
        checkIfDownloaded();
        Get.snackbar(
          'Success',
          'Audio downloaded for offline playback',
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to download audio',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('❌ Download error: $e');
      Get.snackbar(
        'Error',
        'Download failed: $e',
        duration: Duration(seconds: 2),
      );
    }
  }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void checkIfDownloaded() async {
    debugPrint('📥 Checking if audio ${episode.id} is downloaded...');
    bool downloaded = await SimpleAudioStorage.isDownloaded(episode.id);
    debugPrint('Download status: $downloaded');
    isDownloaded.value = downloaded;
  }

  void deleteAudio() async {
    try {
      debugPrint('🗑️ Deleting audio ${episode.id}...');
      await SimpleAudioStorage.deleteAudio(episode.id);
      checkIfDownloaded();
      Get.snackbar(
        'Deleted',
        'Audio removed from offline storage',
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete audio: $e',
        duration: Duration(seconds: 2),
      );
    }
  }

  void getFullAccess() {
    Get.to(() => const SubscriptionScreenV2());
  }

  void _showPremiumRequired() {
    Get.snackbar(
      'Premium Required',
      'This episode requires a premium subscription',
      duration: const Duration(seconds: 2),
    );
  }

  String get formattedCurrentTime {
    final minutes = _audioService.currentPosition.value ~/ 60;
    final seconds = _audioService.currentPosition.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTotalTime {
    final minutes = _audioService.totalDuration.value ~/ 60;
    final seconds = _audioService.totalDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_audioService.totalDuration.value == 0) return 0.0;
    return (_audioService.currentPosition.value /
            _audioService.totalDuration.value)
        .clamp(0.0, 1.0);
  }

  String get episodeProgress {
    return '${currentEpisodeIndex.value + 1} of ${series.episodes.length}';
  }

  List<EpisodeModel> get recommendedEpisodes {
    return series.episodes.where((e) => e.id != episode.id).toList();
  }
}
