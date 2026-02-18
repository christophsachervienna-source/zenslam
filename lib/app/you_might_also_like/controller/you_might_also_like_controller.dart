import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YouMightAlsoLikeController extends GetxController {
  var rating = 0.obs;
  var dailies = <TodaysDailiesModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isNavigating = false.obs;

  void setRating(int value) {
    rating.value = value;
  }

  /// Extract audio player arguments from any item type
  Map<String, dynamic> _extractItemData(dynamic item, String modelType) {
    // Handle FavoriteItem - content data is nested inside item.item
    if (item is FavoriteItem) {
      final content = item.item;
      return {
        'id': item.itemId,
        'author': content.author,
        'imageUrl': content.thumbnail,
        'title': content.title,
        'category': content.category,
        'description': content.description,
        'duration': content.duration,
        'audio': content.content,
        'item': item,
        'accessType': content.accessType,
        'modelType': modelType,
        'contentType': content.type,
      };
    }

    // Default handling for other models
    String contentType = '';
    if (item.contentType != null && item.contentType is List && item.contentType.isNotEmpty) {
      contentType = item.contentType[Random().nextInt(item.contentType.length)];
    }

    return {
      'id': item.id,
      'author': item.author ?? item.title,
      'imageUrl': item.imageUrl ?? item.thumbnail ?? '',
      'title': item.title,
      'category': item.category ?? '',
      'description': item.description ?? '',
      'duration': item.duration,
      'audio': item.audio ?? item.content ?? '',
      'item': item,
      'accessType': item.accessType ?? 'FREE',
      'modelType': modelType,
      'contentType': contentType,
    };
  }

  Future<void> playLike(
    dynamic daily,
    String type,
    String id,
    String modelType,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    try {
      final itemData = _extractItemData(daily, modelType);

      if (token == null) {
        Get.toNamed('/audio-player', arguments: itemData);
        return;
      }

      final response = await ApiService.post(
        endpoint: 'content/progress',
        body: {"contentType": type, "contentId": id},
        token: token,
      );

      // Check if the request was successful
      if (response.data['success'] == true) {
        debugPrint('Progress API Response: ${response.data}');
        Get.toNamed('/audio-player', arguments: itemData);
      } else {
        // Handle API error response
        final errorMsg =
            response.data['message']?.toString() ?? 'Unknown error occurred';
        errorMessage.value = errorMsg;
        debugPrint('API Error: $errorMsg');
        Get.snackbar('Error', errorMsg);
      }
    } catch (e) {
      // Handle network/parsing errors
      errorMessage.value = 'Failed to play audio: $e';
      debugPrint('Error in playDailies: $e');
      Get.snackbar('Error', 'Failed to play audio');
    } finally {
      isLoading.value = false;
    }
  }
}
