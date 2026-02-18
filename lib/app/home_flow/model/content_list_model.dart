class ContentListResponse {
  final bool success;
  final String message;
  final ContentListData data;

  ContentListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ContentListResponse.fromJson(Map<String, dynamic> json) {
    return ContentListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ContentListData.fromJson(json['data']),
    );
  }
}

class ContentListData {
  final Meta meta;
  final List<ContentItem> data;

  ContentListData({required this.meta, required this.data});

  factory ContentListData.fromJson(Map<String, dynamic> json) {
    return ContentListData(
      meta: Meta.fromJson(json['meta']),
      data: List<ContentItem>.from(
        json['data'].map((x) => ContentItem.fromJson(x)),
      ),
    );
  }
}

class ContentItem {
  final String id;
  final String categoryName;
  final String type;
  final int serialNo;
  final String title;
  final String description;
  final String content;
  final String author;
  final String thumbnail;
  final String duration;
  final bool isFeature;
  final bool recommended;
  final String createdAt;
  final String updatedAt;

  ContentItem({
    required this.id,
    required this.categoryName,
    required this.type,
    required this.serialNo,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.thumbnail,
    required this.duration,
    required this.isFeature,
    required this.recommended,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      type: json['type'] ?? '',
      serialNo: json['serialNo'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
      isFeature: json['isFeature'] ?? false,
      recommended: json['recommended'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
