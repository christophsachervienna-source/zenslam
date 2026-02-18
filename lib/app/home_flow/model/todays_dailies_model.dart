import 'package:get/get.dart';

class TodaysDailiesModel {
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

  TodaysDailiesModel({
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

  factory TodaysDailiesModel.fromJson(Map<String, dynamic> json) {
    return TodaysDailiesModel(
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

  // Empty constructor
  factory TodaysDailiesModel.empty() {
    return TodaysDailiesModel(
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

  // Helper method to parse content type array
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

  // Getters for compatibility with existing code
  String get imageUrl => thumbnail;
  String get audio => content;
  bool get isLocked => accessType == 'PAID';
  String get category => contentType.isNotEmpty ? contentType.first : 'General';
  int get serialNo => 0;
  bool get isDisplay => todayDailies;

  // Helper method to parse duration string to Duration object
  Duration get durationObject {
    return _parseDuration(duration);
  }

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
      final seconds = int.tryParse(durationString) ?? 0;
      return Duration(seconds: seconds);
    }
  }

  String get formattedDuration => duration;

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

  @override
  String toString() {
    return 'TodaysDailiesModel{title: $title, contentType: $contentType, author: $author, id: $id}';
  }
}

// Add this model for pagination response
class TodaysDailiesResponse {
  final bool success;
  final String message;
  final TodaysDailiesData data;

  TodaysDailiesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TodaysDailiesResponse.fromJson(Map<String, dynamic> json) {
    return TodaysDailiesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TodaysDailiesData.fromJson(json['data'] ?? {}),
    );
  }
}

class TodaysDailiesData {
  final Meta meta;
  final List<TodaysDailiesModel> data;
  final bool hasMore;

  TodaysDailiesData({
    required this.meta,
    required this.data,
    required this.hasMore,
  });

  factory TodaysDailiesData.fromJson(Map<String, dynamic> json) {
    final meta = Meta.fromJson(json['meta'] ?? {});
    final dataList = (json['data'] as List<dynamic>?)
            ?.map((item) => TodaysDailiesModel.fromJson(item))
            .toList() ??
        [];
    
    final totalPages = (meta.total / meta.limit).ceil();
    final hasMore = meta.page < totalPages;
    
    return TodaysDailiesData(
      meta: meta,
      data: dataList,
      hasMore: hasMore,
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
}