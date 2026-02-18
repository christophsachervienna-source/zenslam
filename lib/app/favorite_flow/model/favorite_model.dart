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
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class FavoriteData {
  final FavoriteMeta meta;
  final List<FavoriteItem> data;
  final bool hasMore;

  FavoriteData({
    required this.meta,
    required this.data,
    required this.hasMore,
  });

  factory FavoriteData.fromJson(Map<String, dynamic> json) {
    return FavoriteData(
      meta: FavoriteMeta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => FavoriteItem.fromJson(item))
              .toList() ??
          [],
      hasMore: json['hasMore'] ?? false,
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

class FavoriteMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  FavoriteMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory FavoriteMeta.fromJson(Map<String, dynamic> json) {
    return FavoriteMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class FavoriteItem {
  final String id;
  final String itemId;
  final String userId;
  final String type;
  final FavoriteItemData item;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteItem({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.type,
    required this.item,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================
  // Compatibility getters - delegate to nested item
  // ============================================
  // These allow FavoriteItem to be used like other content models
  // by exposing the nested FavoriteItemData properties directly

  /// Delegate to nested item's category
  String get category => item.category;

  /// Delegate to nested item's title
  String get title => item.title;

  /// Delegate to nested item's description
  String get description => item.description;

  /// Delegate to nested item's thumbnail
  String get thumbnail => item.thumbnail;

  /// Delegate to nested item's audio (content URL)
  String get audio => item.audio;

  /// Delegate to nested item's imageUrl (thumbnail)
  String get imageUrl => item.imageUrl;

  /// Delegate to nested item's contentType
  List<String> get contentType => item.contentType;

  /// Delegate to nested item's author
  String get author => item.author;

  /// Delegate to nested item's duration
  String get duration => item.duration;

  /// Delegate to nested item's accessType
  String get accessType => item.accessType;

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    // Parse item first to get its ID
    final itemData = FavoriteItemData.fromJson(json['item'] ?? {});

    return FavoriteItem(
      id: json['favoriteId'] ?? json['_id'] ?? json['id'] ?? '',
      // itemId should be the content's ID, which is inside item.id
      itemId: json['itemId'] ?? itemData.id,
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      item: itemData,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'itemId': itemId,
      'userId': userId,
      'type': type,
      'item': item.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FavoriteItemData {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String content;
  final String duration;
  final String type;
  final String category;
  final String author;
  final String accessType;
  final bool isLocked;

  FavoriteItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.content,
    required this.duration,
    required this.type,
    required this.category,
    required this.author,
    required this.accessType,
    required this.isLocked,
  });

  // ============================================
  // Compatibility getters for other model formats
  // ============================================
  // These allow FavoriteItemData to be used interchangeably
  // with other content models (ExploreItem, TodaysDailiesModel, etc.)

  /// Alias for `content` - audio URL (other models use `audio`)
  String get audio => content;

  /// Alias for `thumbnail` - image URL (other models use `imageUrl`)
  String get imageUrl => thumbnail;

  /// Returns type as List for compatibility (other models use `contentType` as List)
  List<String> get contentType => type.isNotEmpty ? [type] : [];

  static String _parseType(Map<String, dynamic> json) {
    // Handle contentType as array (e.g., ["Purpose"])
    if (json['contentType'] is List && (json['contentType'] as List).isNotEmpty) {
      return (json['contentType'] as List).first.toString();
    }
    return json['type'] ?? json['className'] ?? '';
  }

  static String _parseCategory(Map<String, dynamic> json) {
    // Handle contentType as array for category too
    if (json['contentType'] is List && (json['contentType'] as List).isNotEmpty) {
      return (json['contentType'] as List).first.toString();
    }
    return json['category'] ?? '';
  }

  factory FavoriteItemData.fromJson(Map<String, dynamic> json) {
    return FavoriteItemData(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? json['imageUrl'] ?? '',
      content: json['content'] ?? json['audio'] ?? '',
      duration: json['duration'] ?? '',
      type: _parseType(json),
      category: _parseCategory(json),
      author: json['author'] ?? '',
      accessType: json['accessType'] ?? 'free',
      isLocked: json['isLocked'] ?? json['accessType'] == 'paid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'content': content,
      'duration': duration,
      'type': type,
      'category': category,
      'author': author,
      'accessType': accessType,
      'isLocked': isLocked,
    };
  }
}
