class ExploreModel {
  final bool success;
  final String message;
  final ExploreData data;

  ExploreModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExploreModel.fromJson(Map<String, dynamic> json) {
    return ExploreModel(
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
  final List<ExploreCategory> data;

  ExploreData({required this.meta, required this.data});

  factory ExploreData.fromJson(Map<String, dynamic> json) {
    return ExploreData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ExploreCategory.fromJson(item))
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

class Meta {
  final int total;
  final int page;
  final int limit;

  Meta({required this.total, required this.page, required this.limit});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'page': page, 'limit': limit};
  }
}

class ExploreCategory {
  final String id;
  final String name;

  ExploreCategory({required this.id, required this.name});

  factory ExploreCategory.fromJson(Map<String, dynamic> json) {
    return ExploreCategory(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'ExploreCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExploreCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
