import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var meta = Meta(page: 1, limit: 100, total: 0).obs;

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
        endpoint: 'category/user-categories',
        token: token,
      );

      if (response.data['success'] == true) {
        // Access the nested data array from the response
        final List<dynamic> data = response.data['data']['data'] ?? [];
        categories.value = data.map((item) => Category.fromJson(item)).toList();

        // Update meta information
        if (response.data['data']['meta'] != null) {
          meta.value = Meta.fromJson(response.data['data']['meta']);
        }

        debugPrint('Categories loaded: ${categories.length} items');
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to load categories';
        debugPrint('API Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching categories: $e';
      debugPrint('Exception in fetchUserCategories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await fetchUserCategories();
  }
}
