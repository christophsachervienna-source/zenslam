import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreAllController extends GetxController {
  final RxInt selectedCategoryIndex = 0.obs;
  final RxList<ExploreItem> selectedCategoryItems = <ExploreItem>[].obs;
  final RxList<ExploreItem> allExploreItems = <ExploreItem>[].obs;
  final RxMap<String, List<ExploreItem>> categoryContent = <String, List<ExploreItem>>{}.obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;

  // Pagination per category
  final Map<String, int> categoryPage = {};
  final Map<String, bool> categoryHasMore = {};
  final int limit = 10;

  bool get currentCategoryHasMore =>
      categoryHasMore[categories.isNotEmpty ? categories[selectedCategoryIndex.value] : ''] ?? false;

  /// Returns true if any category has content items
  bool get hasAnyData {
    for (var category in categories) {
      if ((categoryContent[category]?.isNotEmpty ?? false)) {
        return true;
      }
    }
    return allExploreItems.isNotEmpty;
  }

  /// Returns items for a specific category
  List<ExploreItem> getItemsByCategory(String category) {
    return categoryContent[category] ?? [];
  }

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    _initializeCategories();
    _loadAllCategoryContent();
  }

  Future<void> _checkLoginStatus() async {
    final token = await SharedPrefHelper.getAccessToken();
    isLoggedIn.value = token != null && token.isNotEmpty;
  }

  void _initializeCategories() {
    categories.value = [
      'Forehand',
      'Backhand',
      'Serve',
      'Confidence',
      'Focus',
      'Flow State',
      'Critical Moments',
      'Winning',
    ];

    // Initialize pagination for all categories
    for (var category in categories) {
      categoryPage[category] = 1;
      categoryHasMore[category] = true;
      categoryContent[category] = [];
    }
  }

  Future<void> _loadAllCategoryContent() async {
    isLoading.value = true;

    // Load content for each category
    for (var category in categories) {
      await loadContentForCategory(category);
    }

    isLoading.value = false;
  }

  Future<void> loadContentForCategory(String category, {bool loadMore = false}) async {
    if (loadMore) {
      if (!(categoryHasMore[category] ?? false) || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final page = loadMore ? (categoryPage[category] ?? 1) : 1;
      debugPrint('ExploreAllController: Fetching content for category: $category, page: $page');

      final response = await ApiService.get(
        endpoint: 'content/user/',
        queryParameters: {
          'contentType': category,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData != null && responseData['data'] is List) {
          final List<dynamic> contentList = responseData['data'];
          final newItems = contentList
              .map((item) => ExploreItem.fromJson(item))
              .toList();

          if (loadMore) {
            final currentList = categoryContent[category] ?? [];
            currentList.addAll(newItems);
            categoryContent[category] = currentList;
          } else {
            categoryContent[category] = newItems;
          }

          // Update pagination
          categoryPage[category] = page + 1;

          final meta = responseData['meta'] ?? {};
          final total = (meta['total'] as num?)?.toInt() ?? 0;
          final currentTotal = categoryContent[category]?.length ?? 0;
          categoryHasMore[category] = currentTotal < total;

          debugPrint('ExploreAllController: $category loaded ${newItems.length} items, total: $currentTotal');

          // Also add to allExploreItems
          for (var item in newItems) {
            if (!allExploreItems.any((e) => e.id == item.id)) {
              allExploreItems.add(item);
            }
          }
        }
      } else {
        debugPrint('ExploreAllController: API error for $category: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('ExploreAllController: Error loading $category: $e');
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      }
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    if (index < categories.length) {
      final category = categories[index];
      selectedCategoryItems.assignAll(categoryContent[category] ?? []);
    }
  }

  Future<void> loadMoreContent() async {
    if (selectedCategoryIndex.value < categories.length) {
      final category = categories[selectedCategoryIndex.value];
      await loadContentForCategory(category, loadMore: true);
      selectedCategoryItems.assignAll(categoryContent[category] ?? []);
    }
  }

  Future<void> refreshContent() async {
    await _loadAllCategoryContent();
  }

  Future<void> playMeditation(
    ExploreItem item,
    String contentType,
    String id,
  ) async {
    try {
      final token = await SharedPrefHelper.getAccessToken();

      if (token == null) {
        Get.toNamed(
          '/audio-player',
          arguments: {
            'id': item.id,
            'author': item.author,
            'imageUrl': item.thumbnail,
            'title': item.title,
            'category': item.category,
            'description': item.description,
            'duration': item.duration,
            'audio': item.content,
            'accessType': item.accessType,
            'item': item,
            'modelType': 'ExploreItem',
            'contentType': contentType,
          },
        );
        return;
      }

      final response = await ApiService.post(
        endpoint: 'content/progress',
        body: {"contentType": contentType, "contentId": id},
        token: token,
      );

      if (response.data['success'] == true ||
          response.data['data']?['lock'] == true) {
        Get.toNamed(
          '/audio-player',
          arguments: {
            'id': item.id,
            'author': item.author,
            'imageUrl': item.thumbnail,
            'title': item.title,
            'category': item.category,
            'description': item.description,
            'duration': item.duration,
            'audio': item.content,
            'accessType': item.accessType,
            'isLocked': item.isLocked,
            'item': item,
            'modelType': 'ExploreItem',
            'contentType': contentType,
          },
        );
      } else {
        Get.snackbar(
          'Failed to play audio',
          'Make sure you are connected to the internet',
        );
      }
    } catch (e) {
      debugPrint('ExploreAllController: Error playing meditation: $e');
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    }
  }
}
