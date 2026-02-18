import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleAudioStorage {
  static const String _downloadsListKey = 'downloaded_audio_ids';

  // Save audio to SharedPreferences and download file
  static Future<bool> saveAudio(
    Map<String, dynamic> audioData, {
    Function(int, int, double)? onProgress, // Updated to include MB
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String audioId = audioData['id'];
      String audioKey = 'audio_$audioId';

      // Download and store audio file locally
      String? localFilePath = await _downloadAndSaveAudio(
        audioData['content'], // audio URL
        audioData['title'], // file name
        audioId, // unique ID
        onProgress, // Pass progress callback
      );

      if (localFilePath == null) {
        debugPrint('Failed to download audio file');
        return false;
      }
      await _downloadAndSaveThumbnail(
        audioData['thumbnail'] ?? audioData['imageUrl'] ?? '',
        audioId,
      );
      // Store all audio data under one key as JSON string
      final Map<String, dynamic> storageData = {
        'id': audioId,
        'title': audioData['title'],
        'description': audioData['description'],
        'content': audioData['content'], // Keep original URL as backup
        'localPath': localFilePath, // Store local file path for offline play
        'thumbnail': audioData['thumbnail'],
        'category': audioData['category'],
        'duration': audioData['duration'].inSeconds,
        'downloadedAt': DateTime.now().toIso8601String(),
        'fileSize': await _getFileSize(localFilePath),
      };

      // Save the audio data
      await prefs.setString(audioKey, json.encode(storageData));

      // Add to downloads list
      List<String> downloads = prefs.getStringList(_downloadsListKey) ?? [];
      if (!downloads.contains(audioId)) {
        downloads.add(audioId);
        await prefs.setStringList(_downloadsListKey, downloads);
      }

      debugPrint('Audio downloaded and saved: ${audioData['title']}');
      debugPrint('Local path: $localFilePath');
      return true;
    } catch (e) {
      debugPrint('Error saving audio: $e');
      return false;
    }
  }

  static Future<String?> _downloadAndSaveThumbnail(
    String thumbnailUrl,
    String audioId,
  ) async {
    try {
      if (thumbnailUrl.isEmpty) return null;

      final Directory directory = await getApplicationDocumentsDirectory();
      final String thumbnailsPath = '${directory.path}/audio_thumbnails';

      final Directory thumbnailsDir = Directory(thumbnailsPath);
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      // Get file extension from URL or default to .jpg
      String extension = '.jpg';
      if (thumbnailUrl.toLowerCase().contains('.png')) {
        extension = '.png';
      } else if (thumbnailUrl.toLowerCase().contains('.jpeg')) {
        extension = '.jpeg';
      }

      final String filePath = '$thumbnailsPath/thumbnail_$audioId$extension';

      final response = await http.get(Uri.parse(thumbnailUrl));
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading thumbnail: $e');
      return null;
    }
  }

  // Download and save audio file locally
  static Future<String?> _downloadAndSaveAudio(
    String audioUrl,
    String title,
    String audioId,
    Function(int, int, double)? onProgress,
  ) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String downloadsPath = '${directory.path}/audio_downloads';

      final Directory downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final String filePath =
          '$downloadsPath/${_sanitizeFileName(audioId)}.mp3';

      // Create the request
      var request = await http.Client().send(
        http.Request('GET', Uri.parse(audioUrl)),
      );

      // Get total content length
      int totalBytes = request.contentLength ?? 0;
      int downloadedBytes = 0;

      // Open file for writing
      final File file = File(filePath);
      final IOSink sink = file.openWrite();

      // Stream the response and update progress
      await for (var chunk in request.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        // Call progress callback if provided
        if (onProgress != null) {
          double downloadedMB =
              downloadedBytes / (1024 * 1024); // Convert to MB
          onProgress(downloadedBytes, totalBytes, downloadedMB);
        }
      }

      await sink.close();
      return filePath;
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      return null;
    }
  }

  static Future<String?> getLocalThumbnailPath(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String audioKey = 'audio_$audioId';
      String? audioDataString = prefs.getString(audioKey);

      if (audioDataString != null) {
        Map<String, dynamic> audioData = json.decode(audioDataString);
        String? localThumbnailPath = audioData['localThumbnailPath'];

        if (localThumbnailPath != null &&
            await _fileExists(localThumbnailPath)) {
          return localThumbnailPath;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local thumbnail path: $e');
      return null;
    }
  }

  // ... rest of your SimpleAudioStorage methods remain the same
  static Future<int> _getFileSize(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[-\s]+'), '_');
  }

  // Get all downloaded audios for display in downloads section
  static Future<List<Map<String, dynamic>>> getAllDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> downloads = prefs.getStringList(_downloadsListKey) ?? [];

      List<Map<String, dynamic>> audios = [];

      for (String audioId in downloads) {
        String audioKey = 'audio_$audioId';
        String? audioDataString = prefs.getString(audioKey);

        if (audioDataString != null) {
          Map<String, dynamic> audioData = json.decode(audioDataString);
          // Verify the local file still exists
          if (await _fileExists(audioData['localPath'])) {
            audios.add(audioData);
          } else {
            // Remove from downloads if file doesn't exist
            await deleteAudio(audioId);
          }
        }
      }

      return audios;
    } catch (e) {
      debugPrint('Error getting downloads: $e');
      return [];
    }
  }

  // Check if file exists
  static Future<bool> _fileExists(String? filePath) async {
    if (filePath == null) return false;
    try {
      File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get local file path for offline playback
  static Future<String?> getLocalAudioPath(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String audioKey = 'audio_$audioId';
      String? audioDataString = prefs.getString(audioKey);

      if (audioDataString != null) {
        Map<String, dynamic> audioData = json.decode(audioDataString);
        String? localPath = audioData['localPath'];

        if (localPath != null && await _fileExists(localPath)) {
          return localPath;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local path: $e');
      return null;
    }
  }

  // Check if audio is downloaded and available for offline play
  static Future<bool> isDownloaded(String audioId) async {
    try {
      final localPath = await getLocalAudioPath(audioId);
      return localPath != null;
    } catch (e) {
      return false;
    }
  }

  // Delete a downloaded audio (both from storage and SharedPreferences)
  static Future<void> deleteAudio(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First delete the local audio file
      String? localPath = await getLocalAudioPath(audioId);
      if (localPath != null) {
        File file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // ✅ Delete the local thumbnail file
      String? localThumbnailPath = await getLocalThumbnailPath(audioId);
      if (localThumbnailPath != null) {
        File thumbnailFile = File(localThumbnailPath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      // Remove from downloads list
      List<String> downloads = prefs.getStringList(_downloadsListKey) ?? [];
      downloads.remove(audioId);
      await prefs.setStringList(_downloadsListKey, downloads);

      // Remove audio data
      await prefs.remove('audio_$audioId');

      debugPrint('Audio and thumbnail deleted: $audioId');
    } catch (e) {
      debugPrint('Error deleting audio: $e');
    }
  }

  // Get audio data for playback
  static Future<Map<String, dynamic>?> getAudio(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String audioKey = 'audio_$audioId';
      String? audioDataString = prefs.getString(audioKey);

      if (audioDataString != null) {
        return json.decode(audioDataString);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting audio: $e');
      return null;
    }
  }
}

class DownloadController extends GetxController {
  var downloadedAudios = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    loadDownloads();
    super.onInit();
  }

  Future<void> loadDownloads() async {
    isLoading.value = true;
    try {
      final downloads = await SimpleAudioStorage.getAllDownloads();
      downloadedAudios.value = downloads;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
