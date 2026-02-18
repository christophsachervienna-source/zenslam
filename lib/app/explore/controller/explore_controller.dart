import 'dart:convert';
import 'dart:math';

import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/data/mock_content_provider.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreController extends GetxController {
  var selectedCategory = 0.obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var errorMessage = ''.obs;
  RxBool isLoggedIn = false.obs;

  // Pagination variables per category
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var limit = 10;

  final categories = [
    'All',
    'Forehand',
    'Backhand',
    'Serve',
    'Volley',
    'Stop/Drop Shot',
    'Footwork & Movement',
    'Eyes on the Ball',
    'Confidence & Self-Belief',
    'Concentration & Focus',
    'Flow State & Rhythm',
    'Trusting Your Inner Game',
    'Critical Moments',
    'Winning',
  ];

  // Store content by category
  final Map<String, List<ExploreItem>> categoryContent = {};
  final Map<String, int> categoryPage = {};
  final Map<String, bool> categoryHasMore = {};

  // Current displayed content
  var filteredContent = <ExploreItem>[].obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW: Search, Filter, and Recently Played State
  // ═══════════════════════════════════════════════════════════════════════════

  /// Recently played content list
  var recentlyPlayed = <ExploreItem>[].obs;

  /// Search query
  var searchQuery = ''.obs;

  /// Search results
  var searchResults = <ExploreItem>[].obs;

  /// Is searching
  var isSearching = false.obs;

  /// Search loading state
  var isSearchLoading = false.obs;

  /// Debounce worker for search
  Worker? _searchDebounce;

  /// Sort by: 0=Popular, 1=Newest
  var sortBy = 0.obs;

  /// Featured content
  var featuredContent = <ExploreItem>[].obs;

  /// Content grouped by category for section display
  final Map<String, RxList<ExploreItem>> sectionContent = {};

  /// Key for recently played storage
  static const String _recentlyPlayedKey = 'recently_played_items';

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    loadRecentlyPlayed();

    // Initialize pagination for all categories
    for (var category in categories) {
      categoryContent[category] = [];
      categoryPage[category] = 1;
      categoryHasMore[category] = true;
      sectionContent[category] = <ExploreItem>[].obs;
    }

    // Load content for the first category ('All')
    loadContentForCategory(categories[0]);

    // Load featured content
    loadFeaturedContent();
  }

  void loadUserName() async {
    isLoggedIn.value = (await SharedPrefHelper.getAccessToken() != null);
    debugPrint('User logged in: ${isLoggedIn.value}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Recently Played Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load recently played items from local storage
  Future<void> loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentlyPlayedKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        recentlyPlayed.assignAll(
          jsonList.map((item) => ExploreItem.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading recently played: $e');
    }
  }

  /// Save recently played items to local storage
  Future<void> _saveRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = recentlyPlayed.map((item) => item.toJson()).toList();
      await prefs.setString(_recentlyPlayedKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving recently played: $e');
    }
  }

  /// Add item to recently played
  void addToRecentlyPlayed(ExploreItem item) {
    // Remove if already exists
    recentlyPlayed.removeWhere((i) => i.id == item.id);

    // Add at the beginning
    recentlyPlayed.insert(0, item);

    // Keep only last 10 items
    if (recentlyPlayed.length > 10) {
      recentlyPlayed.removeLast();
    }

    _saveRecentlyPlayed();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Search Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Search content by query (server-side with debounce)
  void search(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      isSearchLoading.value = false;
      searchResults.clear();
      _searchDebounce?.dispose();
      return;
    }

    isSearching.value = true;
    isSearchLoading.value = true;

    // Debounce search to avoid excessive API calls
    _searchDebounce?.dispose();
    _searchDebounce = debounce(
      searchQuery,
      (_) => _performServerSearch(query),
      time: const Duration(milliseconds: 300),
    );
  }

  /// Perform server-side search
  Future<void> _performServerSearch(String query) async {
    try {
      debugPrint('Searching for: $query');
      final response = await ApiService.get(
        endpoint: 'content/user/',
        queryParameters: {
          'search': query,
          'page': '1',
          'limit': '50',
        },
      );

      if (response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData != null && responseData['data'] is List) {
          final List<dynamic> contentList = responseData['data'];
          searchResults.assignAll(
            contentList.map((item) => ExploreItem.fromJson(item)).toList(),
          );
          debugPrint('Search found ${searchResults.length} results');
          // Apply current sort to search results
          _applySort(searchResults);
        } else {
          searchResults.clear();
        }
      } else {
        // Fallback to local search if API fails
        debugPrint('API search failed, falling back to local');
        _performLocalSearch(query);
      }
    } catch (e) {
      debugPrint('Server search failed: $e, falling back to local search');
      // Fallback to local search if API fails
      _performLocalSearch(query);
    } finally {
      isSearchLoading.value = false;
    }
  }

  /// Fallback local search on cached content
  void _performLocalSearch(String query) {
    final lowerQuery = query.toLowerCase();

    // Search across all cached content + static fallback
    final results = <ExploreItem>[];
    final allContent = categoryContent.values.expand((v) => v).toList();
    if (allContent.isEmpty) {
      allContent.addAll(MockContentProvider.getExploreItems());
    }
    results.addAll(
      allContent.where((item) =>
          item.title.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.category.toLowerCase().contains(lowerQuery) ||
          item.author.toLowerCase().contains(lowerQuery)),
    );

    // Remove duplicates
    final uniqueIds = <String>{};
    searchResults.assignAll(
      results.where((item) => uniqueIds.add(item.id)).toList(),
    );

    // Apply current sort to search results
    _applySort(searchResults);
    isSearchLoading.value = false;
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    super.onClose();
  }

  /// Clear search and reset to 'All' category
  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
    // Reset to 'All' category (index 0)
    selectCategory(0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Filter Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Apply sort filter to content
  void applyFilters({int? sort}) {
    if (sort != null) sortBy.value = sort;

    // Re-sort current content
    if (isSearching.value) {
      _applySort(searchResults);
    } else {
      _applySort(filteredContent);
    }
  }

  /// Apply sort to a list
  void _applySort(RxList<ExploreItem> items) {
    items.sort((a, b) {
      switch (sortBy.value) {
        case 0: // Popular
          return b.views.compareTo(a.views);
        case 1: // Newest
          return b.createdAt.compareTo(a.createdAt);
        default:
          return 0;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Featured Content Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load featured content
  Future<void> loadFeaturedContent() async {
    try {
      final response = await ApiService.get(
        endpoint: 'content/user/',
        queryParameters: {
          'isFeature': 'true',
          'page': '1',
          'limit': '10',
        },
      );

      if (response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData != null && responseData['data'] is List) {
          final List<dynamic> contentList = responseData['data'];
          featuredContent.assignAll(
            contentList.map((item) => ExploreItem.fromJson(item)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading featured content: $e — using static fallback');
      final staticItems = MockContentProvider.getExploreItems();
      featuredContent.assignAll(staticItems.take(10).toList());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Section Content Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load initial sections for the explore page
  Future<void> _loadInitialSections() async {
    // Load first 3-4 categories for initial display
    final initialCategories = categories.take(4).toList();
    for (var category in initialCategories) {
      await loadCategorySection(category);
    }
  }

  /// Load content for a specific category section
  Future<void> loadCategorySection(String category) async {
    if (!sectionContent.containsKey(category)) {
      sectionContent[category] = <ExploreItem>[].obs;
    }

    try {
      final response = await ApiService.get(
        endpoint: 'content/user/',
        queryParameters: {
          'contentType': category,
          'page': '1',
          'limit': '10',
        },
      );

      if (response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData != null && responseData['data'] is List) {
          final List<dynamic> contentList = responseData['data'];
          sectionContent[category]!.assignAll(
            contentList.map((item) => ExploreItem.fromJson(item)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading section content for $category: $e — using static fallback');
      final staticItems = MockContentProvider.getExploreItems(category: category);
      sectionContent[category]!.assignAll(staticItems.take(10).toList());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get combined cached content from all categories (used as fallback)
  List<ExploreItem> _getCombinedCachedContent() {
    final allItems = <ExploreItem>[];
    final seenIds = <String>{};

    for (var category in categories) {
      if (category == 'All') continue; // Skip 'All' itself
      final items = categoryContent[category] ?? [];
      for (var item in items) {
        if (seenIds.add(item.id)) {
          allItems.add(item);
        }
      }
    }

    // Sort by popularity (views) as default
    allItems.sort((a, b) => b.views.compareTo(a.views));
    return allItems;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Content Loading Methods
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadContentForCategory(
    String category, {
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!(categoryHasMore[category] ?? false) || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';

      // Reset pagination for this category
      categoryPage[category] = 1;
      categoryHasMore[category] = true;
      categoryContent[category] = [];
    }

    try {
      final page = categoryPage[category] ?? 1;
      debugPrint('Fetching content for category: $category, page: $page');

      // Build query parameters - omit contentType for 'All' category
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != 'All') {
        queryParams['contentType'] = category;
      }

      final response = await ApiService.get(
        endpoint: 'content/user/',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData != null && responseData['data'] is List) {
          final List<dynamic> contentList = responseData['data'];

          final newItems = contentList
              .map((item) => ExploreItem.fromJson(item))
              .toList();

          if (loadMore) {
            // Append to existing content
            categoryContent[category]?.addAll(newItems);
          } else {
            // Replace existing content
            categoryContent[category] = newItems;
          }

          // Update pagination info
          categoryPage[category] = page + 1;

          final meta = responseData['meta'] ?? {};
          final total = (meta['total'] as num?)?.toInt() ?? 0;
          final currentTotal = categoryContent[category]?.length ?? 0;
          categoryHasMore[category] = currentTotal < total;

          debugPrint(
            'Category: $category, Total items: $currentTotal, Has more: ${categoryHasMore[category]}',
          );

          // Update displayed content if this is the selected category
          if (category == categories[selectedCategory.value]) {
            filteredContent.assignAll(categoryContent[category] ?? []);
            currentPage.value = categoryPage[category] ?? 1;
            hasMore.value = categoryHasMore[category] ?? false;
          }
        } else {
          if (!loadMore) {
            categoryContent[category] = [];
            if (category == categories[selectedCategory.value]) {
              filteredContent.clear();
            }
          }
        }
      } else {
        final message = response.data?['message'] ?? 'Failed to load content';
        errorMessage.value = message;
        debugPrint('API Error: $message');

        if (!loadMore) {
          categoryContent[category] = [];
          if (category == categories[selectedCategory.value]) {
            filteredContent.clear();
          }
        }
      }
    } catch (e) {
      errorMessage.value = '';
      debugPrint('Error loading content: $e — using static fallback');

      if (!loadMore) {
        // Fall back to static tennis content
        final staticItems = MockContentProvider.getExploreItems(category: category);
        categoryContent[category] = staticItems;
        if (category == categories[selectedCategory.value]) {
          filteredContent.assignAll(staticItems);
        }
        categoryHasMore[category] = false;
      }
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreContent() async {
    final category = categories[selectedCategory.value];
    await loadContentForCategory(category, loadMore: true);
  }

  Future<void> refreshContent() async {
    final category = categories[selectedCategory.value];
    await loadContentForCategory(category);
  }

  void selectCategory(int index) {
    // Clear search if active when tapping a category
    if (isSearching.value) {
      searchQuery.value = '';
      isSearching.value = false;
      searchResults.clear();
    }

    selectedCategory.value = index;
    final category = categories[index];

    // Clear any previous error when switching categories
    errorMessage.value = '';

    // Check if we already have content for this category
    if (categoryContent[category]?.isEmpty ?? true) {
      // Load content for this category
      loadContentForCategory(category);
    } else {
      // Use cached content and ensure pagination state is in sync
      filteredContent.assignAll(categoryContent[category] ?? []);
      currentPage.value = categoryPage[category] ?? 1;
      hasMore.value = categoryHasMore[category] ?? false;
      // Reset loading states when using cached content
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> playMeditation(ExploreItem item, String type, String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final token = await SharedPrefHelper.getAccessToken();

    // Add to recently played
    addToRecentlyPlayed(item);

    try {
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
            'contentType':
                item.contentType[Random().nextInt(item.contentType.length)],
          },
        );
        return;
      }

      final response = await ApiService.post(
        endpoint: 'content/progress',
        body: {"contentType": type, "contentId": id},
        token: token,
      );

      if (response.data['success'] == true ||
          response.data['data']['lock'] == true) {
        debugPrint('Progress API Response: ${response.data}');

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
            'contentType':
                item.contentType[Random().nextInt(item.contentType.length)],
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
      errorMessage.value = 'Failed to play meditation: $e';
      debugPrint('Error in playMeditation: $e');
      Get.snackbar(
        'Failed to play audio',
        'Make sure you are connected to the internet',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void playAllExplore(ExploreItem item) {
    // Add to recently played
    addToRecentlyPlayed(item);

    Get.toNamed(
      '/audio-player',
      arguments: {
        'id': item.id,
        'author': item.author,
        'imageUrl': item.thumbnail,
        'title': item.title,
        'category': item.category,
        'description': item.description,
        'duration': 1,
        'audio': item.content,
        'accessType': item.accessType,
        'isLocked': item.isLocked,
        'item': item,
        'modelType': 'ExploreItem',
      },
    );
  }

  void playSeries(ExploreItem item) {
    // Add to recently played
    addToRecentlyPlayed(item);

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
      },
    );
  }
}
