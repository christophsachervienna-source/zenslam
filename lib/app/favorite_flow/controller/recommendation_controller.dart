import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/data/mock_content_provider.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/mentor_flow/controller/recommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendationController extends GetxController {
  var recommendations = <RecommendationModel>[].obs;
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
    fetchRecommendations();
  }

  Future<void> fetchRecommendations({bool loadMore = false}) async {
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
        endpoint: 'user/recommended-audio',
        token: token,
        queryParameters: {
          'page': loadMore ? currentPage.value.toString() : '1',
          'limit': limit.toString(),
        },
      );

      if (response.data['success'] == true) {
        final recommendationsResponse = RecommendationsResponse.fromJson(
          response.data,
        );
        final recommendationsData = recommendationsResponse.data;

        debugPrint(
          'Recommendations: ${recommendationsData.recommended.length}',
        );

        if (loadMore) {
          // Append to existing recommendations
          recommendations.addAll(recommendationsData.recommended);
          currentPage.value++;
        } else {
          // Replace existing recommendations
          recommendations.value = recommendationsData.recommended;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = recommendationsData.hasMore;

        debugPrint(
          'Successfully loaded ${recommendations.length} recommendations, Has more: ${hasMore.value}',
        );
      } else {
        debugPrint('API Error: ${response.data['message']}');
        if (!loadMore) {
          recommendations.value = MockContentProvider.getRecommendations();
          hasMore.value = false;
        }
      }
    } catch (e) {
      errorMessage.value = '';
      debugPrint('Error in fetchRecommendations: $e — using static fallback');
      if (!loadMore) {
        recommendations.value = MockContentProvider.getRecommendations();
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

  // Load more recommendations for pagination
  Future<void> loadMoreRecommendations() async {
    await fetchRecommendations(loadMore: true);
  }

  // Refresh recommendations
  Future<void> refreshRecommendations() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchRecommendations();
  }

  void playRecommendation(RecommendationModel recommendation) {
    Get.toNamed(
      '/audio-player',
      arguments: {
        'id': recommendation.id,
        'author': recommendation.author,
        'imageUrl': recommendation.imageUrl,
        'title': recommendation.title,
        'category': recommendation.category,
        'description': recommendation.description,
        'duration': recommendation.duration,
        'audio': recommendation.content,
        'accessType': recommendation.accessType,
        'isLocked': recommendation.isLocked,
        'item': recommendation,
        'modelType': 'RecommendationModel',
      },
    );
  }

  // Getter to check if there are any recommendations
  bool get hasRecommendations => recommendations.isNotEmpty;

  // Method to get recommendations by category
  List<RecommendationModel> getRecommendationsByCategory(String category) {
    return recommendations.where((rec) => rec.hasCategory(category)).toList();
  }
}
