import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/data/mock_content_provider.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodaysDillesController extends GetxController {
  var rating = 0.obs;
  var dailies = <TodaysDailiesModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs; // For pagination loading
  var errorMessage = ''.obs;
  var isNavigating = false.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10; // Items per page

  void setRating(int value) {
    rating.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDailies();
  }

  Future<void> fetchDailies({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
    }

    final token = await SharedPrefHelper.getAccessToken();

    try {
      final response = await ApiService.get(
        endpoint: 'content/todaydailies',
        token: token,
        queryParameters: {
          'page': loadMore ? currentPage.value.toString() : '1',
          'limit': limit.toString(),
        },
      );

      if (response.success && response.data != null && response.data['success'] == true) {
        final todaysDailiesResponse = TodaysDailiesResponse.fromJson(
          response.data,
        );
        final todaysDailiesData = todaysDailiesResponse.data;

        if (loadMore) {
          // Append to existing dailies
          dailies.addAll(todaysDailiesData.data);
          currentPage.value++;
        } else {
          // Replace existing dailies
          dailies.value = todaysDailiesData.data;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = todaysDailiesData.hasMore;

        debugPrint(
          'Dailies loaded: ${dailies.length} items, Has more: ${hasMore.value}',
        );
      } else {
        debugPrint('API Error: ${response.data['message']}');
        if (!loadMore) {
          dailies.value = MockContentProvider.getDailies();
          hasMore.value = false;
        }
      }
    } catch (e) {
      errorMessage.value = '';
      debugPrint('Exception in fetchDailies: $e — using static fallback');
      if (!loadMore) {
        dailies.value = MockContentProvider.getDailies();
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
  Future<void> loadMoreDailies() async {
    await fetchDailies(loadMore: true);
  }

  // Refresh dailies
  Future<void> refreshDailies() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchDailies();
  }

  Future<void> playDailies(
    TodaysDailiesModel daily,
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
            'id': daily.id,
            'author': daily.author,
            'imageUrl': daily.imageUrl,
            'title': daily.title,
            'category': daily.category,
            'description': daily.description,
            'duration': daily.duration,
            'audio': daily.audio,
            'item': daily,
            'accessType': daily.accessType,
            'modelType': 'TodaysDailiesModel',
            'contentType':
                daily.contentType[Random().nextInt(daily.contentType.length)],
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

        Get.toNamed(
          '/audio-player',
          arguments: {
            'id': daily.id,
            'author': daily.author,
            'imageUrl': daily.imageUrl,
            'title': daily.title,
            'category': daily.category,
            'description': daily.description,
            'duration': daily.duration,
            'audio': daily.audio,
            'item': daily,
            'accessType': daily.accessType,
            'modelType': 'TodaysDailiesModel',
            'contentType':
                daily.contentType[Random().nextInt(daily.contentType.length)],
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
