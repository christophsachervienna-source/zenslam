class CategoryDisplayResponse {
  final bool success;
  final String message;
  final CategoryDisplayData data;

  CategoryDisplayResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryDisplayResponse.fromJson(Map<String, dynamic> json) {
    return CategoryDisplayResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CategoryDisplayData.fromJson(json['data']),
    );
  }
}

class CategoryDisplayData {
  final List<CategoryWithContents> categories;

  CategoryDisplayData({required this.categories});

  factory CategoryDisplayData.fromJson(Map<String, dynamic> json) {
    return CategoryDisplayData(
      categories: List<CategoryWithContents>.from(
        json['categories'].map((x) => CategoryWithContents.fromJson(x)),
      ),
    );
  }
}

class CategoryWithContents {
  final String name;
  final List<Content> contents;

  CategoryWithContents({required this.name, required this.contents});

  factory CategoryWithContents.fromJson(Map<String, dynamic> json) {
    return CategoryWithContents(
      name: json['name'] ?? '',
      contents: List<Content>.from(
        (json['contents'] ?? []).map((x) => Content.fromJson(x)),
      ),
    );
  }
}

class Content {
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

  Content({
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
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
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
    );
  }
}
