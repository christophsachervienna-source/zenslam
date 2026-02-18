import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Controller for the meditation timer feature
/// Handles timer state, breathing patterns, and ambient sounds
class MeditationTimerController extends GetxController {
  // ═══════════════════════════════════════════════════════════════════════════
  // TIMER STATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Selected duration in minutes
  final duration = 10.obs;

  /// Remaining time in seconds
  final remainingSeconds = 0.obs;

  /// Whether the timer is currently running
  final isRunning = false.obs;

  /// Whether the timer is paused
  final isPaused = false.obs;

  /// Whether the meditation session is complete
  final isComplete = false.obs;

  /// Whether countdown is active (5, 4, 3, 2, 1 before meditation)
  final isCountingDown = false.obs;

  /// Current countdown value (5 to 1)
  final countdownValue = 5.obs;

  /// Timer instance
  Timer? _timer;

  /// Countdown timer instance
  Timer? _countdownTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // BREATHING PATTERN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main breathing patterns (shown by default)
  static const List<BreathingPattern> breathingPatterns = [
    BreathingPattern(
      id: 'box',
      name: 'Box Breathing',
      description: '4s inhale, 4s hold, 4s exhale, 4s hold',
      inhale: 4,
      holdIn: 4,
      exhale: 4,
      holdOut: 4,
    ),
    BreathingPattern(
      id: '478',
      name: '4-7-8 Breathing',
      description: '4s inhale, 7s hold, 8s exhale',
      inhale: 4,
      holdIn: 7,
      exhale: 8,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'relaxing',
      name: 'Relaxing Breath',
      description: '4s inhale, 6s exhale',
      inhale: 4,
      holdIn: 0,
      exhale: 6,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'none',
      name: 'No Guide',
      description: 'Timer only, no breathing guide',
      inhale: 0,
      holdIn: 0,
      exhale: 0,
      holdOut: 0,
    ),
  ];

  /// Extended breathing patterns (shown under "More")
  static const List<BreathingPattern> extendedBreathingPatterns = [
    BreathingPattern(
      id: 'coherent',
      name: 'Coherent Breathing',
      description: '5s inhale, 5s exhale - heart coherence',
      inhale: 5,
      holdIn: 0,
      exhale: 5,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'resonant',
      name: 'Resonant Breathing',
      description: '6s inhale, 6s exhale - deep calm',
      inhale: 6,
      holdIn: 0,
      exhale: 6,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'extended_box',
      name: 'Extended Box',
      description: '5s inhale, 5s hold, 5s exhale, 5s hold',
      inhale: 5,
      holdIn: 5,
      exhale: 5,
      holdOut: 5,
    ),
    BreathingPattern(
      id: 'deep_calm',
      name: 'Deep Calm',
      description: '6s inhale, 2s hold, 8s exhale',
      inhale: 6,
      holdIn: 2,
      exhale: 8,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'triangle',
      name: 'Triangle Breathing',
      description: '5s inhale, 5s hold, 5s exhale',
      inhale: 5,
      holdIn: 5,
      exhale: 5,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'physiological_sigh',
      name: 'Physiological Sigh',
      description: '4s inhale, 8s long exhale - stress management',
      inhale: 4,
      holdIn: 0,
      exhale: 8,
      holdOut: 0,
    ),
    BreathingPattern(
      id: 'ocean_breath',
      name: 'Ocean Breath',
      description: '6s inhale, 6s exhale, 2s pause',
      inhale: 6,
      holdIn: 0,
      exhale: 6,
      holdOut: 2,
    ),
  ];

  /// All breathing patterns combined
  static List<BreathingPattern> get allBreathingPatterns => [
        ...breathingPatterns,
        ...extendedBreathingPatterns,
      ];

  /// Selected breathing pattern
  final selectedPattern = breathingPatterns[0].obs;

  /// Current breath phase (inhale, holdIn, exhale, holdOut)
  final currentBreathPhase = 'inhale'.obs;

  /// Seconds remaining in current breath phase
  final breathPhaseRemaining = 0.obs;

  /// Timer for breathing animation
  Timer? _breathTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // SOUND SELECTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Available ambient sounds (fetched from API)
  final ambientSounds = <AmbientSound>[
    AmbientSound(id: 'silence', name: 'Silence', icon: Icons.volume_off),
  ].obs;

  /// Whether sounds are loading from API
  final isLoadingSounds = false.obs;

  /// Selected ambient sound
  final selectedSound =
      AmbientSound(id: 'silence', name: 'Silence', icon: Icons.volume_off)
          .obs;

  /// Audio players
  final AudioPlayer _gongPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  /// Ambient sound volume
  final ambientVolume = 0.5.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // DURATION PRESETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Quick duration presets in minutes
  static const List<int> durationPresets = [5, 10, 15, 20, 30];

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    remainingSeconds.value = duration.value * 60;
    _configureAudioPlayers();
    _fetchAmbientSounds();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _breathTimer?.cancel();
    _countdownTimer?.cancel();
    _gongPlayer.dispose();
    _ambientPlayer.dispose();
    super.onClose();
  }

  void _configureAudioPlayers() {
    _gongPlayer.setReleaseMode(ReleaseMode.stop);
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set timer duration in minutes
  void setDuration(int minutes) {
    if (!isRunning.value) {
      duration.value = minutes;
      remainingSeconds.value = minutes * 60;
    }
  }

  /// Start the meditation timer
  void startTimer() {
    if (isRunning.value && !isPaused.value) return;

    HapticFeedback.mediumImpact();

    // If resuming from pause, skip countdown
    if (isPaused.value) {
      _resumeFromPause();
      return;
    }

    // Start fresh session with countdown
    remainingSeconds.value = duration.value * 60;
    isComplete.value = false;
    isRunning.value = true;
    isPaused.value = false;

    // Start countdown before meditation
    _startCountdown();
  }

  /// Start the 5-4-3-2-1 countdown before meditation
  void _startCountdown() {
    isCountingDown.value = true;
    countdownValue.value = 5;

    HapticFeedback.mediumImpact();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue.value > 1) {
        countdownValue.value--;
        HapticFeedback.selectionClick();
      } else {
        // Countdown finished, start actual meditation
        timer.cancel();
        _countdownTimer = null;
        isCountingDown.value = false;
        _beginMeditation();
      }
    });
  }

  /// Begin the actual meditation after countdown
  void _beginMeditation() {
    HapticFeedback.mediumImpact();

    // Keep screen awake during meditation
    WakelockPlus.enable();

    // Start ambient sound if selected
    _playAmbientSound();

    // Start breathing guide if pattern selected
    if (selectedPattern.value.id != 'none') {
      _startBreathingGuide();
    }

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _completeSession();
      }
    });
  }

  /// Resume meditation from paused state
  void _resumeFromPause() {
    isPaused.value = false;

    // Resume ambient sound
    _playAmbientSound();

    // Resume breathing guide if pattern selected (continue from current phase)
    if (selectedPattern.value.id != 'none') {
      _resumeBreathingGuide();
    }

    // Resume countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _completeSession();
      }
    });
  }

  /// Resume breathing guide from current phase (after pause)
  void _resumeBreathingGuide() {
    final pattern = selectedPattern.value;
    if (pattern.id == 'none') return;

    // Continue from current phase - the breath timer will handle phase transitions

    // Restart the breath timer to continue the cycle
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isRunning.value || isPaused.value) {
        timer.cancel();
        return;
      }

      if (breathPhaseRemaining.value > 1) {
        breathPhaseRemaining.value--;
      } else {
        _advanceBreathPhase();
      }
    });

    // Notify listeners that we're resuming (trigger animation update)
    // Force a phase change notification by temporarily changing and reverting
    currentBreathPhase.refresh();
  }

  /// Pause the timer
  void pauseTimer() {
    if (!isRunning.value || isPaused.value) return;

    HapticFeedback.lightImpact();

    isPaused.value = true;
    _timer?.cancel();
    _breathTimer?.cancel();
    _ambientPlayer.pause();
  }

  /// Resume the timer
  void resumeTimer() {
    if (!isPaused.value) return;
    startTimer();
  }

  /// Stop the timer and reset
  void stopTimer() {
    HapticFeedback.lightImpact();

    _timer?.cancel();
    _breathTimer?.cancel();
    _countdownTimer?.cancel();
    _ambientPlayer.stop();

    // Allow screen to sleep again
    WakelockPlus.disable();

    isRunning.value = false;
    isPaused.value = false;
    isComplete.value = false;
    isCountingDown.value = false;
    countdownValue.value = 5;
    remainingSeconds.value = duration.value * 60;
    currentBreathPhase.value = 'inhale';
    breathPhaseRemaining.value = 0;
  }

  /// Complete the meditation session
  void _completeSession() {
    _timer?.cancel();
    _breathTimer?.cancel();
    _ambientPlayer.stop();

    // Allow screen to sleep again
    WakelockPlus.disable();

    isRunning.value = false;
    isPaused.value = false;
    isComplete.value = true;

    HapticFeedback.heavyImpact();
    _playGong();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BREATHING GUIDE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Select a breathing pattern
  void selectPattern(BreathingPattern pattern) {
    if (!isRunning.value) {
      selectedPattern.value = pattern;
      HapticFeedback.selectionClick();
    }
  }

  /// Start the breathing guide cycle
  void _startBreathingGuide() {
    final pattern = selectedPattern.value;
    if (pattern.id == 'none') return;

    currentBreathPhase.value = 'inhale';
    breathPhaseRemaining.value = pattern.inhale;

    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isRunning.value || isPaused.value) {
        timer.cancel();
        return;
      }

      if (breathPhaseRemaining.value > 1) {
        breathPhaseRemaining.value--;
      } else {
        _advanceBreathPhase();
      }
    });
  }

  /// Advance to the next breath phase
  void _advanceBreathPhase() {
    final pattern = selectedPattern.value;

    switch (currentBreathPhase.value) {
      case 'inhale':
        if (pattern.holdIn > 0) {
          currentBreathPhase.value = 'holdIn';
          breathPhaseRemaining.value = pattern.holdIn;
        } else {
          currentBreathPhase.value = 'exhale';
          breathPhaseRemaining.value = pattern.exhale;
        }
        break;
      case 'holdIn':
        currentBreathPhase.value = 'exhale';
        breathPhaseRemaining.value = pattern.exhale;
        break;
      case 'exhale':
        if (pattern.holdOut > 0) {
          currentBreathPhase.value = 'holdOut';
          breathPhaseRemaining.value = pattern.holdOut;
        } else {
          currentBreathPhase.value = 'inhale';
          breathPhaseRemaining.value = pattern.inhale;
        }
        break;
      case 'holdOut':
        currentBreathPhase.value = 'inhale';
        breathPhaseRemaining.value = pattern.inhale;
        break;
    }

    // Subtle haptic on phase change
    HapticFeedback.selectionClick();
  }

  /// Get the current breath instruction text
  String get breathInstruction {
    switch (currentBreathPhase.value) {
      case 'inhale':
        return 'Breathe In';
      case 'holdIn':
        return 'Hold';
      case 'exhale':
        return 'Breathe Out';
      case 'holdOut':
        return 'Hold';
      default:
        return '';
    }
  }

  /// Get the animation scale for breathing circle
  double get breathScale {
    final pattern = selectedPattern.value;
    if (pattern.id == 'none') return 1.0;

    switch (currentBreathPhase.value) {
      case 'inhale':
        return 1.0; // Expanding
      case 'holdIn':
        return 1.0; // Held expanded
      case 'exhale':
        return 0.6; // Contracting
      case 'holdOut':
        return 0.6; // Held contracted
      default:
        return 0.8;
    }
  }

  /// Get duration for breath phase animation
  Duration get breathPhaseDuration {
    final pattern = selectedPattern.value;
    if (pattern.id == 'none') return Duration.zero;

    switch (currentBreathPhase.value) {
      case 'inhale':
        return Duration(seconds: pattern.inhale);
      case 'holdIn':
        return Duration(seconds: pattern.holdIn);
      case 'exhale':
        return Duration(seconds: pattern.exhale);
      case 'holdOut':
        return Duration(seconds: pattern.holdOut);
      default:
        return const Duration(seconds: 4);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOUND METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Select an ambient sound
  void selectSound(AmbientSound sound) {
    selectedSound.value = sound;
    HapticFeedback.selectionClick();

    // If timer is running, switch the sound
    if (isRunning.value && !isPaused.value) {
      _playAmbientSound();
    }
  }

  /// Set ambient sound volume
  void setAmbientVolume(double volume) {
    ambientVolume.value = volume;
    _ambientPlayer.setVolume(volume);
  }

  /// Play selected ambient sound
  Future<void> _playAmbientSound() async {
    final sound = selectedSound.value;
    if (sound.id == 'silence' || sound.audioUrl == null) {
      await _ambientPlayer.stop();
      return;
    }

    try {
      await _ambientPlayer.setVolume(ambientVolume.value);
      final cachedPath = await _getCachedPath(sound.id);
      if (File(cachedPath).existsSync()) {
        await _ambientPlayer.play(DeviceFileSource(cachedPath));
      } else {
        await _ambientPlayer.play(UrlSource(sound.audioUrl!));
        _downloadAndCache(sound.audioUrl!, sound.id);
      }
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
    }
  }

  /// Play the completion gong
  Future<void> _playGong() async {
    try {
      await _gongPlayer.setVolume(1.0);
      await _gongPlayer.play(AssetSource('audio/gong.mp3'));
    } catch (e) {
      debugPrint('Error playing gong: $e');
    }
  }

  /// Preview a sound
  Future<void> previewSound(AmbientSound sound) async {
    if (sound.id == 'silence' || sound.audioUrl == null) return;

    try {
      await _ambientPlayer.setVolume(0.5);
      final cachedPath = await _getCachedPath(sound.id);
      if (File(cachedPath).existsSync()) {
        await _ambientPlayer.play(DeviceFileSource(cachedPath));
      } else {
        await _ambientPlayer.play(UrlSource(sound.audioUrl!));
        _downloadAndCache(sound.audioUrl!, sound.id);
      }

      // Stop after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!isRunning.value) {
          _ambientPlayer.stop();
        }
      });
    } catch (e) {
      debugPrint('Error previewing sound: $e');
    }
  }

  /// Stop sound preview
  void stopPreview() {
    if (!isRunning.value) {
      _ambientPlayer.stop();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REMOTE SOUND FETCHING & CACHING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch ambient sounds from the API
  Future<void> _fetchAmbientSounds() async {
    isLoadingSounds.value = true;
    try {
      final response = await ApiService.get(
        endpoint: 'meditation-sounds',
        handleAuth: false,
      );

      if (response.success && response.data != null) {
        final List<dynamic> soundList = response.data['data'] ?? [];
        final fetched = soundList
            .map((json) => AmbientSound.fromJson(json as Map<String, dynamic>))
            .toList();

        ambientSounds.value = [
          AmbientSound(
              id: 'silence', name: 'Silence', icon: Icons.volume_off),
          ...fetched,
        ];
      }
    } catch (e) {
      debugPrint('Error fetching ambient sounds: $e');
    } finally {
      isLoadingSounds.value = false;
    }
  }

  /// Get the local cache path for a sound file
  Future<String> _getCachedPath(String soundId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/meditation_sounds/$soundId.mp3';
  }

  /// Download a sound file and cache it locally
  Future<void> _downloadAndCache(String url, String soundId) async {
    try {
      final cachedPath = await _getCachedPath(soundId);
      final file = File(cachedPath);
      if (file.existsSync()) return;

      await file.parent.create(recursive: true);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Cached sound: $soundId');
      }
    } catch (e) {
      debugPrint('Error caching sound $soundId: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    final total = duration.value * 60;
    if (total == 0) return 0;
    return 1 - (remainingSeconds.value / total);
  }

  /// Reset the controller for a new session
  void reset() {
    stopTimer();
    isComplete.value = false;
  }
}

/// Model for breathing patterns
class BreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
  });

  /// Total cycle duration in seconds
  int get cycleDuration => inhale + holdIn + exhale + holdOut;
}

/// Model for ambient sounds
class AmbientSound {
  final String id;
  final String name;
  final IconData icon;
  final String? audioUrl;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.icon,
    this.audioUrl,
  });

  factory AmbientSound.fromJson(Map<String, dynamic> json) {
    return AmbientSound(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: _iconFromString(json['icon'] ?? ''),
      audioUrl: json['audioUrl'],
    );
  }

  static IconData _iconFromString(String name) {
    switch (name) {
      case 'water_drop':
        return Icons.water_drop;
      case 'forest':
        return Icons.forest;
      case 'waves':
        return Icons.waves;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'volume_off':
        return Icons.volume_off;
      case 'music_note':
        return Icons.music_note;
      case 'spa':
        return Icons.spa;
      case 'air':
        return Icons.air;
      default:
        return Icons.music_note;
    }
  }
}
