import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:get/get.dart';

// models/rating_model.dart
class ExploreAllResponseModel {
  final bool success;
  final String message;
  final ExploreAllData data;

  ExploreAllResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExploreAllResponseModel.fromJson(Map<String, dynamic> json) {
    return ExploreAllResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ExploreAllData.fromJson(json['data'] ?? {}),
    );
  }
}

class ExploreAllData {
  final Meta meta;
  final List<ExploreItem> data;

  ExploreAllData({required this.meta, required this.data});

  factory ExploreAllData.fromJson(Map<String, dynamic> json) {
    return ExploreAllData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ExploreItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Meta {
  final int page;
  final int limit;
  final int total;

  Meta({required this.page, required this.limit, required this.total});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'total': total};
  }
}

class RatingResponse {
  final bool success;
  final String message;
  final RatingData data;

  RatingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RatingData.fromJson(json['data']),
    );
  }
}

class RatingData {
  final Meta meta;
  final List<Rating> data;

  RatingData({required this.meta, required this.data});

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      meta: Meta.fromJson(json['meta']),
      data: (json['data'] as List)
          .map((rating) => Rating.fromJson(rating))
          .toList(),
    );
  }
}

class Rating {
  final String id;
  final String userId;
  final double rating;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.rating,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rating': rating,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PlayerItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  bool isFavorite;
  bool isLocked;

  PlayerItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.isFavorite = false,
    this.isLocked = true,
  });

  PlayerItem copyWith({
    String? imageUrl,
    String? title,
    String? subtitle,
    bool? isFavorite,
    bool? isLocked,
  }) {
    return PlayerItem(
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class Player {
  final String image;
  final String title;
  final String subtitle;
  RxBool isFavorite;

  Player({
    required this.image,
    required this.title,
    required this.subtitle,
    bool favorite = false,
  }) : isFavorite = RxBool(favorite);
}

class CardItem {
  final String image;
  final String title;
  final String subtitle;
  bool isFavorite;
  bool isLocked;
  bool hasVideo;

  CardItem({
    required this.image,
    required this.title,
    required this.subtitle,
    this.isFavorite = false,
    this.isLocked = false,
    this.hasVideo = false,
  });
}

class MindfulnessItem {
  final String category;
  final String title;
  final String subtitle;
  final String imageUrl;
  bool isFavorite;
  bool isLocked;

  MindfulnessItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isFavorite = false,
    this.isLocked = true,
  });
}

class SeriesResponse {
  final bool success;
  final String message;
  final SeriesData data;

  SeriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SeriesResponse.fromJson(Map<String, dynamic> json) {
    return SeriesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SeriesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class SeriesData {
  final Meta meta;
  final List<SeriesCategory> data;

  SeriesData({required this.meta, required this.data});

  factory SeriesData.fromJson(Map<String, dynamic> json) {
    return SeriesData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => SeriesCategory.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class SeriesCategory {
  final String id;
  final String name;
  final String title;
  final String description;
  final String thumbnail;
  final bool isFavorite;
  final List<CategoryFavorite> categoryFavorites;

  SeriesCategory({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.isFavorite,
    required this.categoryFavorites,
  });

  factory SeriesCategory.fromJson(Map<String, dynamic> json) {
    final favoritesList = (json['categoryFavorites'] as List<dynamic>?) ?? [];

    return SeriesCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      isFavorite:
          favoritesList.isNotEmpty &&
          favoritesList.any((fav) => fav['favorites'] == true),
      categoryFavorites: favoritesList
          .map((fav) => CategoryFavorite.fromJson(fav))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'categoryFavorites': categoryFavorites
          .map((fav) => fav.toJson())
          .toList(),
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

class CategoriesData {
  final Meta meta;
  final List<SeriesCategory> categories;

  CategoriesData({required this.meta, required this.categories});

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    final categoriesList = json['data'] as List? ?? [];
    return CategoriesData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      categories: categoriesList
          .map((category) => SeriesCategory.fromJson(category))
          .toList(),
    );
  }
}

class ExploreAllItem {
  final String author;
  final String imageUrl;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String audio;
  final bool isLocked;
  RxBool isFavorite;

  ExploreAllItem({
    required this.author,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.audio,
    this.isLocked = false,
    bool isFavorite = false,
  }) : isFavorite = isFavorite.obs;
}

class SeriesCategoryResponse {
  final bool success;
  final String message;
  final SeriesCategoryData data;

  SeriesCategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SeriesCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SeriesCategoryResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: SeriesCategoryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class SeriesCategoryData {
  final Meta meta;
  final List<SeriesCategoryModel> data;

  SeriesCategoryData({required this.meta, required this.data});

  factory SeriesCategoryData.fromJson(Map<String, dynamic> json) {
    return SeriesCategoryData(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List)
          .map(
            (category) =>
                SeriesCategoryModel.fromJson(category as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}

class SeriesCategoryModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String thumbnail;

  SeriesCategoryModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.thumbnail,
  });

  factory SeriesCategoryModel.fromJson(Map<String, dynamic> json) {
    return SeriesCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
    };
  }
}
