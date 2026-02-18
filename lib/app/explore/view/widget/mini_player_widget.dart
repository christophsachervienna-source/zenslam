// widgets/mini_player_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:zenslam/app/home_flow/model/series_player_screen.dart';
import 'package:zenslam/app/home_flow/model/series_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiniPlayerWidget extends StatelessWidget {
  final AudioService audioService = Get.find<AudioService>();

  MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show mini player if we have audio data (even if stopped)
      if (audioService.currentAudioData.value == null) return SizedBox.shrink();

      return Container(
        height: 70,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xff202E3C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _openAudioPlayer,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  // Thumbnail
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: audioService.currentImageUrl.value,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Title and progress
                  Expanded(
                    child: Text(
                      audioService.currentTitle.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      audioService.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),

                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: _stopAudio,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _togglePlayPause() async {
    if (audioService.isPlaying.value) {
      await audioService.pauseAudio();
    } else {
      // If audio was stopped, restart it
      if (!audioService.hasActiveAudio.value &&
          audioService.currentAudioData.value != null) {
        final audioData = audioService.currentAudioData.value!;
        await audioService.playAudio(
          url: audioData['audio'] ?? '',
          title: audioData['title'] ?? '',
          author: audioData['author'] ?? '',
          imageUrl: audioData['imageUrl'] ?? '',
          fullAudioData: audioData,
        );
      } else {
        await audioService.resumeAudio();
      }
    }
  }

  void _stopAudio() {
    audioService.stopAudio();
    audioService.clearAudioData(); // Clear data to hide mini player
  }

  void _openAudioPlayer() async {
    final audioData = audioService.currentAudioData.value;

    if (audioData == null) {
      debugPrint('❌ No audio data available');
      return;
    }

    try {
      // If audio was stopped but we have data, restart it before navigating
      if (!audioService.hasActiveAudio.value) {
        await audioService.playAudio(
          url: audioData['audio'] ?? '',
          title: audioData['title'] ?? '',
          author: audioData['author'] ?? '',
          imageUrl: audioData['imageUrl'] ?? '',
          fullAudioData: audioData,
        );
      }

      // Check content type to determine navigation
      final contentType = audioData['contentType'] ?? '';

      if (contentType == 'series') {
        // Navigate to series player with series and episode data
        debugPrint('🎵 Navigating to SeriesPlayerScreen');

        final seriesData = audioData['series'];
        final episodeData = audioData['episode'];

        if (seriesData != null && episodeData != null) {
          // If we have the full models, use them directly
          Get.to(
            () => SeriesPlayerScreen(),
            arguments: {
              'series': seriesData is SeriesModel
                  ? seriesData
                  : _reconstructSeriesModel(audioData),
              'episode': episodeData is EpisodeModel
                  ? episodeData
                  : _reconstructEpisodeModel(audioData),
            },
          );
        } else {
          // Fallback: reconstruct models from stored data
          debugPrint('⚠️ Reconstructing series/episode from audio data');
          Get.to(
            () => SeriesPlayerScreen(),
            arguments: {
              'series': _reconstructSeriesModel(audioData),
              'episode': _reconstructEpisodeModel(audioData),
            },
          );
        }
      } else {
        // Navigate to regular audio player
        debugPrint('🎵 Navigating to AudioPlayerScreen');
        Get.toNamed('/audio-player', arguments: audioData);
      }
    } catch (e) {
      debugPrint('❌ Error opening audio player: $e');
      Get.snackbar('Error', 'Failed to open player');
    }
  }

  // Helper method to reconstruct SeriesModel from audio data
  SeriesModel _reconstructSeriesModel(Map<String, dynamic> audioData) {
    try {
      // Try to get the full series object first
      if (audioData['series'] != null && audioData['series'] is SeriesModel) {
        return audioData['series'] as SeriesModel;
      }

      // Otherwise reconstruct from available data
      return SeriesModel(
        id: audioData['seriesId'] ?? audioData['id'] ?? '',
        name: audioData['seriesTitle'] ?? audioData['title'] ?? '',
        title: audioData['seriesTitle'] ?? audioData['title'] ?? '',
        description: audioData['description'] ?? '',
        thumbnail: audioData['imageUrl'] ?? '',
        episodes: [
          _reconstructEpisodeModel(audioData),
        ], // At least include current episode
      );
    } catch (e) {
      debugPrint('❌ Error reconstructing SeriesModel: $e');
      rethrow;
    }
  }

  // Helper method to reconstruct EpisodeModel from audio data
  // Helper method to reconstruct EpisodeModel from audio data
  EpisodeModel _reconstructEpisodeModel(Map<String, dynamic> audioData) {
    try {
      // Try to get the full episode object first
      if (audioData['episode'] != null &&
          audioData['episode'] is EpisodeModel) {
        return audioData['episode'] as EpisodeModel;
      }

      // Otherwise reconstruct from available data with required parameters
      return EpisodeModel(
        id: audioData['id'] ?? '',
        title: audioData['title'] ?? '',
        description: audioData['description'] ?? '',
        accessType: audioData['accessType'] ?? 'free', // Provide default value
        content: audioData['audio'] ?? '',
        thumbnail: audioData['imageUrl'] ?? '',
        author: audioData['author'] ?? '',
        duration:
            audioData['duration']?.toString() ??
            '0', // Convert to String if needed
        views: audioData['views'] ?? 0, // Provide default value
        spendTime: audioData['spendTime'] ?? 0, // Provide default value
        serialNo: audioData['serialNo'],
        createdAt:
            audioData['createdAt'] ??
            DateTime.now().toIso8601String(), // Provide default
        updatedAt:
            audioData['updatedAt'] ??
            DateTime.now().toIso8601String(), // Provide default
      );
    } catch (e) {
      debugPrint('❌ Error reconstructing EpisodeModel: $e');
      rethrow;
    }
  }
}
