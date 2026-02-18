class ImportantModel {
  final Map<String, String> selectedImportants; // text -> iconPath

  ImportantModel({Map<String, String>? selectedImportants})
    : selectedImportants = selectedImportants ?? <String, String>{};

  ImportantModel copyWith({Map<String, String>? selectedImportants}) {
    return ImportantModel(
      selectedImportants: selectedImportants ?? this.selectedImportants,
    );
  }

  Map<String, dynamic> toJson() {
    return {'selectedImportants': selectedImportants};
  }

  factory ImportantModel.fromJson(Map<String, dynamic> json) {
    return ImportantModel(
      selectedImportants: Map<String, String>.from(
        json['selectedImportants'] ?? {},
      ),
    );
  }

  @override
  String toString() {
    return 'ImportantModel(selectedImportants: $selectedImportants)';
  }
}
