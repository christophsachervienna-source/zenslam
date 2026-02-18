// services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
// ignore: depend_on_referenced_packages
import 'package:audio_session/audio_session.dart' as audio_session;
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/controller/audio_notification_handler.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart' as audio_service_pkg;
import 'package:shared_preferences/shared_preferences.dart';

class AudioService extends GetxService {
  // FIXED: Changed from Get.put to Get.find to get existing instance
  static AudioService get instance {
    try {
      return Get.find<AudioService>();
    } catch (e) {
      debugPrint('❌ AudioService not found in GetX, attempting to create...');
      throw Exception('AudioService must be initialized in main() before use');
    }
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  late audio_service_pkg.AudioHandler _audioHandler;

  // Session tracking for soft upsell
  static const String _sessionCountKey = 'meditation_session_count';
  static const int _upsellFrequency = 3; // Show upsell every 3rd session

  // Global states
  var isPlaying = false.obs;
  var currentPosition = 0.obs;
  var totalDuration = 0.obs;
  var currentTitle = ''.obs;
  var currentAuthor = ''.obs;
  var currentImageUrl = ''.obs;
  var hasActiveAudio = false.obs;
  var isBuffering = false.obs;

  // Store complete audio data for navigation
  var currentAudioData = Rx<Map<String, dynamic>?>(null);

  // Store current audio URL for resuming
  String? _currentAudioUrl;

  // Flag to track if service is initialized
  bool _isInitialized = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    // onInit is now lightweight. Initialization happens via init() called from main.dart
  }

  Future<void> init() async {
    debugPrint('🎵 Initializing AudioService...');
    try {
      await _initAudioService();
      await _configureAudioSession();
      _setupListeners();
      _configureAudioPlayer();
      _isInitialized = true;
      debugPrint('✅ AudioService initialized successfully');
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR initializing AudioService: $e');
      debugPrint(
        '👉 Verify that MainActivity extends AudioServiceActivity or AudioServiceFragmentActivity',
      );
      // Do not rethrow here, so the app can continue even if audio fails
    }
  }

  Future<void> _initAudioService() async {
    try {
      _audioHandler = await audio_service_pkg.AudioService.init(
        builder: () => SimpleAudioHandler(),
        config: const audio_service_pkg.AudioServiceConfig(
          androidNotificationChannelId: 'com.zenslam.channel.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          notificationColor: Colors.blue,
        ),
      );

      // Connect the handler to this service
      (_audioHandler as SimpleAudioHandler).setAudioService(this);
      debugPrint('🔗 Audio handler connected');
    } catch (e) {
      debugPrint('❌ Error initializing audio service: $e');
      rethrow;
    }
  }

  void _configureAudioPlayer() {
    try {
      // Configure for background playback
      audioPlayer.setReleaseMode(ReleaseMode.stop);
      audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Enable background audio for iOS and Android
      audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      debugPrint('🔊 Audio player configured');
    } catch (e) {
      debugPrint('❌ Error configuring audio player: $e');
    }
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await audio_session.AudioSession.instance;
      await session.configure(
        audio_session.AudioSessionConfiguration(
          avAudioSessionCategory: audio_session.AVAudioSessionCategory.playback,
          avAudioSessionMode: audio_session.AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: audio_session.AndroidAudioAttributes(
            contentType: audio_session.AndroidAudioContentType.music,
            usage: audio_session.AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType:
              audio_session.AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );

      // Listen for audio interruptions (phone calls, etc.)
      session.interruptionEventStream.listen((event) {
        debugPrint(
          '🔔 Audio interruption: ${event.type}, begin: ${event.begin}',
        );

        if (event.begin) {
          // Interruption started (e.g., phone call)
          switch (event.type) {
            case audio_session.AudioInterruptionType.pause:
            case audio_session.AudioInterruptionType.unknown:
              debugPrint('📞 Phone call detected - pausing audio');
              pauseAudio();
              break;
            case audio_session.AudioInterruptionType.duck:
              // Lower volume instead of pausing
              debugPrint('🔉 Ducking audio');
              break;
          }
        } else {
          // Interruption ended
          debugPrint(
            '📞 Phone call ended - audio remains paused (user can resume manually)',
          );
          // Don't auto-resume - let user decide when to resume
        }
      });

      // Listen for audio focus changes
      session.becomingNoisyEventStream.listen((_) {
        debugPrint('🎧 Headphones disconnected - pausing audio');
        pauseAudio();
      });

      debugPrint('🎧 Audio session configured with interruption handling');
    } catch (e) {
      debugPrint('❌ Error configuring audio session: $e');
    }
  }

  void _setupListeners() {
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlaying.value = state == PlayerState.playing;
      debugPrint('🎵 Player state: $state');

      if (state == PlayerState.playing ||
          state == PlayerState.paused ||
          state == PlayerState.stopped) {
        isBuffering.value = false;
      }

      // Update audio_service playback state
      _updatePlaybackState();
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      totalDuration.value = duration.inSeconds;
      debugPrint('⏱️ Duration: ${duration.inSeconds}s');
      _updatePlaybackState();
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      currentPosition.value = position.inSeconds;
    });

    audioPlayer.onPlayerComplete.listen((_) async {
      isPlaying.value = false;
      currentPosition.value = 0;
      isBuffering.value = false;
      await audioPlayer.seek(Duration.zero);
      debugPrint('✅ Audio completed');
      _updatePlaybackState();

      // Track session and potentially show soft upsell
      await _handleMeditationComplete();
    });
  }

  void _updatePlaybackState() {
    if (!_isInitialized) return;

    try {
      (_audioHandler as SimpleAudioHandler).updateCurrentMediaItem(
        title: currentTitle.value,
        artist: currentAuthor.value,
        artUri: currentImageUrl.value,
      );
    } catch (e) {
      debugPrint('❌ Error updating playback state: $e');
    }
  }

  Future<void> playAudio({
    required String url,
    required String title,
    required String author,
    required String imageUrl,
    Map<String, dynamic>? fullAudioData,
  }) async {
    debugPrint('🎵 playAudio called - initialized: $_isInitialized');

    if (!_isInitialized) {
      debugPrint('❌ AudioService not initialized');
      return;
    }

    try {
      isBuffering.value = true;
      debugPrint('▶️ Playing: $title by $author');

      currentTitle.value = title;
      currentAuthor.value = author;
      currentImageUrl.value = imageUrl;
      hasActiveAudio.value = true;
      _currentAudioUrl = url;

      if (fullAudioData != null) {
        currentAudioData.value = fullAudioData;
      }

      // Update notification first
      _updatePlaybackState();

      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url), mode: PlayerMode.mediaPlayer);

      isBuffering.value = false;
      debugPrint('✅ Audio started playing');
    } catch (e) {
      isBuffering.value = false;
      debugPrint('❌ Error playing audio: $e');
      Get.snackbar(
        'Error',
        'Failed to play audio: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> pauseAudio() async {
    if (!_isInitialized) return;

    try {
      await audioPlayer.pause();
      debugPrint('⏸️ Audio paused');
    } catch (e) {
      debugPrint('❌ Error pausing audio: $e');
    }
  }

  Future<void> resumeAudio() async {
    if (!_isInitialized) return;

    try {
      if (_currentAudioUrl != null && hasActiveAudio.value) {
        await audioPlayer.resume();
        debugPrint('▶️ Audio resumed');
      }
    } catch (e) {
      debugPrint('❌ Error resuming audio: $e');
    }
  }

  Future<void> stopAudio() async {
    if (!_isInitialized) return;

    try {
      await audioPlayer.stop();
      hasActiveAudio.value = false;
      currentPosition.value = 0;
      isBuffering.value = false;
      _currentAudioUrl = null;
      debugPrint('⏹️ Audio stopped');
    } catch (e) {
      debugPrint('❌ Error stopping audio: $e');
    }
  }

  Future<void> seekTo(int seconds) async {
    if (!_isInitialized) return;

    try {
      isBuffering.value = true;
      await audioPlayer.seek(Duration(seconds: seconds));
      isBuffering.value = false;
      debugPrint('⏩ Seeked to ${seconds}s');
    } catch (e) {
      isBuffering.value = false;
      debugPrint('❌ Error seeking audio: $e');
    }
  }

  void clearAudioData() {
    currentAudioData.value = null;
    hasActiveAudio.value = false;
    currentTitle.value = '';
    currentAuthor.value = '';
    currentImageUrl.value = '';
    isBuffering.value = false;
    _currentAudioUrl = null;
  }

  /// Handle meditation completion: track session count and show soft upsell for free users
  Future<void> _handleMeditationComplete() async {
    try {
      // Check if user is subscribed
      bool isSubscribed = false;
      bool isLoggedIn = false;

      final token = await SharedPrefHelper.getAccessToken();
      isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn && Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        isSubscribed = profileController.activeSubscription.value == true ||
            profileController.isTrialExpired.value == false;
      }

      // Don't show upsell to subscribed users
      if (isSubscribed) {
        debugPrint('🎯 User is subscribed - skipping soft upsell');
        return;
      }

      // Increment session count
      final prefs = await SharedPreferences.getInstance();
      int sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
      sessionCount++;
      await prefs.setInt(_sessionCountKey, sessionCount);
      debugPrint('🧘 Meditation session completed. Total sessions: $sessionCount');

      // Show soft upsell every Nth session
      if (sessionCount % _upsellFrequency == 0) {
        debugPrint('🎁 Showing soft upsell (session $sessionCount)');
        // Delay slightly to let the completion state settle
        await Future.delayed(const Duration(milliseconds: 500));
        _showSoftUpsellBottomSheet();
      }
    } catch (e) {
      debugPrint('❌ Error handling meditation complete: $e');
    }
  }

  /// Show soft upsell bottom sheet with gentle upgrade prompt
  void _showSoftUpsellBottomSheet() {
    final context = Get.context;
    if (context == null) {
      debugPrint('❌ No context available for bottom sheet');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, Color(0xFFB8956E)],
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF1A1A2E),
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Headline
              Text(
                'Enjoying Zenslam?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Subtext
              Text(
                'Unlock unlimited access to 120+ tennis mental training sessions\nand elevate your game.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Primary CTA - Start Free Trial
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => const SubscriptionScreenV2());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start Free Trial',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary CTA - Maybe Later
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  child: Text(
                    'Maybe Later',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() async {
    try {
      if (_isInitialized) {
        await _audioHandler.stop();
        final handler = _audioHandler as SimpleAudioHandler;
        handler.dispose();
      }
      await audioPlayer.dispose();
      debugPrint('🔒 AudioService closed');
    } catch (e) {
      debugPrint('❌ Error closing AudioService: $e');
    }
    super.onClose();
  }
}
