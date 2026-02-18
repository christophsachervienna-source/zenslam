import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/favorite_flow/model/favorite_model.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final Rx<FavoriteResponse?> favorites = Rx<FavoriteResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs; // For pagination loading
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoggedIn = false.obs;

  // Pagination variables
  var limit = 10; // Items per page
  var loadingPage = 1.obs; // Separate variable for loading pages

  final RxSet<String> pendingFavoriteOperations = <String>{}.obs;
  final RxSet<String> optimisticToggledItems = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await checkUser();
    if (isLoggedIn.value) {
      await getFavorites();
    }
  }

  Future<void> checkUser() async {
    isLoggedIn.value = (await SharedPrefHelper.getAccessToken() != null);
  }

  // Safe method to check if item is in favorites
  bool isItemInFavorites(String itemId) {
    try {
      if (isLoggedIn.value == false) {
        return false;
      }
      if (itemId.isEmpty) return false;

      final actualFavorite =
          favorites.value?.data.data.any((item) => item.itemId == itemId) ??
          false;

      // If the item is in our optimistic list, it means the user just clicked it
      // so we should show the OPPOSITE of the actual state
      if (optimisticToggledItems.contains(itemId)) {
        return !actualFavorite;
      }

      return actualFavorite;
    } catch (e) {
      debugPrint('❌ Error in isItemInFavorites: $e');
      return false;
    }
  }

  // Safe method to get favorite by item ID
  FavoriteItem? getFavoriteByItemId(String itemId) {
    try {
      if (isLoggedIn.value == false) {
        return null;
      }
      if (itemId.isEmpty) return null;

      final itemsList = favorites.value?.data.data;
      if (itemsList == null) return null;

      return itemsList.firstWhereOrNull((item) => item.itemId == itemId);
    } catch (e) {
      debugPrint('❌ Error in getFavoriteByItemId: $e');
      return null;
    }
  }

  // Updated getFavorites method with pagination
  Future<void> getFavorites({bool loadMore = false}) async {
    if (isLoggedIn.value == false) {
      return;
    }
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      loadingPage.value++;
    } else {
      isLoading.value = true;
      error.value = '';
      loadingPage.value = 1;
    }

    final token = await SharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      error.value = 'Please login to view favorites';
      isLoading.value = false;
      isLoadingMore.value = false;
      return;
    }

    try {
      final response = await ApiService.get(
        endpoint: 'user/favorites',
        token: token,
        queryParameters: {
          'page': loadingPage.value.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        debugPrint('📦 Favorites API Response: $responseData');

        try {
          final favoriteResponse = FavoriteResponse.fromJson(responseData);

          // Filter out series and masterclass - only keep regular content
          final contentOnlyItems = favoriteResponse.data.data
              .where((item) => item.type == 'content')
              .toList();

          debugPrint('🔄 Filtered favorites: ${contentOnlyItems.length} content items (excluded ${favoriteResponse.data.data.length - contentOnlyItems.length} series/masterclass)');

          // Debug: Print first item's thumbnail
          if (contentOnlyItems.isNotEmpty) {
            final firstItem = contentOnlyItems.first;
            debugPrint('🖼️ First favorite thumbnail: ${firstItem.item.thumbnail}');
            debugPrint('🖼️ First favorite raw item: ${firstItem.toJson()}');
          }

          if (loadMore) {
            // Append to existing favorites
            final existingData = favorites.value?.data.data ?? [];
            final updatedData = existingData + contentOnlyItems;

            favorites.value = FavoriteResponse(
              success: favoriteResponse.success,
              message: favoriteResponse.message,
              data: FavoriteData(
                meta: favoriteResponse.data.meta,
                data: updatedData,
                hasMore: favoriteResponse.data.hasMore,
              ),
            );
          } else {
            // Replace existing favorites with filtered content only
            favorites.value = FavoriteResponse(
              success: favoriteResponse.success,
              message: favoriteResponse.message,
              data: FavoriteData(
                meta: favoriteResponse.data.meta,
                data: contentOnlyItems,
                hasMore: favoriteResponse.data.hasMore,
              ),
            );
          }

          // Update hasMore
          hasMore.value = favoriteResponse.data.hasMore;

          debugPrint(
            '🔄 Favorites loaded: ${favoriteResponse.data.data.length} items, Has more: ${favoriteResponse.data.hasMore}',
          );
        } catch (parseError) {
          debugPrint('❌ JSON Parsing error: $parseError');
          error.value = 'Failed to parse favorites data';
          if (!loadMore) {
            favorites.value = null;
          }
        }
      } else {
        error.value = 'Failed to load favorites: ${response.statusCode}';
        if (!loadMore) {
          favorites.value = null;
        }
      }
    } catch (e) {
      debugPrint('❌ Network error in getFavorites: $e');
      error.value = 'Network error: ${e.toString()}';
      if (!loadMore) {
        favorites.value = null;
      }
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Load more favorites for pagination
  Future<void> loadMoreFavorites() async {
    await getFavorites(loadMore: true);
  }

  // Refresh favorites
  Future<void> refreshFavorites() async {
    currentPage.value = 1;
    hasMore.value = true;
    await getFavorites();
  }

  // Add to favorites method with race condition protection
  Future<void> addFavorites(String itemId) async {
    // Prevent multiple concurrent operations for the same item
    if (pendingFavoriteOperations.contains(itemId)) {
      debugPrint('⚠️ Favorite operation already in progress for: $itemId');
      return;
    }

    final token = await SharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      error.value = 'Please login to manage favorites';
      Get.to(() => const SubscriptionScreenV2());
      return;
    }

    try {
      // **IMMEDIATE UI FEEDBACK - mark as pending and optimistic toggled**
      pendingFavoriteOperations.add(itemId);
      if (optimisticToggledItems.contains(itemId)) {
        optimisticToggledItems.remove(itemId);
      } else {
        optimisticToggledItems.add(itemId);
      }

      final response = await ApiService.post(
        endpoint: 'user/content-favorite/$itemId',
        token: token,
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          debugPrint('✅ Successfully toggled favorite for: $itemId');

          // **REFRESH FAVORITES LIST** - This is crucial!
          await refreshFavorites();
        } else {
          _handleApiError(responseData, true);
        }
      } else {
        _handleHttpError(response, true);
      }
    } catch (e) {
      debugPrint('Toggle favorites error: $e');
      error.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      // **REMOVE PENDING STATUS** - always clean up
      pendingFavoriteOperations.remove(itemId);
      optimisticToggledItems.remove(itemId);
    }
  }

  // Add series to favorites with race condition protection
  Future<void> addSeriesFavorites(String itemId) async {
    // Prevent multiple concurrent operations for the same item
    if (pendingFavoriteOperations.contains(itemId)) {
      debugPrint('⚠️ Favorite operation already in progress for: $itemId');
      return;
    }

    final token = await SharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      error.value = 'Please login to manage favorites';
      Get.to(() => const SubscriptionScreenV2());
      return;
    }

    try {
      // **IMMEDIATE UI FEEDBACK - mark as pending and optimistic toggled**
      pendingFavoriteOperations.add(itemId);
      if (optimisticToggledItems.contains(itemId)) {
        optimisticToggledItems.remove(itemId);
      } else {
        optimisticToggledItems.add(itemId);
      }

      final response = await ApiService.post(
        endpoint: 'user/series-favorite/$itemId',
        token: token,
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          debugPrint('✅ Successfully toggled favorite for: $itemId');

          // **REFRESH FAVORITES LIST** - This is crucial!
          await refreshFavorites();
        } else {
          _handleApiError(responseData, true);
        }
      } else {
        _handleHttpError(response, true);
      }
    } catch (e) {
      debugPrint('Toggle favorites error: $e');
      error.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      // **REMOVE PENDING STATUS** - always clean up
      pendingFavoriteOperations.remove(itemId);
      optimisticToggledItems.remove(itemId);
    }
  }

  // Add series category to favorites with race condition protection
  Future<void> addSeriesCategoryFavorites(String itemId) async {
    // Prevent multiple concurrent operations for the same item
    if (pendingFavoriteOperations.contains(itemId)) {
      debugPrint('⚠️ Favorite operation already in progress for: $itemId');
      return;
    }

    final token = await SharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      error.value = 'Please login to manage favorites';
      Get.to(() => const SubscriptionScreenV2());
      return;
    }

    try {
      // **IMMEDIATE UI FEEDBACK - mark as pending and optimistic toggled**
      pendingFavoriteOperations.add(itemId);
      if (optimisticToggledItems.contains(itemId)) {
        optimisticToggledItems.remove(itemId);
      } else {
        optimisticToggledItems.add(itemId);
      }

      final response = await ApiService.post(
        endpoint: 'user/series-category-favorite/$itemId',
        token: token,
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          debugPrint('✅ Successfully toggled favorite for: $itemId');

          // **REFRESH FAVORITES LIST** - This is crucial!
          await refreshFavorites();
        } else {
          _handleApiError(responseData, true);
        }
      } else {
        _handleHttpError(response, true);
      }
    } catch (e) {
      debugPrint('Toggle favorites error: $e');
      error.value = 'Network error: ${e.toString()}';
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      // **REMOVE PENDING STATUS** - always clean up
      pendingFavoriteOperations.remove(itemId);
      optimisticToggledItems.remove(itemId);
    }
  }

  Future<void> addFavoritesByCategory(String className, String category) async {
    await _handleFavoriteOperation(
      className: className,
      category: category,
      endpoint: 'user/category-favorite',
      isAdd: true,
    );
  }

  Future<void> removeFavoritesByCategory(
    String className,
    String category,
  ) async {
    await _handleFavoriteOperation(
      className: className,
      category: category,
      endpoint: 'user/remove-category-favorite',
      isAdd: false,
    );
  }

  void _handleApiError(dynamic responseData, bool isAdd) {
    final errorMessage = responseData is Map
        ? responseData['message']?.toString()
        : 'Failed to ${isAdd ? 'add to' : 'remove from'} favorites';
    _showError(errorMessage ?? 'Operation failed');
  }

  void _handleHttpError(dynamic response, bool isAdd) {
    final responseData = response.data;
    final errorMessage = responseData is Map
        ? responseData['message']?.toString()
        : 'Failed to ${isAdd ? 'add to' : 'remove from'} favorites (Status: ${response.statusCode})';
    _showError(errorMessage!);
  }

  void _showError(String message) {
    error.value = message;
    Get.snackbar(
      'Failed to play audio',
      'Make sure you are connected to the internet',
    );
  }

  Future<void> _handleFavoriteOperation({
    required String className,
    required String category,
    required String endpoint,
    required bool isAdd,
  }) async {
    final token = await SharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      _showError('Please login to manage favorites');
      return;
    }

    try {
      error.value = '';

      final response = await ApiService.post(
        endpoint: endpoint,
        token: token,
        body: {"className": className, "category": category},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          debugPrint(
            '✅ Successfully ${isAdd ? 'added to' : 'removed from'} favorites',
          );

          // Refresh favorites
          await refreshFavorites();
        } else {
          _handleApiError(responseData, isAdd);
        }
      } else {
        _handleHttpError(response, isAdd);
      }
    } catch (e) {
      debugPrint('${isAdd ? 'Add' : 'Remove'} favorites error: $e');
      _showError('Network error occurred');
    }
  }

  // Clear error
  void clearError() {
    error.value = '';
  }

  void playMeditation(FavoriteItem item) {
    Get.toNamed(
      '/audio-player',
      arguments: {
        'id': item.itemId,
        'author': item.item.author,
        'imageUrl': item.item.thumbnail,
        'title': item.item.title,
        'category': item.item.type,
        'description': item.item.description,
        'duration': item.item.duration,
        'audio': item.item.content,
        'accessType': item.item.accessType,
        'modelType': 'FavoriteResponse',
        'item': item,
      },
    );
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
