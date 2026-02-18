import 'package:get/get.dart';

class FavoriteResponse {
  final bool success;
  final String message;
  final FavoriteData data;

  FavoriteResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: FavoriteData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class FavoriteData {
  final Meta meta;
  final List<FavoriteItem> data;
  final bool hasMore; // Add this for pagination

  FavoriteData({
    required this.meta,
    required this.data,
    required this.hasMore,
  });

  factory FavoriteData.fromJson(Map<String, dynamic> json) {
    final meta = Meta.fromJson(json['meta'] ?? {});
    final dataList = (json['data'] as List<dynamic>?)
            ?.map((item) => FavoriteItem.fromJson(item))
            .toList() ??
        [];
    
    final totalPages = (meta.total / meta.limit).ceil();
    final hasMore = meta.page < totalPages;
    
    return FavoriteData(
      meta: meta,
      data: dataList,
      hasMore: hasMore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
      'hasMore': hasMore,
    };
  }
}

class FavoriteItem {
  final String type;
  final String favoriteId; // Changed from 'id' to 'favoriteId' to match JSON
  final DateTime createdAt;
  final FavoriteContent item;

  FavoriteItem({
    required this.type,
    required this.favoriteId,
    required this.createdAt,
    required this.item,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      type: json['type']?.toString() ?? '',
      favoriteId: json['favoriteId']?.toString() ?? '', // Updated field name
      createdAt: _parseDateTime(json['createdAt']),
      item: FavoriteContent.fromJson(json['item'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'favoriteId': favoriteId,
      'createdAt': createdAt.toIso8601String(),
      'item': item.toJson(),
    };
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper method to get itemId for compatibility with existing code
  String get itemId => item.id;
  String get id => favoriteId; // Keep backward compatibility
}

class FavoriteContent {
  final String id;
  final List<String> contentType;
  final String accessType;
  final String title;
  final String description;
  final String content;
  final String author;
  final String thumbnail;
  final String duration;
  final int views;
  final int spendTime;
  final bool isFeature;
  final bool masterClass;
  final bool todayDailies;
  final bool mostPopular;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic categoryId;
  final RxBool isFavoriteRx; // Add reactive favorite state

  FavoriteContent({
    required this.id,
    required this.contentType,
    required this.accessType,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.spendTime,
    required this.isFeature,
    required this.masterClass,
    required this.todayDailies,
    required this.mostPopular,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    bool isFavorite = true, // Always true since it's in favorites
  }) : isFavoriteRx = RxBool(isFavorite);

  factory FavoriteContent.fromJson(Map<String, dynamic> json) {
    return FavoriteContent(
      id: json['id']?.toString() ?? '',
      contentType:
          (json['contentType'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      accessType: json['accessType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '0:00',
      views: (json['views'] as num?)?.toInt() ?? 0,
      spendTime: (json['spendTime'] as num?)?.toInt() ?? 0,
      isFeature: json['isFeature'] ?? false,
      masterClass: json['masterClass'] ?? false,
      todayDailies: json['todayDailies'] ?? false,
      mostPopular: json['mostPopular'] ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      categoryId: json['categoryId'],
      isFavorite: true, // Always true for favorites
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'accessType': accessType,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'thumbnail': thumbnail,
      'duration': duration,
      'views': views,
      'spendTime': spendTime,
      'isFeature': isFeature,
      'masterClass': masterClass,
      'todayDailies': todayDailies,
      'mostPopular': mostPopular,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper method for compatibility with existing code
  String get type => contentType.isNotEmpty ? contentType.first : '';

  // Toggle favorite status (should remove from favorites)
  void toggleFavorite() {
    isFavoriteRx.value = false; // Removing from favorites
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