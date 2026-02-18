// rating_controller.dart
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  RxInt rating = 0.obs;
  RxString description = ''.obs;
  RxString title = ''.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString feedbackType = 'General Feedback'.obs;

  static const List<String> feedbackTypes = [
    'General Feedback',
    'Feature Suggestion',
    'Meditation Topic Request',
  ];

  void setFeedbackType(String type) {
    feedbackType.value = type;
  }

  // For storing fetched ratings
  RxList<dynamic> ratingsList = <dynamic>[].obs;
  RxInt currentPage = 1.obs;
  RxInt totalRatings = 0.obs;
  RxBool hasMore = true.obs;

  void setRating(int value) {
    rating.value = value;
  }

  void setTitle(String value) {
    description.value = value;
  }

  void setDescription(String value) {
    description.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    getRatings(); // Fetch ratings when controller is initialized
  }

  Future<bool> submitRating() async {
    if (rating.value == 0) {
      errorMessage.value = 'Please select a rating';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SharedPrefHelper.getAccessToken();

      final response = await ApiService.post(
        endpoint: 'rating/create',
        token: token,
        body: {
          'rating': rating.value.toDouble(),
          'title': '[${feedbackType.value}] ${title.value.trim()}',
          'description': description.value.trim(),
        },
      );
      if (response.data['success'] == true) {
        rating.value = 0;
        description.value = '';

        Get.snackbar(
          "Success",
          "Thank you for your feedback!",
         
        );
        debugPrint('Rating: ${rating.value.toDouble()}');
        debugPrint('Title: ${title.value.trim()}');
        debugPrint('Description: ${description.value.trim()}');
        return true;
      } else {
        final message = response.data['message'] ?? 'Failed to submit rating';
        debugPrint(message);
        errorMessage.value = message;
        Get.snackbar(
          "Error",
          message,
         
        );
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      errorMessage.value = e.toString();
      Get.snackbar(
        "Error",
        "Failed to submit rating: $e",
       
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get ratings method
  Future<bool> getRatings({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = page;
    }

    errorMessage.value = '';

    try {
      final response = await ApiService.get(
        endpoint: 'rating?page=$page&limit=$limit',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final meta = data['meta'];
        final ratingsData = data['data'] as List<dynamic>;

        if (loadMore) {
          ratingsList.addAll(ratingsData);
        } else {
          ratingsList.value = ratingsData;
        }

        currentPage.value = meta['page'] ?? page;
        totalRatings.value = meta['total'] ?? 0;

        // Check if there are more pages
        final totalPages = (totalRatings.value / limit).ceil();
        hasMore.value = currentPage.value < totalPages;

        return true;
      } else {
        final message = response.data['message'] ?? 'Failed to fetch ratings';
        debugPrint(message);
        errorMessage.value = message;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load more ratings for pagination
  Future<void> loadMoreRatings() async {
    if (hasMore.value && !isLoading.value) {
      await getRatings(page: currentPage.value + 1, loadMore: true);
    }
  }

  // Refresh ratings
  Future<void> refreshRatings() async {
    await getRatings(page: 1, loadMore: false);
  }

  void resetForm() {
    rating.value = 0;
    title.value = '';
    description.value = '';
    feedbackType.value = 'General Feedback';
    errorMessage.value = '';
  }
}
