class CategoryResponse {
  final bool success;
  final String message;
  final CategoryData data;

  CategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CategoryData.fromJson(json['data']),
    );
  }
}

class CategoryData {
  final Meta meta;
  final List<Category> data;

  CategoryData({required this.meta, required this.data});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      meta: Meta.fromJson(json['meta']),
      data: List<Category>.from(json['data'].map((x) => Category.fromJson(x))),
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

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'total': total};
  }
}

class Category {
  final String id;
  final String name;
  final bool fontShow;

  Category({required this.id, required this.name, required this.fontShow});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fontShow: json['fontShow'] ?? false,
    );
  }
}
