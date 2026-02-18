import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/data/mock_content_provider.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/mentor_flow/controller/most_popular_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MostPopularController extends GetxController {
  var popularItems = <MostPopularModel>[].obs;
  RxBool isLoading = false.obs;
  var isLoadingMore = false.obs; // For pagination loading
  RxString errorMessage = ''.obs;
  RxBool isLoggedIn = false.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10; // Items per page

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    fetchPopularItems();
  }

  void loadUserName() async {
    isLoggedIn.value = (await SharedPrefHelper.getAccessToken() != null);
    debugPrint('Is logged in: ${isLoggedIn.value}');
  }

  Future<void> fetchPopularItems({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final token = await SharedPrefHelper.getAccessToken();

      final response = await ApiService.get(
        endpoint: 'content/popular',
        token: token,
        queryParameters: {
          'page': loadMore ? currentPage.value.toString() : '1',
          'limit': limit.toString(),
        },
      );

      debugPrint('📦 Full API Response: ${response.data}');

      if (response.data['success'] == true) {
        final mostPopularResponse = MostPopularResponse.fromJson(response.data);
        final mostPopularData = mostPopularResponse.data;

        if (loadMore) {
          // Append to existing items
          popularItems.addAll(mostPopularData.data);
          currentPage.value++;
        } else {
          // Replace existing items
          popularItems.value = mostPopularData.data;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = mostPopularData.hasMore;

        debugPrint(
          '🎯 Most Popular Items Loaded: ${popularItems.length}, Has more: ${hasMore.value}',
        );
      } else {
        debugPrint('API Error: ${response.data['message']}');
        if (!loadMore) {
          popularItems.value = MockContentProvider.getMostPopular();
          hasMore.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching popular items: $e — using static fallback');
      errorMessage.value = '';
      if (!loadMore) {
        popularItems.value = MockContentProvider.getMostPopular();
        hasMore.value = false;
      }
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Load more content for pagination
  Future<void> loadMorePopular() async {
    await fetchPopularItems(loadMore: true);
  }

  // Refresh popular items
  Future<void> refreshPopular() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchPopularItems();
  }

  Future<void> playPopular(
    MostPopularModel popularItem,
    String type,
    String id,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    try {
      if (token == null) {
        Get.toNamed(
          '/audio-player',
          arguments: {
            'id': popularItem.id,
            'author': popularItem.author,
            'imageUrl': popularItem.imageUrl,
            'title': popularItem.title,
            'category': popularItem.category,
            'description': popularItem.description,
            'duration': popularItem.duration,
            'audio': popularItem.audio,
            'accessType': popularItem.accessType,
            'item': popularItem,
            'modelType': 'MostPopularModel',
            'contentType': popularItem
                .contentType[Random().nextInt(popularItem.contentType.length)],
          },
        );
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
        debugPrint('ID: $id');

        Get.toNamed(
          '/audio-player',
          arguments: {
            'id': popularItem.id,
            'author': popularItem.author,
            'imageUrl': popularItem.imageUrl,
            'title': popularItem.title,
            'category': popularItem.category,
            'description': popularItem.description,
            'duration': popularItem.duration,
            'audio': popularItem.audio,
            'item': popularItem,
            'accessType': popularItem.accessType,
            'modelType': 'MostPopularModel',
            'contentType': popularItem
                .contentType[Random().nextInt(popularItem.contentType.length)],
          },
        );
      } else {
        // Handle API error response
        final errorMsg =
            response.data['message']?.toString() ?? 'Unknown error occurred';
        errorMessage.value = errorMsg;
        debugPrint('API Error: $errorMsg');
        Get.snackbar(
          'Failed to play audio',
          'Make sure you are connected to the internet',
        );
      }
    } catch (e) {
      // Handle network/parsing errors
      errorMessage.value = 'Failed to play audio: $e';
      debugPrint('Error in playDailies: $e');
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
