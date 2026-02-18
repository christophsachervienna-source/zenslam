import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/categories_display_model.dart'
    show Content;
import 'package:zenslam/app/home_flow/model/content_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContentListController extends GetxController {
  var contentList = <ContentItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var meta = Meta(page: 1, limit: 10, total: 0).obs;

  // Modified to accept category name parameter
  Future<void> fetchContentList({String? categoryName}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    try {
      // Build endpoint based on whether category is provided
      String endpoint = 'content/user/$categoryName';

      final response = await ApiService.get(
        endpoint: endpoint,
        token: token,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'] ?? [];
        contentList.value = data
            .map((item) => ContentItem.fromJson(item))
            .toList();

        if (response.data['data']['meta'] != null) {
          meta.value = Meta.fromJson(response.data['data']['meta']);
        }

        debugPrint('Content list loaded: ${contentList.length} items');
        if (categoryName != null) {
          debugPrint('Category: $categoryName');
        }

        // Log featured and recommended items
        final featuredCount = contentList
            .where((item) => item.isFeature)
            .length;
        final recommendedCount = contentList
            .where((item) => item.recommended)
            .length;
        debugPrint(
          'Featured items: $featuredCount, Recommended: $recommendedCount',
        );
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to load content';
        debugPrint('API Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching content: $e';
      debugPrint('Exception in fetchContentList: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to fetch by specific category
  Future<void> fetchContentByCategory(String categoryName) async {
    await fetchContentList(categoryName: categoryName);
  }

  // Rest of your methods remain the same...
  List<ContentItem> getFeaturedContent() {
    return contentList.where((item) => item.isFeature).toList();
  }

  List<ContentItem> getRecommendedContent() {
    return contentList.where((item) => item.recommended).toList();
  }

  List<ContentItem> getContentByCategory(String categoryName) {
    return contentList
        .where((item) => item.categoryName == categoryName)
        .toList();
  }

  Future<void> playContent(
    ContentItem content,
    String categoryName,
    String id,
  ) async {
    //isLoading.value = true;
    errorMessage.value = '';

    debugPrint('Playing content: ${content.title}');
    final token = await SharedPrefHelper.getAccessToken();

    try {
      final response = await ApiService.post(
        endpoint: 'content/progress',
        body: {"categoryName": categoryName, "ContentId": id},
        token: token,
      );

      if (response.data['success'] == true) {
        debugPrint('Progress API Response: ${response.data}');

        Get.toNamed(
          '/audio-player',
          arguments: {
            'author': content.author,
            'imageUrl': content.thumbnail,
            'title': content.title,
            'category': content.categoryName,
            'description': content.description,
            'duration': content.duration,
            'audio': content.content,
            'item': content,
            'modelType': 'Content_dailies',
          },
        );
      } else {
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
      errorMessage.value = 'Failed to play content: $e';
      debugPrint('Error in playContent: $e');
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshContentList({String? categoryName}) async {
    await fetchContentList(categoryName: categoryName);
  }

  Future<void> loadMoreContent({String? categoryName}) async {
    if (isLoading.value || contentList.length >= meta.value.total) return;

    final nextPage = meta.value.page + 1;
    isLoading.value = true;
    final token = await SharedPrefHelper.getAccessToken();

    try {
      String endpoint = 'content?page=$nextPage&limit=${meta.value.limit}';
      if (categoryName != null && categoryName.isNotEmpty) {
        endpoint =
            'content/user/$categoryName?page=$nextPage&limit=${meta.value.limit}';
      }

      final response = await ApiService.get(
        endpoint: endpoint,
        token: token,
      );

      if (response.data['success'] == true) {
        final List<dynamic> newData = response.data['data']['data'] ?? [];
        contentList.addAll(newData.map((item) => ContentItem.fromJson(item)));

        if (response.data['data']['meta'] != null) {
          meta.value = Meta.fromJson(response.data['data']['meta']);
        }

        debugPrint(
          'Loaded more content: ${newData.length} items, Total: ${contentList.length}',
        );
      }
    } catch (e) {
      debugPrint('Error loading more content: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to your ContentListController
  Content convertToContent(ContentItem item) {
    return Content(
      id: item.id,
      categoryName: item.categoryName,
      type: item.type,
      serialNo: item.serialNo,
      title: item.title,
      description: item.description,
      content: item.content,
      author: item.author,
      thumbnail: item.thumbnail,
      duration: item.duration,
    );
  }
}
