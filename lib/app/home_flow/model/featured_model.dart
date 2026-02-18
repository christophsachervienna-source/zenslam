import 'package:get/get.dart';

class FeaturedModel {
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
  final String? categoryId;
  final RxBool isFavorite;

  FeaturedModel({
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
    this.categoryId,
    bool isFavorite = false,
  }) : isFavorite = RxBool(isFavorite);

  factory FeaturedModel.fromJson(Map<String, dynamic> json) {
    return FeaturedModel(
      id: json['id']?.toString() ?? '',
      contentType: _parseContentType(json['contentType']),
      accessType: json['accessType']?.toString() ?? 'FREE',
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      content: json['content']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Unknown Author',
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
      categoryId: json['categoryId']?.toString(),
      isFavorite: false,
    );
  }

  // Helper method to parse content type array with null safety
  static List<String> _parseContentType(dynamic contentType) {
    if (contentType == null) {
      return ['General'];
    }
    if (contentType is List) {
      return contentType.map((item) => item.toString()).toList();
    }
    return ['General'];
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Getter for Duration object from duration string
  Duration get durationObject {
    return _parseDuration(duration);
  }

  // Helper method to parse duration string like "1:38" to Duration
  static Duration _parseDuration(String durationString) {
    if (durationString.isEmpty) {
      return Duration.zero;
    }

    final parts = durationString.split(':');
    if (parts.length == 2) {
      // Format: "minutes:seconds"
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    } else if (parts.length == 3) {
      // Format: "hours:minutes:seconds"
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } else {
      // Try to parse as seconds integer
      final seconds = int.tryParse(durationString) ?? 0;
      return Duration(seconds: seconds);
    }
  }

  // Getter for formatted duration (same as original string)
  String get formattedDuration => duration;

  // Helper getters for compatibility with existing code
  String get imageUrl => thumbnail;
  String get audio => content;

  // Get primary category from contentType array
  String get categoryName =>
      contentType.isNotEmpty ? contentType.first : 'General';

  // Get category (alias for categoryName)
  String get category => categoryName;

  // Get type (could be derived from contentType or other fields)
  String get type =>
      contentType.isNotEmpty ? contentType.join(', ') : 'General';

  // Serial number not in JSON, can be set separately
  int get serialNo => 0;

  // Recommended flag not in JSON, can use mostPopular or custom logic
  bool get recommended => mostPopular;

  // Check if content is locked based on access type
  bool get isLocked => accessType == 'PAID';

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

  // Copy with method for updating properties
  FeaturedModel copyWith({
    String? id,
    List<String>? contentType,
    String? accessType,
    String? title,
    String? description,
    String? content,
    String? author,
    String? thumbnail,
    String? duration,
    int? views,
    int? spendTime,
    bool? isFeature,
    bool? masterClass,
    bool? todayDailies,
    bool? mostPopular,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
    bool? isFavorite,
  }) {
    return FeaturedModel(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      accessType: accessType ?? this.accessType,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      spendTime: spendTime ?? this.spendTime,
      isFeature: isFeature ?? this.isFeature,
      masterClass: masterClass ?? this.masterClass,
      todayDailies: todayDailies ?? this.todayDailies,
      mostPopular: mostPopular ?? this.mostPopular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() {
    return 'FeaturedModel(id: $id, title: $title, contentType: $contentType, duration: $duration)';
  }
}

// Add these models for pagination response
class FeaturedResponse {
  final bool success;
  final String message;
  final FeaturedData data;

  FeaturedResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FeaturedResponse.fromJson(Map<String, dynamic> json) {
    return FeaturedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: FeaturedData.fromJson(json['data'] ?? {}),
    );
  }
}

class FeaturedData {
  final Meta meta;
  final List<FeaturedModel> data;
  final bool hasMore;

  FeaturedData({required this.meta, required this.data, required this.hasMore});

  factory FeaturedData.fromJson(Map<String, dynamic> json) {
    final meta = Meta.fromJson(json['meta'] ?? {});
    final dataList =
        (json['data'] as List<dynamic>?)
            ?.map((item) => FeaturedModel.fromJson(item))
            .toList() ??
        [];

    final totalPages = (meta.total / meta.limit).ceil();
    final hasMore = meta.page < totalPages;

    return FeaturedData(meta: meta, data: dataList, hasMore: hasMore);
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
    };
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
    return {
      'page': page,
      'limit': limit,
      'total': total,
    };
  }
}
