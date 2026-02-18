import 'package:audio_service/audio_service.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart'
    as app_audio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleAudioHandler extends BaseAudioHandler with SeekHandler {
  app_audio.AudioService? myAudioService;
  MediaItem? _currentMediaItem;
  Worker? _isPlayingWorker;
  Worker? _positionWorker;
  Worker? _durationWorker;
  Worker? _bufferingWorker;

  SimpleAudioHandler() {
    // Set initial state
    playbackState.add(
      PlaybackState(
        controls: [MediaControl.play, MediaControl.stop],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  void setAudioService(app_audio.AudioService audioService) {
    debugPrint('🔗 SimpleAudioHandler.setAudioService called');
    myAudioService = audioService;
    _setupListeners();
    debugPrint('🔗 SimpleAudioHandler connected to AudioService');
  }

  void _setupListeners() {
    final audioService = myAudioService;
    if (audioService == null) return;

    // Listen to playing state changes
    _isPlayingWorker = ever(audioService.isPlaying, (dynamic value) {
      final bool isPlaying = value as bool? ?? false;
      final currentState = playbackState.value;
      playbackState.add(
        currentState.copyWith(
          controls: isPlaying
              ? [MediaControl.pause, MediaControl.stop]
              : [MediaControl.play, MediaControl.stop],
          androidCompactActionIndices: const [0, 1],
          processingState:
              currentState.processingState == AudioProcessingState.buffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.ready,
          playing: isPlaying,
          //updateTime: DateTime.now(),
        ),
      );
    });

    // Listen to position changes
    _positionWorker = ever(audioService.currentPosition, (dynamic value) {
      final int position = value as int? ?? 0;
      final currentState = playbackState.value;
      playbackState.add(
        currentState.copyWith(updatePosition: Duration(seconds: position)),
      );
    });

    // Listen to duration changes
    _durationWorker = ever(audioService.totalDuration, (dynamic value) {
      final int duration = value as int? ?? 0;
      if (_currentMediaItem != null && duration > 0) {
        _currentMediaItem = _currentMediaItem!.copyWith(
          duration: Duration(seconds: duration),
        );
        mediaItem.add(_currentMediaItem);
      }
    });

    // Listen to buffering state
    _bufferingWorker = ever(audioService.isBuffering, (dynamic value) {
      final bool buffering = value as bool? ?? false;
      final currentState = playbackState.value;
      playbackState.add(
        currentState.copyWith(
          processingState: buffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.ready,
        ),
      );
    });
  }

  @override
  Future<void> play() async {
    debugPrint('▶️ SimpleAudioHandler.play() called');
    if (myAudioService == null) {
      debugPrint('❌ play() failed: myAudioService is null');
      return;
    }

    if (!myAudioService!.hasActiveAudio.value) {
      debugPrint('⚠️ play() skipped: hasActiveAudio is false');
      return;
    }

    await myAudioService!.resumeAudio();

    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        androidCompactActionIndices: const [0, 1],
        playing: true,
        processingState: AudioProcessingState.ready,
      ),
    );
  }

  @override
  Future<void> pause() async {
    debugPrint('⏸️ SimpleAudioHandler.pause() called');
    if (myAudioService == null) {
      debugPrint('❌ pause() failed: myAudioService is null');
      return;
    }

    await myAudioService!.pauseAudio();

    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.play, MediaControl.stop],
        androidCompactActionIndices: const [0, 1],
        playing: false,
        processingState: AudioProcessingState.ready,
      ),
    );
  }

  @override
  Future<void> stop() async {
    debugPrint('⏹️ SimpleAudioHandler.stop() called');
    if (myAudioService == null) {
      debugPrint('❌ stop() failed: myAudioService is null');
      return;
    }

    await myAudioService!.stopAudio();

    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.play],
        androidCompactActionIndices: const [0],
        playing: false,
        processingState: AudioProcessingState.idle,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
      ),
    );

    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('⏩ SimpleAudioHandler.seek() called: ${position.inSeconds}s');
    if (myAudioService == null) {
      debugPrint('❌ seek() failed: myAudioService is null');
      return;
    }

    await myAudioService!.seekTo(position.inSeconds);

    playbackState.add(playbackState.value.copyWith(updatePosition: position));
  }

  @override
  Future<void> onTaskRemoved() async {
    debugPrint('🗑️ App task removed - stopping audio and exiting');
    await stop();
    await super.onTaskRemoved();
    exit(0);
  }

  /// Downloads and caches the image, returning a local file URI
  Future<Uri?> _getCachedImagePath(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return null;

      // Use CachedNetworkImage's cache manager to get the cached file
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getSingleFile(imageUrl);

      if (await file.exists()) {
        // Return file:// URI for the notification system
        return Uri.file(file.path);
      }
    } catch (e) {
      debugPrint('Error caching notification image: $e');
    }
    return null;
  }

  void updateCurrentMediaItem({
    required String title,
    required String artist,
    String? artUri,
  }) async {
    final int durationInSeconds = myAudioService?.totalDuration.value ?? 0;

    // Pre-cache the image and get local file URI
    Uri? cachedArtUri;
    if (artUri != null && artUri.isNotEmpty) {
      cachedArtUri = await _getCachedImagePath(artUri);
    }

    _currentMediaItem = MediaItem(
      id: 'audio_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artist: artist,
      artUri: cachedArtUri,
      duration: durationInSeconds > 0
          ? Duration(seconds: durationInSeconds)
          : null,
    );

    mediaItem.add(_currentMediaItem);
  }

  void dispose() {
    _isPlayingWorker?.dispose();
    _positionWorker?.dispose();
    _durationWorker?.dispose();
    _bufferingWorker?.dispose();
  }
}
