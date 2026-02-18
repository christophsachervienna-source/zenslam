import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/onboarding_flow/controller/download_controller.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../explore/controller/audio_service.dart';

class AudioPlayerController extends GetxController {
  final AudioService _audioService = Get.find<AudioService>();

  // Observable states
  var isLocked = false.obs;
  var isFavorite = false.obs;
  var isLoading = false.obs;
  var isBuffering = false.obs;
  RxBool isDownloaded = false.obs;
  RxBool isLoggedIn = false.obs;
  var currentItem = Rx<dynamic>(null);
  var currentModelType = RxString('');
  var contentType = ''.obs;
  var errorMessage = ''.obs;

  // Item properties
  var id = ''.obs;
  var author = ''.obs;
  var title = ''.obs;
  var subtitle = ''.obs;
  var imageUrl = ''.obs;
  var audioUrl = ''.obs;
  var category = ''.obs;
  var description = ''.obs;
  var durationText = ''.obs;
  var isDescriptionExpanded = false.obs;
  final duration = Rx<Duration>(Duration.zero);
  var categoryName = ''.obs;
  var accessType = ''.obs;

  static const int _skipDurationSeconds = 15;
  static const int _defaultDurationMinutes = 10;

  // Getters for global audio state
  bool get isPlaying => _audioService.isPlaying.value;
  int get currentPosition => _audioService.currentPosition.value;
  int get totalDuration => _audioService.totalDuration.value;
  bool get hasActiveAudio => _audioService.hasActiveAudio.value;
  String get currentGlobalTitle => _audioService.currentTitle.value;
  String get currentGlobalAuthor => _audioService.currentAuthor.value;
  String get currentGlobalImageUrl => _audioService.currentImageUrl.value;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() async {
    try {
      _extractArgumentsFromRoute();
      await checkIsLoggedIn();
      await _checkLockStatus(); // Correctly calculate lock status
      _scheduleDownloadCheck();

      // Check if this is the same audio that's already playing globally
      final bool isSameAudioPlaying =
          hasActiveAudio &&
          currentGlobalTitle == title.value &&
          currentGlobalAuthor == author.value;

      // CRITICAL FIX: Only play if NOT locked
      if (!isLocked.value) {
        debugPrint('✅ Content unlocked - Starting playback');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isSameAudioPlaying) {
            _startPlayback();
          } else {
            debugPrint('🎵 Same audio already playing globally - Syncing UI');
            isLoading.value = false;
          }
        });
      } else {
        debugPrint('🔒 Content locked - NOT starting playback');
        isLoading.value = false; // Stop loading indicator
      }

      isDescriptionExpanded.value = false;
      debugPrint('Controller initialized - Title: ${title.value}');
      debugPrint(
        'accessType: ${accessType.value}, isLoggedIn: ${isLoggedIn.value}, isLocked: ${isLocked.value}',
      );
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      Get.snackbar('Error', 'Failed to start player');
    }
  }

  void _extractArgumentsFromRoute() {
    try {
      final Map<String, dynamic> arguments = Get.arguments ?? {};

      debugPrint('📋 Extracting arguments from route:');
      debugPrint('   - Raw arguments: ${arguments.keys.toList()}');

      id.value = arguments['id'] ?? '';
      author.value = arguments['author'] ?? '';
      title.value = arguments['title'] ?? 'Unknown Title';
      description.value = arguments['description'] ?? '';
      imageUrl.value = arguments['imageUrl'] ?? '';
      audioUrl.value = arguments['audio'] ?? '';
      category.value = arguments['category'] ?? '';
      isLocked.value = arguments['isLocked'] ?? false;
      isFavorite.value = arguments['isFavorite'] ?? false;
      currentItem.value = arguments['item'];
      currentModelType.value = arguments['modelType'] ?? '';
      categoryName.value = arguments['categoryName'] ?? '';
      accessType.value = arguments['accessType'] ?? 'FREE';
      contentType.value = arguments['contentType'] ?? '';

      debugPrint('   - Extracted imageUrl: ${imageUrl.value}');
      debugPrint('   - Extracted title: ${title.value}');
      debugPrint('   - Extracted contentType: ${contentType.value}');

      // Initial lock state - will be corrected by _checkLockStatus
      if (accessType.value == 'PAID') {
        isLocked.value = true;
      } else {
        isLocked.value = false;
      }

      _parseDuration(arguments['duration']);

      debugPrint('📋 Arguments extracted:');
      debugPrint('   - accessType: ${accessType.value}');
      debugPrint('   - isLocked: ${isLocked.value}');
      debugPrint('   - audioUrl: ${audioUrl.value}');
    } catch (e) {
      debugPrint('Error extracting arguments: $e');
    }
  }

  void _parseDuration(dynamic durationArg) {
    try {
      if (durationArg is int) {
        duration.value = Duration(minutes: durationArg);
      } else {
        duration.value = Duration(minutes: _defaultDurationMinutes);
      }
    } catch (e) {
      debugPrint('Error parsing duration: $e');
      duration.value = Duration(minutes: _defaultDurationMinutes);
    }
  }

  void _scheduleDownloadCheck() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        checkIfDownloaded();
      }
    });
  }

  @override
  void onClose() {
    // Don't stop audio when closing this controller - let AudioService manage it globally
    debugPrint(
      '🎵 AudioPlayerController closed - Audio continues playing globally',
    );
    super.onClose();
  }

  Future<void> checkIsLoggedIn() async {
    try {
      final token = await SharedPrefHelper.getAccessToken();
      isLoggedIn.value = (token != null && token.isNotEmpty);
      debugPrint('Login check complete: ${isLoggedIn.value}');
    } catch (e) {
      debugPrint('Error checking login status: $e');
      isLoggedIn.value = false;
    }
  }

  Future<void> _checkLockStatus() async {
    // Use centralized lock helper for consistent behavior across the app
    bool isPaidContent = accessType.value == 'PAID';
    isLocked.value = ContentLockHelper.instance.shouldBlockPlayback(isPaidContent: isPaidContent);
    debugPrint('🔒 Lock status: ${isLocked.value} (isPaid: $isPaidContent)');
  }

  void _startPlayback() async {
    // DOUBLE CHECK: Never play locked content
    if (isLocked.value || audioUrl.value.isEmpty) {
      debugPrint(
        '❌ Cannot play: accessType=${accessType.value}, isLocked=${isLocked.value}',
      );
      isLoading.value = false;
      return;
    }

    debugPrint('▶️ Starting audio playback through global AudioService');
    isLoading.value = true;

    try {
      // Create complete audio data
      final fullAudioData = {
        'id': id.value,
        'author': author.value,
        'imageUrl': imageUrl.value,
        'title': title.value,
        'category': category.value,
        'description': description.value,
        'duration': duration.value.inMinutes,
        'audio': audioUrl.value,
        'item': currentItem.value,
        'accessType': accessType.value,
        'modelType': currentModelType.value,
        'contentType': contentType.value,
        'isLocked': isLocked.value,
        'isFavorite': isFavorite.value,
        'categoryName': categoryName.value,
      };

      await _audioService.playAudio(
        url: audioUrl.value,
        title: title.value,
        author: author.value,
        imageUrl: imageUrl.value,
        fullAudioData: fullAudioData,
      );
      isLoading.value = false;
      debugPrint(
        '✅ Audio playback started successfully through global service',
      );
    } catch (e) {
      debugPrint('Audio playback error: $e');
      isLoading.value = false;
      _showErrorSnackbar('Failed to play audio');
    }
  }

  void togglePlayPause() async {
    // CRITICAL: Check lock status first
    if (isLocked.value) {
      _showPremiumRequired();
      return;
    }

    try {
      if (_audioService.isPlaying.value) {
        await _audioService.pauseAudio();
        debugPrint('⏸️ Audio paused through global service');
      } else {
        // If audio completed or was stopped, restart it from the beginning
        if (!_audioService.hasActiveAudio.value ||
            (_audioService.currentPosition.value == 0 &&
                _audioService.totalDuration.value > 0)) {
          debugPrint('🔄 Restarting audio from beginning');
          _startPlayback();
        } else {
          await _audioService.resumeAudio();
          debugPrint('▶️ Audio resumed through global service');
        }
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
      _showErrorSnackbar('Failed to toggle playback');
    }
  }

  void seekTo(double value) async {
    if (isLocked.value) return;

    try {
      final newPosition = (value * _audioService.totalDuration.value).round();
      await _audioService.seekTo(newPosition);
      debugPrint('🔍 Seeked to position: $newPosition seconds');
    } catch (e) {
      debugPrint('Error seeking: $e');
      _showErrorSnackbar('Failed to seek');
    }
  }

  void skipForward() async {
    if (isLocked.value) return;
    await _skip(_skipDurationSeconds);
  }

  void skipBackward() async {
    if (isLocked.value) return;
    await _skip(-_skipDurationSeconds);
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
      debugPrint('Error skipping: $e');
      _showErrorSnackbar('Failed to skip');
    }
  }

  // Mini player controls
  void toggleMiniPlayerPlayPause() async {
    try {
      if (_audioService.isPlaying.value) {
        await _audioService.pauseAudio();
      } else {
        await _audioService.resumeAudio();
      }
    } catch (e) {
      debugPrint('Error in mini player toggle: $e');
    }
  }

  void stopAudioGlobally() async {
    await _audioService.stopAudio();
    debugPrint('🛑 Audio stopped globally');
  }

  void navigateToAudioPlayer() {
    if (_audioService.hasActiveAudio.value ||
        _audioService.currentAudioData.value != null) {
      Get.toNamed(
        '/audio-player',
        arguments:
            _audioService.currentAudioData.value ??
            {
              'id': id.value,
              'author': author.value,
              'imageUrl': imageUrl.value,
              'title': title.value,
              'category': category.value,
              'description': description.value,
              'duration': duration.value.inMinutes,
              'audio': audioUrl.value,
              'item': currentItem.value,
              'accessType': accessType.value,
              'modelType': currentModelType.value,
              'contentType': contentType.value,
              'isLocked': isLocked.value,
            },
      );
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    _showSnackbar(
      'Favorite',
      isFavorite.value ? 'Added to favorites' : 'Removed from favorites',
      duration: const Duration(seconds: 2),
    );
  }

  void downloadAudio() async {
    try {
      _showDownloadDialog();

      Map<String, dynamic> audioData = {
        'id': id.value,
        'title': title.value,
        'description': description.value,
        'content': audioUrl.value,
        'thumbnail': imageUrl.value,
        'category': category.value,
        'duration': duration.value,
      };

      bool success = await SimpleAudioStorage.saveAudio(audioData);
      Get.back(); // Close dialog

      if (success) {
        checkIfDownloaded();
        _showSnackbar('Success', 'Audio downloaded for offline playback');
      } else {
        _showErrorSnackbar('Failed to download audio');
      }
    } catch (e) {
      Get.back();
      debugPrint('Download error: $e');
      _showErrorSnackbar('Download failed: $e');
    }
  }

  void _showDownloadDialog() {
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
  }

  void checkIfDownloaded() async {
    try {
      debugPrint('Checking download status for audio: ${id.value}');
      bool downloaded = await SimpleAudioStorage.isDownloaded(id.value);
      if (!isClosed) {
        isDownloaded.value = downloaded;
        debugPrint('Download status: $downloaded');
      }
    } catch (e) {
      debugPrint('Error checking download status: $e');
    }
  }

  void deleteAudio() async {
    try {
      debugPrint('Deleting audio: ${id.value}');
      await SimpleAudioStorage.deleteAudio(id.value);
      checkIfDownloaded();
      _showSnackbar('Deleted', 'Audio removed from offline storage');
    } catch (e) {
      debugPrint('Delete error: $e');
      _showErrorSnackbar('Failed to delete audio: $e');
    }
  }

  void getFullAccess() {
    Get.to(() => const SubscriptionScreenV2());
  }

  void _showPremiumRequired() {
    _showSnackbar(
      'Premium Required',
      'This feature requires premium subscription',
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    _showSnackbar('Error', message);
  }

  void _showSnackbar(
    String title,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(title, message, duration: duration);
  }

  // UI helper methods
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

  Future<void> playNext(
    dynamic model,
    String type,
    String id,
    String contentType,
  ) async {
    debugPrint('🎬 playNext called with:');
    debugPrint('   - model type: ${model.runtimeType}');
    debugPrint('   - modelType param: $type');
    debugPrint('   - id: $id');
    debugPrint('   - contentType: $contentType');

    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    String getImageUrl(dynamic item) {
      try {
        debugPrint('🖼️ Extracting image URL from ${item.runtimeType}');
        if (item.thumbnail != null && item.thumbnail.toString().isNotEmpty) {
          debugPrint('   - Found thumbnail: ${item.thumbnail}');
          return item.thumbnail;
        }
        if (item.imageUrl != null && item.imageUrl.toString().isNotEmpty) {
          debugPrint('   - Found imageUrl: ${item.imageUrl}');
          return item.imageUrl;
        }
        debugPrint('   - No image URL found');
      } catch (e) {
        debugPrint('Error extracting image url: $e');
      }
      return '';
    }

    final String image = getImageUrl(model);
    debugPrint('🖼️ Final image URL: $image');

    // Get audio URL - FavoriteItemData uses 'content', others use 'audio'
    String getAudioUrl(dynamic item) {
      if (item is FavoriteItemData) {
        return item.content;
      }
      try {
        if (item.audio != null) return item.audio;
        if (item.content != null) return item.content;
      } catch (e) {
        debugPrint('Error extracting audio url: $e');
      }
      return '';
    }

    final String audioUrl = getAudioUrl(model);

    // Use centralized lock helper for consistent behavior
    bool isItemLocked = ContentLockHelper.instance.shouldBlockPlayback(
      isPaidContent: model.accessType == 'PAID',
    );
    debugPrint('🔒 Next item lock status: $isItemLocked (accessType: ${model.accessType})');

    // Create complete audio data
    final fullAudioData = {
      'id': model.id,
      'author': model.author,
      'imageUrl': image,
      'title': model.title,
      'category': model.category,
      'description': model.description,
      'duration': model.duration,
      'audio': audioUrl,
      'item': model,
      'accessType': model.accessType,
      'modelType': type,
      'contentType': contentType,
      'isLocked': isItemLocked,
    };

    debugPrint('📦 fullAudioData created:');
    debugPrint('   - id: ${fullAudioData['id']}');
    debugPrint('   - title: ${fullAudioData['title']}');
    debugPrint('   - imageUrl: ${fullAudioData['imageUrl']}');
    debugPrint('   - audio: ${fullAudioData['audio']}');
    debugPrint('   - contentType: ${fullAudioData['contentType']}');

    // If locked, just navigate without playing
    if (isItemLocked) {
      debugPrint('🔒 Next item is locked - Navigating without playing');
      isLoading.value = false;
      Get.offAndToNamed('/audio-player', arguments: fullAudioData);
      return;
    }

    try {
      if (token == null) {
        debugPrint('⚠️ No token - playing without API call');
        await _audioService.playAudio(
          url: audioUrl,
          title: model.title,
          author: model.author,
          imageUrl: image,
          fullAudioData: fullAudioData, // Pass complete data
        );

        Get.offAndToNamed('/audio-player', arguments: fullAudioData);
        return;
      }

      // Call progress tracking API in background (non-blocking)
      // We still navigate and play even if this fails
      debugPrint('📡 Calling content/progress API:');
      debugPrint('   - contentType: $contentType');
      debugPrint('   - contentId: $id');

      // Fire and forget - don't block playback on progress tracking
      ApiService.post(
        endpoint: 'content/progress',
        body: {"contentType": contentType, "contentId": id},
        token: token,
      ).then((response) {
        debugPrint('📡 API Response: ${response.data}');
        if (response.data['success'] != true) {
          debugPrint('⚠️ Progress tracking failed: ${response.data['message']}');
        }
      }).catchError((e) {
        debugPrint('⚠️ Progress tracking error: $e');
      });

      // Always play and navigate regardless of progress API result
      await _audioService.playAudio(
        url: audioUrl,
        title: model.title,
        author: model.author,
        imageUrl: image,
        fullAudioData: fullAudioData,
      );

      Get.offAndToNamed('/audio-player', arguments: fullAudioData);
    } catch (e) {
      errorMessage.value = 'Failed to play audio: $e';
      debugPrint('Error in audio player: $e');
      Get.snackbar('Error', 'Failed to play audio');
    } finally {
      isLoading.value = false;
    }
  }
}
