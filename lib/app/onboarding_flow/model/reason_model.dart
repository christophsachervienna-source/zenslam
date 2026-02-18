class ReasonModel {
  final Map<String, String> selectedReasons; // text -> iconPath

  ReasonModel({Map<String, String>? selectedReasons})
    : selectedReasons = selectedReasons ?? <String, String>{};

  ReasonModel copyWith({Map<String, String>? selectedReasons}) {
    return ReasonModel(
      selectedReasons: selectedReasons ?? this.selectedReasons,
    );
  }

  Map<String, dynamic> toJson() {
    return {'selectedReasons': selectedReasons};
  }

  factory ReasonModel.fromJson(Map<String, dynamic> json) {
    return ReasonModel(
      selectedReasons: Map<String, String>.from(json['selectedReasons'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'ReasonModel(selectedReasons: $selectedReasons)';
  }
}
