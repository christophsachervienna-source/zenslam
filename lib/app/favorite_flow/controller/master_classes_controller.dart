import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/masterclasses_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MasterClassesController extends GetxController {
  var masterList = <MasterClassModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs; // For pagination loading
  var errorMessage = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10; // Items per page

  @override
  void onInit() {
    super.onInit();
    fetchMasterClasses();
  }

  Future<void> fetchMasterClasses({bool loadMore = false}) async {
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
        endpoint: 'content/masterclass',
        token: token,
        queryParameters: {
          'page': loadMore ? currentPage.value.toString() : '1',
          'limit': limit.toString(),
        },
      );

      debugPrint('📦 Full API Response: ${response.data}');

      if (response.data['success'] == true) {
        final masterClassResponse = MasterClassResponse.fromJson(response.data);
        final masterClassData = masterClassResponse.data;

        if (loadMore) {
          // Append to existing items
          masterList.addAll(masterClassData.data);
          currentPage.value++;
        } else {
          // Replace existing items
          masterList.value = masterClassData.data;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = masterClassData.hasMore;

        debugPrint(
          '🎯 Master Classes Loaded: ${masterList.length}, Has more: ${hasMore.value}',
        );
      } else {
        final errorMsg =
            response.data['message'] ?? 'Failed to load master classes';
        errorMessage.value = errorMsg;
        if (!loadMore) {
          //    Get.snackbar('Error', errorMsg);
        }
      }
    } catch (e) {
      debugPrint('💥 Error fetching master classes: $e');
      errorMessage.value = 'Failed to load master classes: $e';
      if (!loadMore) {
        // Get.snackbar('Error', 'Failed to load master classes');
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
  Future<void> loadMoreMasterClasses() async {
    await fetchMasterClasses(loadMore: true);
  }

  // Refresh master classes
  Future<void> refreshMasterClasses() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchMasterClasses();
  }

  // Track progress for a master class
  Future<bool> trackMasterProgress(String masterId) async {
    try {
      final userId = await SharedPrefHelper.getUserId();
      debugPrint('User ID: $userId');

      final response = await ApiService.post(
        endpoint: 'content/progress',
        body: {"contentType": "MasterClass", "contentId": masterId},
      );

      if (response.data['success'] == true) {
        debugPrint('Progress tracked successfully for master: $masterId');
        return true;
      } else {
        debugPrint('Failed to track progress: ${response.data['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error tracking master progress: $e');
      return false;
    }
  }

  Future<void> playMasterClass(
    MasterClassModel masterItem,
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
            'id': masterItem.id,
            'author': masterItem.author,
            'imageUrl': masterItem.imageUrl,
            'title': masterItem.title,
            'category': masterItem.category,
            'description': masterItem.description,
            'duration': masterItem.duration,
            'audio': masterItem.audio,
            'accessType': masterItem.accessType,
            'item': masterItem,
            'modelType': 'MasterClassModel',
            'contentType': masterItem
                .contentType[Random().nextInt(masterItem.contentType.length)],
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
            'id': masterItem.id,
            'author': masterItem.author,
            'imageUrl': masterItem.imageUrl,
            'title': masterItem.title,
            'category': masterItem.category,
            'description': masterItem.description,
            'duration': masterItem.duration,
            'audio': masterItem.audio,
            'item': masterItem,
            'accessType': masterItem.accessType,
            'modelType': 'MasterClassModel',
            'contentType': masterItem
                .contentType[Random().nextInt(masterItem.contentType.length)],
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

  // Get unique categories from master classes
  List<String> get allCategories {
    final categories = masterList.map((item) => item.category).toSet().toList();
    return categories..sort();
  }

  // Get master classes by category
  List<MasterClassModel> getMasterByCategory(String category) {
    return masterList.where((item) => item.category == category).toList();
  }

  // Check if category has content
  bool hasContent(String category) {
    return masterList.any((item) => item.category == category);
  }

  // Get featured master classes
  List<MasterClassModel> get featuredMasterClasses {
    return masterList.where((item) => item.isFeature).toList();
  }

  // Get most popular master classes
  List<MasterClassModel> get popularMasterClasses {
    return masterList.where((item) => item.mostPopular).toList();
  }
}
