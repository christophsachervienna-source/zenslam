import 'package:zenslam/core/data/tennis_content_library.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:zenslam/app/mentor_flow/controller/recommendation_model.dart';
import 'package:zenslam/app/mentor_flow/controller/most_popular_model.dart';
import 'package:zenslam/app/home_flow/model/featured_model.dart';
import 'package:zenslam/app/home_flow/model/series_model.dart';

/// Provides static content from the tennis content library,
/// converting TennisSession/TennisCategory into the app's existing model types.
/// Used as fallback when API calls fail (empty baseUrl during development).
class MockContentProvider {
  static final _now = DateTime.now();

  /// Pick a meditation thumbnail based on session id (cycles through 5 images)
  static String _thumbnailForSession(String sessionId) {
    final index = sessionId.hashCode.abs() % ImagePath.meditationThumbnails.length;
    return ImagePath.meditationThumbnails[index];
  }

  /// Get the category name for a given categoryId
  static String _categoryName(String categoryId) {
    return tennisCategories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => tennisCategories.first,
        )
        .name;
  }

  /// Convert a TennisSession to an ExploreItem
  static ExploreItem _toExploreItem(TennisSession session) {
    final categoryName = _categoryName(session.categoryId);
    return ExploreItem(
      id: session.id,
      contentType: [categoryName],
      accessType: session.isPremium ? 'PAID' : 'FREE',
      title: session.title,
      description: session.description,
      content: '',
      author: 'Zenslam',
      thumbnail: _thumbnailForSession(session.id),
      duration: '${session.durationMinutes}:00',
      views: 0,
      spendTime: 0,
      isFeature: false,
      masterClass: false,
      todayDailies: false,
      mostPopular: false,
      createdAt: _now,
      updatedAt: _now,
      categoryId: session.categoryId,
    );
  }

  /// Convert a TennisSession to a TodaysDailiesModel
  static TodaysDailiesModel _toDailiesModel(TennisSession session) {
    final categoryName = _categoryName(session.categoryId);
    return TodaysDailiesModel(
      id: session.id,
      contentType: [categoryName],
      accessType: session.isPremium ? 'PAID' : 'FREE',
      title: session.title,
      description: session.description,
      content: '',
      author: 'Zenslam',
      thumbnail: _thumbnailForSession(session.id),
      duration: '${session.durationMinutes}:00',
      views: 0,
      spendTime: 0,
      isFeature: false,
      masterClass: false,
      todayDailies: true,
      mostPopular: false,
      createdAt: _now,
      updatedAt: _now,
      categoryId: session.categoryId,
    );
  }

  /// Convert a TennisSession to a RecommendationModel
  static RecommendationModel _toRecommendationModel(TennisSession session) {
    final categoryName = _categoryName(session.categoryId);
    return RecommendationModel(
      id: session.id,
      contentType: [categoryName],
      accessType: session.isPremium ? 'PAID' : 'FREE',
      title: session.title,
      description: session.description,
      content: '',
      thumbnail: _thumbnailForSession(session.id),
      author: 'Zenslam',
      duration: '${session.durationMinutes}:00',
      views: 0,
      spendTime: 0,
      isFeature: false,
      masterClass: false,
      todayDailies: false,
      mostPopular: false,
      createdAt: _now,
      updatedAt: _now,
      categoryId: session.categoryId,
    );
  }

  /// Convert a TennisSession to a MostPopularModel
  static MostPopularModel _toMostPopularModel(TennisSession session) {
    final categoryName = _categoryName(session.categoryId);
    return MostPopularModel(
      id: session.id,
      contentType: [categoryName],
      accessType: session.isPremium ? 'PAID' : 'FREE',
      title: session.title,
      description: session.description,
      content: '',
      author: 'Zenslam',
      thumbnail: _thumbnailForSession(session.id),
      duration: '${session.durationMinutes}:00',
      views: 0,
      spendTime: 0,
      isFeature: false,
      masterClass: false,
      todayDailies: false,
      mostPopular: true,
      createdAt: _now,
      updatedAt: _now,
      categoryId: session.categoryId,
    );
  }

  /// Convert a TennisSession to a FeaturedModel
  static FeaturedModel _toFeaturedModel(TennisSession session) {
    final categoryName = _categoryName(session.categoryId);
    return FeaturedModel(
      id: session.id,
      contentType: [categoryName],
      accessType: session.isPremium ? 'PAID' : 'FREE',
      title: session.title,
      description: session.description,
      content: '',
      author: 'Zenslam',
      thumbnail: _thumbnailForSession(session.id),
      duration: '${session.durationMinutes}:00',
      views: 0,
      spendTime: 0,
      isFeature: true,
      masterClass: false,
      todayDailies: false,
      mostPopular: false,
      createdAt: _now,
      updatedAt: _now,
      categoryId: session.categoryId,
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Returns explore items, optionally filtered by category name.
  /// If category is 'All' or null, returns all sessions.
  static List<ExploreItem> getExploreItems({String? category}) {
    if (category == null || category == 'All') {
      return tennisSessions.map(_toExploreItem).toList();
    }

    // Find the categoryId for this category name
    final cat = tennisCategories.firstWhere(
      (c) => c.name == category,
      orElse: () => tennisCategories.first,
    );

    return tennisSessions
        .where((s) => s.categoryId == cat.id)
        .map(_toExploreItem)
        .toList();
  }

  /// Returns 5 sessions as daily picks (first free session from each of the first 5 categories).
  static List<TodaysDailiesModel> getDailies() {
    final picks = <TodaysDailiesModel>[];
    for (final cat in tennisCategories.take(5)) {
      final session = tennisSessions.firstWhere(
        (s) => s.categoryId == cat.id,
      );
      picks.add(_toDailiesModel(session));
    }
    return picks;
  }

  /// Returns category name list for explore tabs.
  static List<String> getCategories() {
    return ['All', ...tennisCategories.map((c) => c.name)];
  }

  /// Returns 5 featured sessions as recommendations.
  static List<RecommendationModel> getRecommendations() {
    // Pick one session from each of the first 5 categories
    final picks = <RecommendationModel>[];
    for (final cat in tennisCategories.take(5)) {
      final session = tennisSessions.firstWhere(
        (s) => s.categoryId == cat.id,
      );
      picks.add(_toRecommendationModel(session));
    }
    return picks;
  }

  /// Returns most popular items (first session from each category).
  static List<MostPopularModel> getMostPopular() {
    return tennisCategories.map((cat) {
      final session = tennisSessions.firstWhere(
        (s) => s.categoryId == cat.id,
      );
      return _toMostPopularModel(session);
    }).toList();
  }

  /// Returns featured items (second session from each category, if available).
  static List<FeaturedModel> getFeatured() {
    final picks = <FeaturedModel>[];
    for (final cat in tennisCategories) {
      final sessions = tennisSessions.where((s) => s.categoryId == cat.id).toList();
      if (sessions.length > 1) {
        picks.add(_toFeaturedModel(sessions[1]));
      } else if (sessions.isNotEmpty) {
        picks.add(_toFeaturedModel(sessions.first));
      }
    }
    return picks;
  }

  /// Returns SeriesCategory list from tennis categories.
  static List<SeriesCategory> getSeriesCategories() {
    return tennisCategories.map((cat) {
      return SeriesCategory(
        id: cat.id,
        name: cat.name,
        title: cat.name,
        description: cat.description,
        thumbnail: _thumbnailForSession(cat.id),
        categoryFavorites: [],
      );
    }).toList();
  }
}
