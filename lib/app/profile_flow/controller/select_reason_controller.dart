import 'package:zenslam/app/profile_flow/controller/preferences_service.dart';
import 'package:zenslam/app/notification_flow/model/preference_model.dart';
import 'package:zenslam/app/onboarding_flow/model/reason_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SelectReasonController extends GetxController {
  var reasonModel = ReasonModel().obs;
  var availableReasons = <PreferenceItem>[].obs;
  var isLoading = true.obs;

  // Store initial selections to detect changes
  Map<String, String> _initialSelections = {};

  @override
  void onInit() {
    super.onInit();
    fetchAvailableReasons();
  }

  /// Fetch available reasons from API
  Future<void> fetchAvailableReasons() async {
    try {
      isLoading.value = true;
      final response = await PreferencesService.getPreferences();

      if (response != null && response.success) {
        availableReasons.value = response.data.reasons;
        debugPrint('✅ Fetched ${availableReasons.length} reasons from API');

        // Sync selected items with available options to get correct images/emojis
        _syncWithAvailableOptions();
      } else {
        debugPrint('❌ Failed to fetch reasons from API');
        // You can set default/fallback reasons here if needed
      }
    } catch (e) {
      debugPrint('❌ Error fetching reasons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync selected items with available options to ensure correct images/emojis
  void _syncWithAvailableOptions() {
    if (availableReasons.isEmpty) return;

    final currentSelections = Map<String, String>.from(
      reasonModel.value.selectedReasons,
    );
    bool hasUpdates = false;

    // Create a map of available reasons for quick lookup
    final availableMap = {
      for (var item in availableReasons) item.name: item.image,
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
      debugPrint('🔄 Synced reason images with API data');
      reasonModel.update((model) {
        model?.selectedReasons.clear();
        model?.selectedReasons.addAll(currentSelections);
      });
    }
  }

  bool isSelected(String reason) {
    return reasonModel.value.selectedReasons.containsKey(reason);
  }

  void toggleReason(String reason, String iconPath) {
    debugPrint('🔄 toggleReason called: $reason');
    debugPrint('   Before toggle: ${reasonModel.value.selectedReasons}');
    debugPrint('   Initial selections: $_initialSelections');

    reasonModel.update((model) {
      if (model!.selectedReasons.containsKey(reason)) {
        model.selectedReasons.remove(reason);
        debugPrint('   ➖ Removed: $reason');
      } else {
        model.selectedReasons[reason] = iconPath;
        debugPrint('   ➕ Added: $reason');
      }
    });

    debugPrint('   After toggle: ${reasonModel.value.selectedReasons}');
    debugPrint('   Initial selections after toggle: $_initialSelections');
  }

  /// Initialize with existing selections (for editing from preferences)
  void initializeWithSelections(Map<String, String> selections) {
    debugPrint('🔧 SelectReasonController.initializeWithSelections called');
    debugPrint('   Selections to initialize: $selections');
    // Create a new model instance with the selections
    reasonModel.value = ReasonModel(
      selectedReasons: Map<String, String>.from(selections),
    );
    reasonModel.refresh(); // Force refresh to ensure Obx detects the change
    _initialSelections = Map<String, String>.from(selections);
    debugPrint(
      '   ✅ Initialized with ${reasonModel.value.selectedReasons.length} selections',
    );
    debugPrint('   Current selections: ${reasonModel.value.selectedReasons}');
  }

  /// Check if selections have changed
  bool hasChanges() {
    debugPrint('\n🔍 hasChanges() called');
    final current = reasonModel.value.selectedReasons;
    debugPrint('   Current selections: $current');
    debugPrint('   Initial selections: $_initialSelections');

    // Check if same keys
    if (current.keys.length != _initialSelections.keys.length) {
      debugPrint(
        '   ✅ HAS CHANGES: Different length (current: ${current.keys.length}, initial: ${_initialSelections.keys.length})',
      );
      return true;
    }

    // Check if all keys match
    for (var key in current.keys) {
      if (!_initialSelections.containsKey(key)) {
        debugPrint('   ✅ HAS CHANGES: Key "$key" not in initial selections');
        return true;
      }
    }

    debugPrint('   ❌ NO CHANGES: Selections are identical');
    return false;
  }

  /// Reset to initial selections (for back button)
  void resetToInitial() {
    reasonModel.value = ReasonModel(
      selectedReasons: Map<String, String>.from(_initialSelections),
    );
    reasonModel.refresh(); // Force refresh to ensure Obx detects the change
  }
}
