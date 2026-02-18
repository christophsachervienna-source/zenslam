import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/explore_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreCategoryController extends GetxController {
  var categories = <ExploreCategory>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var meta = Meta(total: 0, page: 1, limit: 10).obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserCategories();
  }

  Future<void> fetchUserCategories() async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    try {
      final response = await ApiService.get(
        endpoint: 'category/explore',
        token: token,
      );

      if (response.data['success'] == true) {
        final exploreModel = ExploreModel.fromJson(response.data);

        if (exploreModel.success) {
          categories.value = exploreModel.data.data;
          meta.value = exploreModel.data.meta;
          debugPrint('Categories loaded: ${categories.length} items');

          // Print categories for debugging
          for (var category in categories) {
            debugPrint('Category: ${category.name} (${category.id})');
          }
        } else {
          errorMessage.value = exploreModel.message;
          debugPrint('API Error: ${errorMessage.value}');
        }
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to load categories';
        debugPrint('Network Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching categories: $e';
      debugPrint('Exception in fetchUserCategories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get category by ID
  ExploreCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  ExploreCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get category names list
  List<String> get categoryNames {
    return categories.map((category) => category.name).toList();
  }

  // Get category IDs list
  List<String> get categoryIds {
    return categories.map((category) => category.id).toList();
  }

  // Check if categories are empty
  bool get hasCategories => categories.isNotEmpty;

  // Get total categories count
  int get totalCategories => categories.length;

  // Check if loading is complete and has data
  bool get hasData => !isLoading.value && hasCategories;

  // Check if loading is complete but no data
  bool get hasNoData => !isLoading.value && !hasCategories;

  // Refresh categories
  Future<void> refreshCategories() async {
    await fetchUserCategories();
  }

  // Clear all data
  void clear() {
    categories.clear();
    meta.value = Meta(total: 0, page: 1, limit: 10);
    errorMessage.value = '';
  }

  // Get pagination info
  String get paginationInfo {
    return 'Page ${meta.value.page} of ${(meta.value.total / meta.value.limit).ceil()} (${meta.value.total} total items)';
  }

  // Load more categories (for pagination)
  Future<void> loadMoreCategories() async {
    if (isLoading.value ||
        meta.value.page * meta.value.limit >= meta.value.total) {
      return;
    }

    final token = await SharedPrefHelper.getAccessToken();
    final nextPage = meta.value.page + 1;

    try {
      final response = await ApiService.get(
        endpoint: 'category/explore?page=$nextPage&limit=${meta.value.limit}',
        token: token,
      );

      if (response.data['success'] == true) {
        final exploreModel = ExploreModel.fromJson(response.data);

        if (exploreModel.success) {
          categories.addAll(exploreModel.data.data);
          meta.value = exploreModel.data.meta;
          debugPrint('Loaded more categories. Total: ${categories.length}');
        }
      }
    } catch (e) {
      debugPrint('Error loading more categories: $e');
    }
  }
}
