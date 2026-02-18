import 'package:get/get.dart';

class EpisodeModel {
  final String id;
  final String title;
  final String description;
  final String accessType;
  final String content;
  final String thumbnail;
  final String author;
  final String duration;
  final int views;
  final int spendTime;
  final int? serialNo;
  final String createdAt;
  final String updatedAt;

  EpisodeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.accessType,
    required this.content,
    required this.thumbnail,
    required this.author,
    required this.duration,
    required this.views,
    required this.spendTime,
    this.serialNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      accessType: json['accessType'] ?? 'FREE',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      author: json['author'] ?? '',
      duration: json['duration'] ?? '',
      views: json['views'] ?? 0,
      spendTime: json['spendTime'] ?? 0,
      serialNo: json['serialNo'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'accessType': accessType,
      'content': content,
      'thumbnail': thumbnail,
      'author': author,
      'duration': duration,
      'views': views,
      'spendTime': spendTime,
      'serialNo': serialNo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Check if episode is locked
  bool get isLocked => accessType == 'PREMIUM';
}

// ============= SERIES CATEGORY MODEL =============

class SeriesCategory {
  final String id;
  final String name;
  final String title;
  final String description;
  final String thumbnail;
  final List<CategoryFavorite> categoryFavorites;
  final RxBool isFavoriteRx; // Add RxBool for reactive favorite state

  SeriesCategory({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.categoryFavorites,
    bool isFavorite = false,
  }) : isFavoriteRx = RxBool(isFavorite);

  // Check if category is favorite
  bool get isFavorite =>
      categoryFavorites.isNotEmpty && categoryFavorites.first.favorites;

  factory SeriesCategory.fromJson(Map<String, dynamic> json) {
    final isFavorite =
        (json['categoryFavorites'] as List?)?.isNotEmpty == true &&
        (json['categoryFavorites'] as List).first['favorites'] == true;

    return SeriesCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      categoryFavorites:
          (json['categoryFavorites'] as List?)
              ?.map((e) => CategoryFavorite.fromJson(e))
              .toList() ??
          [],
      isFavorite: isFavorite,
    );
  }

  // Toggle favorite status
  void toggleFavorite() {
    isFavoriteRx.value = !isFavoriteRx.value;
    // You can also update categoryFavorites if needed
    if (categoryFavorites.isNotEmpty) {
      categoryFavorites.first = CategoryFavorite(favorites: isFavoriteRx.value);
    } else {
      categoryFavorites.add(CategoryFavorite(favorites: isFavoriteRx.value));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'categoryFavorites': categoryFavorites.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryFavorite {
  final bool favorites;

  CategoryFavorite({required this.favorites});

  factory CategoryFavorite.fromJson(Map<String, dynamic> json) {
    return CategoryFavorite(favorites: json['favorites'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'favorites': favorites};
  }
}

// ============= CATEGORIES RESPONSE =============
class CategoriesResponse {
  final bool success;
  final String message;
  final CategoriesData data;

  CategoriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CategoriesData.fromJson(json['data'] ?? {}),
    );
  }
}

// Update CategoriesData to include hasMore
class CategoriesData {
  final MetaData meta;
  final List<SeriesCategory> categories;
  final bool hasMore;

  CategoriesData({
    required this.meta,
    required this.categories,
    required this.hasMore,
  });

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    final meta = MetaData.fromJson(json['meta'] ?? {});
    final categoriesList =
        (json['data'] as List?)
            ?.map((e) => SeriesCategory.fromJson(e))
            .toList() ??
        [];

    final totalPages = (meta.total / meta.limit).ceil();
    final hasMore = meta.page < totalPages;

    return CategoriesData(
      meta: meta,
      categories: categoriesList,
      hasMore: hasMore,
    );
  }
}

// Update MetaData class
class MetaData {
  final int page;
  final int limit;
  final int total;

  MetaData({required this.page, required this.limit, required this.total});

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============= SERIES EPISODES RESPONSE =============
class SeriesEpisodesResponse {
  final bool success;
  final String message;
  final SeriesEpisodesData data;

  SeriesEpisodesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SeriesEpisodesResponse.fromJson(Map<String, dynamic> json) {
    return SeriesEpisodesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SeriesEpisodesData.fromJson(json['data'] ?? {}),
    );
  }
}

class SeriesEpisodesData {
  final MetaData meta;
  final List<EpisodeModel> episodes;

  SeriesEpisodesData({required this.meta, required this.episodes});

  factory SeriesEpisodesData.fromJson(Map<String, dynamic> json) {
    return SeriesEpisodesData(
      meta: MetaData.fromJson(json['meta'] ?? {}),
      episodes:
          (json['data'] as List?)
              ?.map((e) => EpisodeModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// ============= SERIES MODEL (FOR PLAYER) =============
class SeriesModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String thumbnail;
  final List<EpisodeModel> episodes;

  SeriesModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.episodes,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      episodes:
          (json['episodes'] as List?)
              ?.map((e) => EpisodeModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }

  // Create SeriesModel from SeriesCategory
  factory SeriesModel.fromCategory(
    SeriesCategory category,
    List<EpisodeModel> episodes,
  ) {
    return SeriesModel(
      id: category.id,
      name: category.name,
      title: category.title,
      description: category.description,
      thumbnail: category.thumbnail,
      episodes: episodes,
    );
  }
}
