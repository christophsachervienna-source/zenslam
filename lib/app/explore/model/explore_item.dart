import 'package:get/get.dart';

class ExploreResponse {
  final bool success;
  final String message;
  final ExploreData data;

  ExploreResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExploreResponse.fromJson(Map<String, dynamic> json) {
    return ExploreResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ExploreData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class ExploreData {
  final Meta meta;
  final List<ExploreItem> data;
  final bool hasMore; // Add this field for pagination

  ExploreData({
    required this.meta,
    required this.data,
    this.hasMore = false,
  });

  factory ExploreData.fromJson(Map<String, dynamic> json) {
    final currentPage = (json['meta']['page'] as num?)?.toInt() ?? 1;
    final totalPages = (json['meta']['total'] as num?)?.toInt() ?? 0;
    final limit = (json['meta']['limit'] as num?)?.toInt() ?? 10;
    
    return ExploreData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ExploreItem.fromJson(item))
              .toList() ??
          [],
      hasMore: currentPage * limit < totalPages, // Calculate if more pages exist
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

class ExploreItem {
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

  ExploreItem({
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

  factory ExploreItem.fromJson(Map<String, dynamic> json) {
    return ExploreItem(
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

  // Empty constructor for null safety
  factory ExploreItem.empty() {
    return ExploreItem(
      id: '',
      contentType: [],
      accessType: 'FREE',
      title: '',
      description: '',
      content: '',
      author: '',
      thumbnail: '',
      duration: '0:00',
      views: 0,
      spendTime: 0,
      isFeature: false,
      masterClass: false,
      todayDailies: false,
      mostPopular: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

  // Helper getters for compatibility with existing code
  String get imageUrl => thumbnail;
  String get audio => content;

  // Get primary category from contentType array
  String get category => contentType.isNotEmpty ? contentType.first : 'General';

  // Get serial number (not in JSON, can be set separately)
  int get serialNo => 0;

  // Check if content is locked based on access type
  bool get isLocked => accessType == 'PAID';

  // Get formatted duration (same as original string)
  String get formattedDuration => duration;

  // For video class compatibility (not in JSON)
  String? get videoClass => null;

  // Get type for compatibility
  String get type =>
      contentType.isNotEmpty ? contentType.join(', ') : 'General';

  // Recommended flag for compatibility
  bool get recommended => mostPopular;

  // String getters for createdAt and updatedAt for backward compatibility
  String get createdAtString => createdAt.toIso8601String();
  String get updatedAtString => updatedAt.toIso8601String();

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
  ExploreItem copyWith({
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
    return ExploreItem(
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
      isFavorite: isFavorite ?? this.isFavorite.value,
    );
  }

  @override
  String toString() {
    return 'ExploreItem(id: $id, title: $title, contentType: $contentType, accessType: $accessType)';
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
