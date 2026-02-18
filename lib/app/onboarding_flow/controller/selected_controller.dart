import 'package:zenslam/app/profile_flow/controller/preferences_service.dart';
import 'package:zenslam/app/notification_flow/model/important_model.dart';
import 'package:zenslam/app/notification_flow/model/preference_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SelectedController extends GetxController {
  var importantModel = ImportantModel().obs;
  var availableMatters = <PreferenceItem>[].obs;
  var isLoading = true.obs;

  // Store initial selections to detect changes
  Map<String, String> _initialSelections = {};

  @override
  void onInit() {
    super.onInit();
    fetchAvailableMatters();
  }

  /// Fetch available matters from API
  Future<void> fetchAvailableMatters() async {
    try {
      isLoading.value = true;
      final response = await PreferencesService.getPreferences();

      if (response != null && response.success) {
        availableMatters.value = response.data.matters;
        debugPrint('✅ Fetched ${availableMatters.length} matters from API');

        // Sync selected items with available options to get correct images/emojis
        _syncWithAvailableOptions();
      } else {
        debugPrint('❌ Failed to fetch matters from API');
      }
    } catch (e) {
      debugPrint('❌ Error fetching matters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync selected items with available options to ensure correct images/emojis
  void _syncWithAvailableOptions() {
    if (availableMatters.isEmpty) return;

    final currentSelections = Map<String, String>.from(
      importantModel.value.selectedImportants,
    );
    bool hasUpdates = false;

    // Create a map of available matters for quick lookup
    final availableMap = {
      for (var item in availableMatters) item.name: item.image,
    };

    // Update selected items with images/emojis from API
    for (var key in currentSelections.keys) {
      if (availableMap.containsKey(key)) {
        final apiImage = availableMap[key];
        if (currentSelections[key] != apiImage) {
          currentSelections[key] = apiImage!;
          hasUpdates = true;
        }
      }
    }

    if (hasUpdates) {
      debugPrint('🔄 Synced important images with API data');
      importantModel.update((model) {
        model?.selectedImportants.clear();
        model?.selectedImportants.addAll(currentSelections);
      });
    }
  }

  bool isSelected(String important) {
    return importantModel.value.selectedImportants.containsKey(important);
  }

  void toggleImportant(String important, String iconPath) {
    importantModel.update((model) {
      if (model!.selectedImportants.containsKey(important)) {
        model.selectedImportants.remove(important);
      } else {
        model.selectedImportants[important] = iconPath;
      }
    });
  }

  /// Initialize with existing selections (for editing from preferences)
  void initializeWithSelections(Map<String, String> selections) {
    // Create a new model instance with the selections
    importantModel.value = ImportantModel(
      selectedImportants: Map<String, String>.from(selections),
    );
    importantModel.refresh(); // Force refresh to ensure Obx detects the change
    _initialSelections = Map<String, String>.from(selections);
  }

  /// Check if selections have changed
  bool hasChanges() {
    final current = importantModel.value.selectedImportants;

    // Check if same keys
    if (current.keys.length != _initialSelections.keys.length) {
      return true;
    }

    // Check if all keys match
    for (var key in current.keys) {
      if (!_initialSelections.containsKey(key)) {
        return true;
      }
    }

    return false;
  }

  /// Reset to initial selections (for back button)
  void resetToInitial() {
    importantModel.value = ImportantModel(
      selectedImportants: Map<String, String>.from(_initialSelections),
    );
    importantModel.refresh(); // Force refresh to ensure Obx detects the change
  }
}
