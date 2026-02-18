class GoalModel {
  final Map<String, String> selectedGoals; // text -> iconPath

  GoalModel({Map<String, String>? selectedGoals})
    : selectedGoals = selectedGoals ?? <String, String>{};

  GoalModel copyWith({Map<String, String>? selectedGoals}) {
    return GoalModel(selectedGoals: selectedGoals ?? this.selectedGoals);
  }

  Map<String, dynamic> toJson() {
    return {'selectedGoals': selectedGoals};
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      selectedGoals: Map<String, String>.from(json['selectedGoals'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'GoalModel(selectedGoals: $selectedGoals)';
  }
}
