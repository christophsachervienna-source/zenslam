import 'package:zenslam/app/profile_flow/controller/preferences_service.dart';
import 'package:zenslam/app/notification_flow/model/preference_model.dart';
import 'package:zenslam/app/onboarding_flow/model/time_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SelectTimeController extends GetxController {
  var timeModel = TimeModel().obs;
  var availableTimes = <PreferenceItem>[].obs;
  var isLoading = true.obs;

  // Store initial selections to detect changes
  List<String> _initialSelections = [];

  @override
  void onInit() {
    super.onInit();
    fetchAvailableTimes();
  }

  /// Fetch available times from API
  Future<void> fetchAvailableTimes() async {
    try {
      isLoading.value = true;
      final response = await PreferencesService.getPreferences();

      if (response != null && response.success) {
        availableTimes.value = response.data.times;
        debugPrint('✅ Fetched ${availableTimes.length} times from API');
      } else {
        debugPrint('❌ Failed to fetch times from API');
      }
    } catch (e) {
      debugPrint('❌ Error fetching times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isSelected(String time) {
    return timeModel.value.selectedTimes.contains(time);
  }

  void toggleTime(String time) {
    timeModel.update((model) {
      if (model!.selectedTimes.contains(time)) {
        model.selectedTimes.remove(time);
      } else {
        model.selectedTimes.add(time);
      }
    });
  }

  /// Initialize with existing selections (for editing from preferences)
  void initializeWithSelections(List<String> selections) {
    // Create a new model instance with the selections
    timeModel.value = TimeModel(selectedTimes: Set<String>.from(selections));
    timeModel.refresh(); // Force refresh to ensure Obx detects the change
    _initialSelections = List<String>.from(selections);
  }

  /// Check if selections have changed
  bool hasChanges() {
    final current = timeModel.value.selectedTimes;

    // Check if same length
    if (current.length != _initialSelections.length) {
      return true;
    }

    // Check if all items match
    for (var item in current) {
      if (!_initialSelections.contains(item)) {
        return true;
      }
    }

    return false;
  }

  /// Reset to initial selections (for back button)
  void resetToInitial() {
    timeModel.value = TimeModel(
      selectedTimes: Set<String>.from(_initialSelections),
    );
    timeModel.refresh(); // Force refresh to ensure Obx detects the change
  }
}
