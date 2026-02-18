// models/preference_summary_model.dart
import 'package:zenslam/app/onboarding_flow/model/goal_model.dart';
import 'package:zenslam/app/notification_flow/model/important_model.dart';
import 'package:zenslam/app/onboarding_flow/model/reason_model.dart';
import 'package:zenslam/app/onboarding_flow/model/time_model.dart';

class PreferenceModel {
  final ReasonModel reasonModel;
  final TimeModel timeModel;
  final GoalModel goalModel;
  final ImportantModel importantModel;

  PreferenceModel({
    required this.reasonModel,
    required this.timeModel,
    required this.goalModel,
    required this.importantModel,
  });

  PreferenceModel copyWith({
    ReasonModel? reasonModel,
    TimeModel? timeModel,
    GoalModel? goalModel,
    ImportantModel? importantModel,
  }) {
    return PreferenceModel(
      reasonModel: reasonModel ?? this.reasonModel,
      timeModel: timeModel ?? this.timeModel,
      goalModel: goalModel ?? this.goalModel,
      importantModel: importantModel ?? this.importantModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reasonModel': reasonModel.toJson(),
      'timeModel': timeModel.toJson(),
      'goalModel': goalModel.toJson(),
      'importantModel': importantModel.toJson(),
    };
  }

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      reasonModel: ReasonModel.fromJson(json['reasonModel'] ?? {}),
      timeModel: TimeModel.fromJson(json['timeModel'] ?? {}),
      goalModel: GoalModel.fromJson(json['goalModel'] ?? {}),
      importantModel: ImportantModel.fromJson(json['importantModel'] ?? {}),
    );
  }

  // Helper methods to get display data for preference screen
  Map<String, String> getSelectedReasons() => reasonModel.selectedReasons;
  Map<String, String> getSelectedGoals() => goalModel.selectedGoals;
  Map<String, String> getSelectedImportants() =>
      importantModel.selectedImportants;
  List<String> getSelectedTimes() => timeModel.selectedTimes.toList();

  @override
  String toString() {
    return 'PreferenceModel(\n'
        '  Reasons: ${reasonModel.selectedReasons},\n'
        '  Times: ${timeModel.selectedTimes},\n'
        '  Goals: ${goalModel.selectedGoals},\n'
        '  Importants: ${importantModel.selectedImportants}\n'
        ')';
  }
}
