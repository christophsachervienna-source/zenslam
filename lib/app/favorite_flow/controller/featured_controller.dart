import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/core/const/routes.dart';
import 'package:zenslam/app/home_flow/model/featured_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeaturedController extends GetxController {
  var featuredItems = <FeaturedModel>[].obs;
  RxBool isLoading = false.obs;
  var isLoadingMore = false.obs; // For pagination loading
  var errorMessage = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10; // Items per page

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedItems();
  }

  Future<void> fetchFeaturedItems({bool loadMore = false}) async {
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
        endpoint: 'content/feature',
        token: token,
        queryParameters: {
          'page': loadMore ? currentPage.value.toString() : '1',
          'limit': limit.toString(),
        },
      );

      debugPrint('📦 Full API Response: ${response.data}');

      if (response.data['success'] == true) {
        final featuredResponse = FeaturedResponse.fromJson(response.data);
        final featuredData = featuredResponse.data;

        if (loadMore) {
          // Append to existing items
          featuredItems.addAll(featuredData.data);
          currentPage.value++;
        } else {
          // Replace existing items
          featuredItems.value = featuredData.data;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = featuredData.hasMore;

        debugPrint(
          '✅ Featured items loaded: ${featuredItems.length}, Has more: ${hasMore.value}',
        );
      } else {
        debugPrint('❌ API returned success: false');
        final message = response.data['message'] ?? 'Failed to load content';
        errorMessage.value = message;
        if (!loadMore) {
          //  Get.snackbar('Error', message);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception: $e');
      debugPrint('📝 Stack trace: $stackTrace');
      errorMessage.value = e.toString();
      if (!loadMore) {
        //  Get.snackbar('Error', 'Failed to load content: $e');
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
  Future<void> loadMoreFeatured() async {
    await fetchFeaturedItems(loadMore: true);
  }

  // Refresh featured items
  Future<void> refreshFeatured() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchFeaturedItems();
  }

  Future<void> playFeatured(
    FeaturedModel featured,
    String type,
    String id,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    try {
      if (token == null) {
        Get.toNamed(
          AppRoutes.audioPlayer,
          arguments: {
            'id': featured.id,
            'author': featured.author,
            'imageUrl': featured.imageUrl,
            'title': featured.title,
            'category': featured.category,
            'description': featured.description,
            'duration': featured.duration,
            'audio': featured.audio,
            'accessType': featured.accessType,
            'item': featured,
            'modelType': 'FeaturedModel',
            'contentType': featured
                .contentType[Random().nextInt(featured.contentType.length)],
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
            'id': featured.id,
            'author': featured.author,
            'imageUrl': featured.imageUrl,
            'title': featured.title,
            'category': featured.category,
            'description': featured.description,
            'duration': featured.duration,
            'audio': featured.audio,
            'item': featured,
            'accessType': featured.accessType,
            'modelType': 'FeaturedModel',
            'contentType': featured
                .contentType[Random().nextInt(featured.contentType.length)],
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
