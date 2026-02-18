// models/time_model.dart
class TimeModel {
  final Set<String> selectedTimes;

  TimeModel({Set<String>? selectedTimes})
    : selectedTimes = selectedTimes ?? <String>{};

  TimeModel copyWith({Set<String>? selectedTimes}) {
    return TimeModel(selectedTimes: selectedTimes ?? this.selectedTimes);
  }

  Map<String, dynamic> toJson() {
    return {'selectedTimes': selectedTimes.toList()};
  }

  factory TimeModel.fromJson(Map<String, dynamic> json) {
    return TimeModel(
      selectedTimes: Set<String>.from(json['selectedTimes'] ?? []),
    );
  }

  @override
  String toString() {
    return 'TimeModel(selectedTimes: $selectedTimes)';
  }
}
