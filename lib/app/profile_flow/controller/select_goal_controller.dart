import 'package:zenslam/app/profile_flow/controller/preferences_service.dart';
import 'package:zenslam/app/onboarding_flow/model/goal_model.dart';
import 'package:zenslam/app/notification_flow/model/preference_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SelectGoalController extends GetxController {
  var goalModel = GoalModel().obs;
  var availableWants = <PreferenceItem>[].obs;
  var isLoading = true.obs;

  // Store initial selections to detect changes
  Map<String, String> _initialSelections = {};

  @override
  void onInit() {
    super.onInit();
    fetchAvailableWants();
  }

  /// Fetch available wants from API
  Future<void> fetchAvailableWants() async {
    try {
      isLoading.value = true;
      final response = await PreferencesService.getPreferences();

      if (response != null && response.success) {
        availableWants.value = response.data.wants;
        debugPrint('✅ Fetched ${availableWants.length} wants from API');

        // Sync selected items with available options to get correct images/emojis
        _syncWithAvailableOptions();
      } else {
        debugPrint('❌ Failed to fetch wants from API');
      }
    } catch (e) {
      debugPrint('❌ Error fetching wants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync selected items with available options to ensure correct images/emojis
  void _syncWithAvailableOptions() {
    if (availableWants.isEmpty) return;

    final currentSelections = Map<String, String>.from(
      goalModel.value.selectedGoals,
    );
    bool hasUpdates = false;

    // Create a map of available wants for quick lookup
    final availableMap = {
      for (var item in availableWants) item.name: item.image,
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
      debugPrint('🔄 Synced goal images with API data');
      goalModel.update((model) {
        model?.selectedGoals.clear();
        model?.selectedGoals.addAll(currentSelections);
      });
    }
  }

  bool isSelected(String goal) {
    return goalModel.value.selectedGoals.containsKey(goal);
  }

  void toggleGoal(String goal, String iconPath) {
    goalModel.update((model) {
      if (model!.selectedGoals.containsKey(goal)) {
        model.selectedGoals.remove(goal);
      } else {
        model.selectedGoals[goal] = iconPath;
      }
    });
  }

  /// Initialize with existing selections (for editing from preferences)
  void initializeWithSelections(Map<String, String> selections) {
    // Create a new model instance with the selections
    goalModel.value = GoalModel(
      selectedGoals: Map<String, String>.from(selections),
    );
    goalModel.refresh(); // Force refresh to ensure Obx detects the change
    _initialSelections = Map<String, String>.from(selections);
  }

  /// Check if selections have changed
  bool hasChanges() {
    final current = goalModel.value.selectedGoals;

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
    goalModel.value = GoalModel(
      selectedGoals: Map<String, String>.from(_initialSelections),
    );
    goalModel.refresh(); // Force refresh to ensure Obx detects the change
  }
}
