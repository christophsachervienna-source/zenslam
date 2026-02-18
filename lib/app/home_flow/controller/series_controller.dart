import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/home_flow/model/series_model.dart';
import 'package:zenslam/app/home_flow/model/series_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeriesController extends GetxController {
  var categoriesList = <SeriesCategory>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var errorMessage = ''.obs;

  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final token = await SharedPrefHelper.getAccessToken();
      final userId = await SharedPrefHelper.getUserId();

      // Build endpoint with optional userId and pagination
      String endpoint = 'category/user-categories';
      String queryParams = '';

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        queryParams = '?userId=$userId';
      }

      // Add pagination parameters
      if (queryParams.isNotEmpty) {
        queryParams += '&page=${loadMore ? currentPage.value : 1}&limit=$limit';
      } else {
        queryParams = '?page=${loadMore ? currentPage.value : 1}&limit=$limit';
      }

      endpoint += queryParams;

      debugPrint('📡 Fetching categories: $endpoint');

      final response = await ApiService.get(endpoint: endpoint, token: token);

      if (response.data['success'] == true) {
        final categoriesResponse = CategoriesResponse.fromJson(response.data);
        final categoriesData = categoriesResponse.data;

        if (loadMore) {
          // Append to existing categories
          categoriesList.addAll(categoriesData.categories);
          currentPage.value++;
        } else {
          // Replace existing categories
          categoriesList.value = categoriesData.categories;
          currentPage.value = 2; // Next page will be 2
        }

        // Update hasMore
        hasMore.value = categoriesData.hasMore;

        debugPrint(
          '✅ Fetched ${categoriesList.length} categories, Has more: ${hasMore.value}',
        );
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Failed to fetch categories';
        debugPrint('❌ Error: ${errorMessage.value}');
        if (!loadMore) {
          // Get.snackbar('Error', 'Failed to load categories');
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch categories: $e';
      debugPrint('❌ Error fetching categories: $e');
      if (!loadMore) {
        //Get.snackbar('Error', 'Failed to load categories');
      }
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreCategories() async {
    await fetchCategories(loadMore: true);
  }

  Future<void> refreshCategories() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchCategories();
  }

  // Track progress for a category (POST API)
  Future<bool> trackCategoryProgress(
    String contentType,
    String categoryId,
  ) async {
    try {
      final token = await SharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No token available, skipping progress tracking');
        return false;
      }

      // Get the first episode's seriesId from the category
      final episodes = await fetchEpisodesByCategory(categoryId);
      if (episodes == null || episodes.isEmpty) {
        debugPrint('⚠️ No episodes found for category: $categoryId');
        return false;
      }

      final firstEpisodeId = episodes.first.id;

      final response = await ApiService.post(
        endpoint: 'series/progress',
        token: token,
        body: {"seriesId": firstEpisodeId, "categoryId": categoryId},
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Progress tracked successfully for category: $categoryId');
        return true;
      } else {
        debugPrint('⚠️ Failed to track progress: ${response.data['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error tracking category progress: $e');
      return false;
    }
  }

  // Fetch all episodes for a category (GET API)
  Future<List<EpisodeModel>?> fetchEpisodesByCategory(String categoryId) async {
    try {
      final token = await SharedPrefHelper.getAccessToken();

      final response = await ApiService.get(
        endpoint: 'series/user?categoryId=$categoryId',
        token: token,
      );

      if (response.data['success'] == true) {
        final episodesResponse = SeriesEpisodesResponse.fromJson(response.data);
        debugPrint(
          '✅ Fetched ${episodesResponse.data.episodes.length} episodes for category: $categoryId',
        );
        return episodesResponse.data.episodes;
      } else {
        debugPrint('⚠️ Failed to fetch episodes: ${response.data['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching episodes by category: $e');
      return null;
    }
  }

  // Combined method: Track progress and fetch episodes for a category
  Future<Map<String, dynamic>?> prepareCategoryForPlayback(
    SeriesCategory category,
  ) async {
    try {
      // Fetch all episodes for this category
      final episodes = await fetchEpisodesByCategory(category.id);

      if (episodes != null && episodes.isNotEmpty) {
        // Track progress (fire and forget)
        trackCategoryProgress("Series", category.id);

        return {'category': category, 'episodes': episodes};
      } else {
        debugPrint('⚠️ No episodes found for category: ${category.name}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error preparing category for playback: $e');
      return null;
    }
  }

  // Toggle favorite status for a category
  void toggleFavorite(String categoryId) {
    final index = categoriesList.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      // Create a new category with toggled favorite status
      final updatedCategory = SeriesCategory(
        id: categoriesList[index].id,
        name: categoriesList[index].name,
        title: categoriesList[index].title,
        description: categoriesList[index].description,
        thumbnail: categoriesList[index].thumbnail,
        // isFavorite: !categoriesList[index].isFavorite,
        categoryFavorites: [],
      );

      categoriesList[index] = updatedCategory;
      categoriesList.refresh();

      // Update favorite status on server
      _updateFavoriteOnServer(categoryId, updatedCategory.isFavorite);
    }
  }

  // Update favorite status on server
  Future<void> _updateFavoriteOnServer(
    String categoryId,
    bool isFavorite,
  ) async {
    try {
      final token = await SharedPrefHelper.getAccessToken();
      final userId = await SharedPrefHelper.getUserId();

      final response = await ApiService.post(
        endpoint: 'category/favorite',
        token: token,
        body: {
          "categoryId": categoryId,
          "userId": userId,
          "isFavorite": isFavorite,
        },
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Favorite status updated successfully');
      } else {
        debugPrint(
          '⚠️ Failed to update favorite status: ${response.data['message']}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating favorite status: $e');
    }
  }

  // Get category by ID
  SeriesCategory? getCategoryById(String categoryId) {
    return categoriesList.firstWhereOrNull((cat) => cat.id == categoryId);
  }

  // Get category by name
  SeriesCategory? getCategoryByName(String categoryName) {
    return categoriesList.firstWhereOrNull((cat) => cat.name == categoryName);
  }

  // Get favorite categories
  List<SeriesCategory> get favoriteCategories {
    return categoriesList.where((cat) => cat.isFavorite).toList();
  }

  // Update category favorite status (for external updates)
  void updateCategoryFavoriteStatus(String categoryId, bool isFavorite) {
    debugPrint('🔄 updateCategoryFavoriteStatus called:');
    debugPrint('   Category ID: $categoryId');
    debugPrint('   New isFavorite: $isFavorite');

    final index = categoriesList.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      final updatedCategory = SeriesCategory(
        id: categoriesList[index].id,
        name: categoriesList[index].name,
        title: categoriesList[index].title,
        description: categoriesList[index].description,
        thumbnail: categoriesList[index].thumbnail,
        //isFavorite: isFavorite,
        categoryFavorites: [],
      );

      categoriesList[index] = updatedCategory;
      categoriesList.refresh();
      debugPrint('   ✅ Category favorite status updated successfully');
    } else {
      debugPrint('   ❌ Category with ID "$categoryId" not found');
    }
  }

  Future<void> handleSeriesTap(int index) async {
    try {
      final category = categoriesList[index];

      debugPrint('📂 Selected category: ${category.name} (${category.id})');

      // Fetch all episodes for this category
      final episodes = await fetchEpisodesByCategory(category.id);

      if (episodes == null || episodes.isEmpty) {
        Get.snackbar(
          'This series has no episodes yet',
          'Try another series or come back later',
        );
        return;
      }

      debugPrint('✅ Fetched ${episodes.length} episodes');

      // Track progress for the first episode (series/progress)
      final firstEpisode = episodes.first;
      await trackCategoryProgress("Series", category.id);

      debugPrint('✅ Progress tracked for first episode: ${firstEpisode.id}');

      // Create SeriesModel with all episodes
      final seriesModel = SeriesModel(
        id: category.id,
        name: category.name,
        title: category.title,
        description: category.description,
        thumbnail: category.thumbnail,
        episodes: episodes,
      );

      // Navigate to player
      Get.to(
        () => SeriesPlayerScreen(),
        arguments: {'series': seriesModel, 'episode': firstEpisode},
      );
    } catch (e) {
      debugPrint('❌ Error handling series tap: $e');
      Get.snackbar('Error', 'Failed to load series');
    }
  }
}
