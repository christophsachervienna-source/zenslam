class PreferencesData {
  final String id;
  final List<PreferenceItem> reasons;
  final List<PreferenceItem> times;
  final List<PreferenceItem> matters;
  final List<PreferenceItem> wants;
  final DateTime createdAt;
  final DateTime updatedAt;

  PreferencesData({
    required this.id,
    required this.reasons,
    required this.times,
    required this.matters,
    required this.wants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PreferencesData.fromJson(Map<String, dynamic> json) {
    return PreferencesData(
      id: json['id'] ?? '',
      reasons: (json['reasons'] as List?)
          ?.map((item) => PreferenceItem.fromJson(item))
          .toList() ?? [],
      times: (json['times'] as List?)
          ?.map((item) => PreferenceItem.fromJson(item))
          .toList() ?? [],
      matters: (json['matters'] as List?)
          ?.map((item) => PreferenceItem.fromJson(item))
          .toList() ?? [],
      wants: (json['wants'] as List?)
          ?.map((item) => PreferenceItem.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reasons': reasons.map((item) => item.toJson()).toList(),
      'times': times.map((item) => item.toJson()).toList(),
      'matters': matters.map((item) => item.toJson()).toList(),
      'wants': wants.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PreferencesResponse {
  final bool success;
  final String message;
  final PreferencesData data;

  PreferencesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PreferencesResponse.fromJson(Map<String, dynamic> json) {
    return PreferencesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PreferencesData.fromJson(json['data'] ?? {}),
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

class PreferenceItem {
  final String name;
  final String image;

  PreferenceItem({
    required this.name,
    required this.image,
  });

  factory PreferenceItem.fromJson(Map<String, dynamic> json) {
    return PreferenceItem(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }

  @override
  String toString() {
    return 'PreferenceItem(name: $name, image: $image)';
  }
}