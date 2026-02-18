class NotificationResponse {
  final bool success;
  final String message;
  final NotificationData data;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class NotificationData {
  final Meta meta;
  final List<NotificationItem> data;

  NotificationData({required this.meta, required this.data});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) =>
                    NotificationItem.fromJson(item['pushNotification'] ?? {}),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((e) => {'pushNotification': e.toJson()}).toList(),
    };
  }
}

class Meta {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  Meta({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalCount': totalCount,
      'totalPages': totalPages,
    };
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String audience;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      audience: json['audience'] ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'audience': audience,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
