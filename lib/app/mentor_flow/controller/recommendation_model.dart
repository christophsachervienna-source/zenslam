import 'package:get/get.dart';

class RecommendationModel {
  final String id;
  final List<String> contentType;
  final String accessType;
  final String title;
  final String description;
  final String content;
  final String thumbnail;
  final String author;
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

  RecommendationModel({
    required this.id,
    required this.contentType,
    required this.accessType,
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnail,
    required this.author,
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

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id']?.toString() ?? '',
      contentType: json['contentType'] != null
          ? List<String>.from(json['contentType'])
          : <String>[],
      accessType: json['accessType']?.toString() ?? 'FREE',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '0:00',
      views: (json['views'] as num?)?.toInt() ?? 0,
      spendTime: (json['spendTime'] as num?)?.toInt() ?? 0,
      isFeature: json['isFeature'] ?? false,
      masterClass: json['masterClass'] ?? false,
      todayDailies: json['todayDailies'] ?? false,
      mostPopular: json['mostPopular'] ?? false,
      createdAt: _parseDateTime(json['createdAt'])!,
      updatedAt: _parseDateTime(json['updatedAt'])!,
      categoryId: json['categoryId']?.toString(),
      isFavorite: false,
    );
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Helper getters for compatibility with existing code
  String get imageUrl => thumbnail;
  String get audio => content;
  bool get isLocked => accessType == 'PAID';
  String get category => contentType.isNotEmpty ? contentType.first : 'General';

  // Toggle favorite
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'accessType': accessType,
      'title': title,
      'description': description,
      'content': content,
      'thumbnail': thumbnail,
      'author': author,
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

  bool hasCategory(String category) {
    return contentType.contains(category);
  }

  String get categoriesString => contentType.join(', ');

  @override
  String toString() {
    return 'RecommendationModel(id: $id, title: $title, contentType: $contentType)';
  }
}

// Add this model for pagination response
class RecommendationsResponse {
  final bool success;
  final String message;
  final RecommendationsData data;

  RecommendationsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RecommendationsData.fromJson(json['data'] ?? {}),
    );
  }
}

class RecommendationsData {
  final Meta meta;
  final List<RecommendationModel> recommended;
  final bool hasMore;

  RecommendationsData({
    required this.meta,
    required this.recommended,
    required this.hasMore,
  });

  factory RecommendationsData.fromJson(Map<String, dynamic> json) {
    final meta = Meta.fromJson(json);
    final recommendedList = (json['recommended'] as List<dynamic>?)
            ?.map((item) => RecommendationModel.fromJson(item))
            .toList() ??
        [];
    
    final totalPages = (meta.total / meta.limit).ceil();
    final hasMore = meta.page < totalPages;
    
    return RecommendationsData(
      meta: meta,
      recommended: recommendedList,
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

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'total': total};
  }
}