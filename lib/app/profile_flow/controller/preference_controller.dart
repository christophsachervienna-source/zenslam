import 'dart:convert';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/profile_flow/controller/preferences_service.dart';
import 'package:zenslam/app/profile_flow/controller/select_goal_controller.dart';
import 'package:zenslam/app/profile_flow/controller/select_reason_controller.dart';
import 'package:zenslam/app/onboarding_flow/controller/select_time_controller.dart';
import 'package:zenslam/app/onboarding_flow/controller/selected_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PreferenceController extends GetxController {
  // Titles
  var reasonTitle = "What's your main reason for being here?".obs;
  var importantTitle = "What's most important to you right now?".obs;
  var timeTitle = "How much time can you give to practice?".obs;
  var goalTitle = "What are your top goals?".obs;

  // Reactive variables
  var selectedReasons = <String, String>{}.obs;
  var selectedImportants = <String, String>{}.obs;
  var selectedTimes = <String, String>{}.obs;
  var selectedGoals = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('\n========== PREFERENCE CONTROLLER INIT ==========');
    debugPrint(
      '🔄 Loading preferences from controllers and SharedPreferences...',
    );
    // Clean up old mixed data in SharedPreferences first, then load
    _initializePreferences();
  }

  /// Initialize preferences with cleanup and loading
  Future<void> _initializePreferences() async {
    // Clean up old mixed data in SharedPreferences first
    await _cleanupMixedPreferencesData();
    // Load from SharedPreferences first (as fallback)
    await _loadPreferencesFromSharedPreferences();
    // Fetch from API and sync emojis
    await _fetchAndSyncPreferences();
    // Then update from controllers (which have priority if they have data)
    updatePreferences();
  }

  /// Fetch preferences from API and sync emojis
  Future<void> _fetchAndSyncPreferences() async {
    try {
      debugPrint('🔄 Fetching preferences from API to sync emojis...');
      final response = await PreferencesService.getPreferences();

      if (response != null && response.success) {
        // Create lookup maps for emojis
        final reasonMap = {
          for (var item in response.data.reasons) item.name: item.image,
        };
        final importantMap = {
          for (var item in response.data.matters) item.name: item.image,
        };
        final timeMap = {
          for (var item in response.data.times) item.name: item.image,
        };
        final goalMap = {
          for (var item in response.data.wants) item.name: item.image,
        };

        // Sync selected reasons
        final updatedReasons = <String, String>{};
        for (var key in selectedReasons.keys) {
          if (reasonMap.containsKey(key)) {
            updatedReasons[key] = reasonMap[key]!;
          } else {
            updatedReasons[key] = selectedReasons[key]!;
          }
        }
        selectedReasons.value = updatedReasons;

        // Sync selected importants
        final updatedImportants = <String, String>{};
        for (var key in selectedImportants.keys) {
          if (importantMap.containsKey(key)) {
            updatedImportants[key] = importantMap[key]!;
          } else {
            updatedImportants[key] = selectedImportants[key]!;
          }
        }
        selectedImportants.value = updatedImportants;

        // Sync selected times
        final updatedTimes = <String, String>{};
        for (var key in selectedTimes.keys) {
          if (timeMap.containsKey(key)) {
            updatedTimes[key] = timeMap[key]!;
          } else {
            updatedTimes[key] = selectedTimes[key]!;
          }
        }
        selectedTimes.value = updatedTimes;

        // Sync selected goals
        final updatedGoals = <String, String>{};
        for (var key in selectedGoals.keys) {
          if (goalMap.containsKey(key)) {
            updatedGoals[key] = goalMap[key]!;
          } else {
            updatedGoals[key] = selectedGoals[key]!;
          }
        }
        selectedGoals.value = updatedGoals;

        debugPrint('✅ Synced all preferences with API emojis');
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching preferences for sync: $e');
    }
  }

  void updatePreferences() {
    // Only update each specific section, don't recreate all
    // This preserves the other selections
    selectedReasons.value = _getSelectedReasons();
    selectedImportants.value = _getSelectedImportants();
    selectedTimes.value = _getSelectedTimes();
    selectedGoals.value = _getSelectedGoals();
  }

  /// Clean up old mixed data in SharedPreferences (convert icon paths to names)
  Future<void> _cleanupMixedPreferencesData() async {
    try {
      debugPrint('🧹 Cleaning up mixed preferences data...');

      // Clean up reason preferences
      final reasonJson = await SharedPrefHelper.getReasonHere();
      if (reasonJson != null && reasonJson.isNotEmpty) {
        try {
          final reasons = jsonDecode(reasonJson) as List;
          bool hasIconPaths = false;
          final convertedReasons = reasons.map((item) {
            final itemStr = item.toString();
            if (itemStr.contains('assets/icons/')) {
              hasIconPaths = true;
              return _getReasonNameFromIconPath(itemStr);
            }
            return itemStr;
          }).toList();
          // Save if there were icon paths to convert
          if (hasIconPaths) {
            await SharedPrefHelper.saveReasonHere(jsonEncode(convertedReasons));
            debugPrint('✅ Cleaned up reasonHere');
          }
        } catch (e) {
          debugPrint('⚠️ Error cleaning reasonHere: $e');
        }
      }

      // Clean up important preferences
      final importantJson = await SharedPrefHelper.getMostImportant();
      if (importantJson != null && importantJson.isNotEmpty) {
        try {
          final importants = jsonDecode(importantJson) as List;
          bool hasIconPaths = false;
          final convertedImportants = importants.map((item) {
            final itemStr = item.toString();
            if (itemStr.contains('assets/icons/')) {
              hasIconPaths = true;
              return _getImportantNameFromIconPath(itemStr);
            }
            return itemStr;
          }).toList();
          // Save if there were icon paths to convert
          if (hasIconPaths) {
            await SharedPrefHelper.saveMostImportant(
              jsonEncode(convertedImportants),
            );
            debugPrint('✅ Cleaned up mostImportant');
          }
        } catch (e) {
          debugPrint('⚠️ Error cleaning mostImportant: $e');
        }
      }

      // Clean up goal preferences
      final goalsJson = await SharedPrefHelper.getTopGoals();
      if (goalsJson != null && goalsJson.isNotEmpty) {
        try {
          final goals = jsonDecode(goalsJson) as List;
          bool hasIconPaths = false;
          final convertedGoals = goals.map((item) {
            final itemStr = item.toString();
            if (itemStr.contains('assets/icons/')) {
              hasIconPaths = true;
              return _getGoalNameFromIconPath(itemStr);
            }
            return itemStr;
          }).toList();
          // Save if there were icon paths to convert
          if (hasIconPaths) {
            await SharedPrefHelper.saveTopGoals(jsonEncode(convertedGoals));
            debugPrint('✅ Cleaned up topGoals');
          }
        } catch (e) {
          debugPrint('⚠️ Error cleaning topGoals: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in cleanup: $e');
    }
  }

  /// Load preferences from SharedPreferences (offline fallback)
  Future<void> _loadPreferencesFromSharedPreferences() async {
    try {
      debugPrint(
        '\n========== LOADING PREFERENCES FROM SHARED PREFS ==========',
      );

      // Load reason here
      final reasonJson = await SharedPrefHelper.getReasonHere();
      if (reasonJson != null && reasonJson.isNotEmpty) {
        try {
          final reasons = jsonDecode(reasonJson) as List;
          debugPrint('✅ Loaded reasonHere from SharedPreferences: $reasons');
          // Convert icon paths to reason names and populate the map
          final reasonMap = <String, String>{};
          final convertedReasons = <dynamic>[];
          for (var reason in reasons) {
            final reasonStr = reason.toString();
            // Check if it's an icon path (old format) or a reason name (new format)
            final reasonName = reasonStr.contains('assets/icons/')
                ? _getReasonNameFromIconPath(reasonStr)
                : reasonStr;
            final iconPath = _getReasonIconPath(reasonName);
            reasonMap[reasonName] = iconPath;
            convertedReasons.add(reasonName); // Store converted name
          }
          selectedReasons.value = reasonMap;
          // Also populate the SelectReasonController if it exists with converted names
          _populateReasonController(convertedReasons);
        } catch (e) {
          debugPrint('⚠️ Error parsing reasonHere: $e');
        }
      }

      // Load most important
      final importantJson = await SharedPrefHelper.getMostImportant();
      if (importantJson != null && importantJson.isNotEmpty) {
        try {
          final importants = jsonDecode(importantJson) as List;
          debugPrint(
            '✅ Loaded mostImportant from SharedPreferences: $importants',
          );
          // Convert icon paths to important names and populate the map
          final importantMap = <String, String>{};
          final convertedImportants = <dynamic>[];
          for (var important in importants) {
            final importantStr = important.toString();
            // Check if it's an icon path (old format) or an important name (new format)
            final importantName = importantStr.contains('assets/icons/')
                ? _getImportantNameFromIconPath(importantStr)
                : importantStr;
            final iconPath = _getImportantIconPath(importantName);
            importantMap[importantName] = iconPath;
            convertedImportants.add(importantName); // Store converted name
          }
          selectedImportants.value = importantMap;
          // Also populate the SelectedController if it exists with converted names
          _populateImportantController(convertedImportants);
        } catch (e) {
          debugPrint('⚠️ Error parsing mostImportant: $e');
        }
      }

      // Load practice commit
      final commitJson = await SharedPrefHelper.getPracticeCommit();
      if (commitJson != null && commitJson.isNotEmpty) {
        try {
          final commit = jsonDecode(commitJson) as List;
          debugPrint('✅ Loaded practiceCommit from SharedPreferences: $commit');
          // Convert to Map<String, String> format
          final timeMap = <String, String>{};
          for (var time in commit) {
            final timeStr = time.toString();
            // For now, use empty string as placeholder for emoji/image
            // This will be synced with API data later
            timeMap[timeStr] = '';
          }
          selectedTimes.value = timeMap;
          // Also populate the SelectTimeController with saved preferences
          _populateTimeController(commit);
        } catch (e) {
          debugPrint('⚠️ Error parsing practiceCommit: $e');
        }
      }

      // Load top goals
      final goalsJson = await SharedPrefHelper.getTopGoals();
      if (goalsJson != null && goalsJson.isNotEmpty) {
        try {
          final goals = jsonDecode(goalsJson) as List;
          debugPrint('✅ Loaded topGoals from SharedPreferences: $goals');
          // Convert icon paths to goal names and populate the map
          final goalMap = <String, String>{};
          final convertedGoals = <dynamic>[];
          for (var goal in goals) {
            final goalStr = goal.toString();
            // Check if it's an icon path (old format) or a goal name (new format)
            final goalName = goalStr.contains('assets/icons/')
                ? _getGoalNameFromIconPath(goalStr)
                : goalStr;
            final iconPath = _getGoalIconPath(goalName);
            goalMap[goalName] = iconPath;
            convertedGoals.add(goalName); // Store converted name
          }
          selectedGoals.value = goalMap;
          // Also populate the SelectGoalController if it exists with converted names
          _populateGoalController(convertedGoals);
        } catch (e) {
          debugPrint('⚠️ Error parsing topGoals: $e');
        }
      }

      debugPrint('=====================================================\n');
    } catch (e, stackTrace) {
      debugPrint('💥 Error loading preferences from SharedPreferences: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
    }
  }

  /// Populate SelectReasonController with saved preferences
  void _populateReasonController(List<dynamic> reasons) {
    try {
      if (Get.isRegistered<SelectReasonController>()) {
        final reasonController = Get.find<SelectReasonController>();
        reasonController.reasonModel.update((model) {
          model?.selectedReasons.clear();
          for (var reason in reasons) {
            final reasonStr = reason.toString();
            // Check if it's an icon path (old format) or a reason name (new format)
            final reasonName = reasonStr.contains('assets/icons/')
                ? _getReasonNameFromIconPath(reasonStr)
                : reasonStr;
            final iconPath = _getReasonIconPath(reasonName);
            model?.selectedReasons[reasonName] = iconPath;
          }
        });
        debugPrint(
          '✅ Populated SelectReasonController with ${reasons.length} reasons',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not populate SelectReasonController: $e');
    }
  }

  /// Populate SelectedController with saved preferences
  void _populateImportantController(List<dynamic> importants) {
    try {
      if (Get.isRegistered<SelectedController>()) {
        final importantController = Get.find<SelectedController>();
        importantController.importantModel.update((model) {
          model?.selectedImportants.clear();
          for (var important in importants) {
            final importantStr = important.toString();
            // Check if it's an icon path (old format) or an important name (new format)
            final importantName = importantStr.contains('assets/icons/')
                ? _getImportantNameFromIconPath(importantStr)
                : importantStr;
            final iconPath = _getImportantIconPath(importantName);
            model?.selectedImportants[importantName] = iconPath;
          }
        });
        debugPrint(
          '✅ Populated SelectedController with ${importants.length} importants',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not populate SelectedController: $e');
    }
  }

  /// Populate SelectTimeController with saved preferences
  void _populateTimeController(List<dynamic> times) {
    try {
      if (Get.isRegistered<SelectTimeController>()) {
        final timeController = Get.find<SelectTimeController>();
        timeController.timeModel.update((model) {
          model?.selectedTimes.clear();
          for (var time in times) {
            model?.selectedTimes.add(time.toString());
          }
        });
        debugPrint(
          '✅ Populated SelectTimeController with ${times.length} times',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not populate SelectTimeController: $e');
    }
  }

  /// Populate SelectGoalController with saved preferences
  void _populateGoalController(List<dynamic> goals) {
    try {
      if (Get.isRegistered<SelectGoalController>()) {
        final goalController = Get.find<SelectGoalController>();
        goalController.goalModel.update((model) {
          model?.selectedGoals.clear();
          for (var goal in goals) {
            final goalStr = goal.toString();
            // Check if it's an icon path (old format) or a goal name (new format)
            final goalName = goalStr.contains('assets/icons/')
                ? _getGoalNameFromIconPath(goalStr)
                : goalStr;
            final iconPath = _getGoalIconPath(goalName);
            model?.selectedGoals[goalName] = iconPath;
          }
        });
        debugPrint(
          '✅ Populated SelectGoalController with ${goals.length} goals',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not populate SelectGoalController: $e');
    }
  }

  // Update specific preference only
  void updateSpecificPreference(String type) {
    switch (type) {
      case 'reason':
        selectedReasons.value = _getSelectedReasons();
        break;
      case 'important':
        selectedImportants.value = _getSelectedImportants();
        break;
      case 'time':
        selectedTimes.value = _getSelectedTimes();
        break;
      case 'goal':
        selectedGoals.value = _getSelectedGoals();
        break;
    }
  }

  Map<String, String> _getSelectedReasons() {
    try {
      final controller = Get.find<SelectReasonController>();
      final rawReasons = controller.reasonModel.value.selectedReasons;

      // Convert icon paths to reason names if needed
      final convertedReasons = <String, String>{};
      for (var entry in rawReasons.entries) {
        final key = entry.key;
        final value = entry.value;

        // If key is an icon path, convert it to reason name
        final reasonName = key.contains('assets/icons/')
            ? _getReasonNameFromIconPath(key)
            : key;

        convertedReasons[reasonName] = value;
      }

      return convertedReasons;
    } catch (e) {
      return Map<String, String>.from(
        selectedReasons,
      ); // Return current value if error
    }
  }

  Map<String, String> _getSelectedImportants() {
    try {
      final controller = Get.find<SelectedController>();
      final rawImportants = controller.importantModel.value.selectedImportants;

      // Convert icon paths to important names if needed
      final convertedImportants = <String, String>{};
      for (var entry in rawImportants.entries) {
        final key = entry.key;
        final value = entry.value;

        // If key is an icon path, convert it to important name
        final importantName = key.contains('assets/icons/')
            ? _getImportantNameFromIconPath(key)
            : key;

        convertedImportants[importantName] = value;
      }

      return convertedImportants;
    } catch (e) {
      return Map<String, String>.from(selectedImportants);
    }
  }

  Map<String, String> _getSelectedTimes() {
    try {
      final controller = Get.find<SelectTimeController>();
      // Convert List/Set from controller to Map
      final timeMap = <String, String>{};
      for (var time in controller.timeModel.value.selectedTimes) {
        // Use existing emoji/image if available, otherwise empty string
        timeMap[time] = selectedTimes[time] ?? '';
      }
      return timeMap;
    } catch (e) {
      return Map<String, String>.from(selectedTimes);
    }
  }

  Map<String, String> _getSelectedGoals() {
    try {
      final controller = Get.find<SelectGoalController>();
      final rawGoals = controller.goalModel.value.selectedGoals;

      // Convert icon paths to goal names if needed
      final convertedGoals = <String, String>{};
      for (var entry in rawGoals.entries) {
        final key = entry.key;
        final value = entry.value;

        // If key is an icon path, convert it to goal name
        final goalName = key.contains('assets/icons/')
            ? _getGoalNameFromIconPath(key)
            : key;

        convertedGoals[goalName] = value;
      }

      return convertedGoals;
    } catch (e) {
      return Map<String, String>.from(selectedGoals);
    }
  }

  /// Prepare reason edit by initializing controller with existing selections
  Future<void> prepareReasonEdit() async {
    try {
      debugPrint('\n🔧 prepareReasonEdit() called');
      debugPrint('   Current selectedReasons: $selectedReasons');
      debugPrint('   Type: ${selectedReasons.runtimeType}');
      debugPrint('   Length: ${selectedReasons.length}');

      // Delete existing controller if it exists
      if (Get.isRegistered<SelectReasonController>()) {
        debugPrint('   Deleting existing SelectReasonController');
        Get.delete<SelectReasonController>();
      }

      // Create new controller and initialize with existing selections
      debugPrint('   Creating new SelectReasonController');
      final controller = Get.put(SelectReasonController());

      debugPrint('   Calling initializeWithSelections...');
      controller.initializeWithSelections(
        Map<String, String>.from(selectedReasons),
      );

      debugPrint(
        '✅ Initialized reason controller with ${selectedReasons.length} selections',
      );
    } catch (e) {
      debugPrint('⚠️ Could not initialize SelectReasonController: $e');
    }
  }

  /// Check if reason selections have changed
  Future<bool> checkReasonChanges() async {
    try {
      debugPrint('\n🔍 checkReasonChanges() called in PreferenceController');
      final controller = Get.find<SelectReasonController>();
      final hasChanges = controller.hasChanges();
      debugPrint('   Result: $hasChanges');
      return hasChanges;
    } catch (e) {
      debugPrint('⚠️ Could not check reason changes: $e');
      return false;
    }
  }

  /// Prepare important edit by initializing controller with existing selections
  Future<void> prepareImportantEdit() async {
    try {
      // Delete existing controller if it exists
      if (Get.isRegistered<SelectedController>()) {
        Get.delete<SelectedController>();
      }
      // Create new controller and initialize with existing selections
      final controller = Get.put(SelectedController());
      controller.initializeWithSelections(
        Map<String, String>.from(selectedImportants),
      );
      debugPrint(
        '✅ Initialized important controller with ${selectedImportants.length} selections',
      );
    } catch (e) {
      debugPrint('⚠️ Could not initialize SelectedController: $e');
    }
  }

  /// Check if important selections have changed
  Future<bool> checkImportantChanges() async {
    try {
      final controller = Get.find<SelectedController>();
      return controller.hasChanges();
    } catch (e) {
      debugPrint('⚠️ Could not check important changes: $e');
      return false;
    }
  }

  /// Prepare time edit by initializing controller with existing selections
  Future<void> prepareTimeEdit() async {
    try {
      // Delete existing controller if it exists
      if (Get.isRegistered<SelectTimeController>()) {
        Get.delete<SelectTimeController>();
      }
      // Create new controller and initialize with existing selections
      final controller = Get.put(SelectTimeController());
      // Convert Map keys to List for the controller
      controller.initializeWithSelections(selectedTimes.keys.toList());
      debugPrint(
        '✅ Initialized time controller with ${selectedTimes.length} selections',
      );
    } catch (e) {
      debugPrint('⚠️ Could not initialize SelectTimeController: $e');
    }
  }

  /// Check if time selections have changed
  Future<bool> checkTimeChanges() async {
    try {
      final controller = Get.find<SelectTimeController>();
      return controller.hasChanges();
    } catch (e) {
      debugPrint('⚠️ Could not check time changes: $e');
      return false;
    }
  }

  /// Prepare goal edit by initializing controller with existing selections
  Future<void> prepareGoalEdit() async {
    try {
      // Delete existing controller if it exists
      if (Get.isRegistered<SelectGoalController>()) {
        Get.delete<SelectGoalController>();
      }
      // Create new controller and initialize with existing selections
      final controller = Get.put(SelectGoalController());
      controller.initializeWithSelections(
        Map<String, String>.from(selectedGoals),
      );
      debugPrint(
        '✅ Initialized goal controller with ${selectedGoals.length} selections',
      );
    } catch (e) {
      debugPrint('⚠️ Could not initialize SelectGoalController: $e');
    }
  }

  /// Check if goal selections have changed
  Future<bool> checkGoalChanges() async {
    try {
      final controller = Get.find<SelectGoalController>();
      return controller.hasChanges();
    } catch (e) {
      debugPrint('⚠️ Could not check goal changes: $e');
      return false;
    }
  }

  /// Update specific preference via API and refresh local data
  Future<bool> updatePreferenceAndSync(String type) async {
    try {
      debugPrint('\n\n🔴🔴🔴 UPDATE PREFERENCE SYNC STARTED 🔴🔴🔴');
      debugPrint('📝 Preference Type: $type');

      // ALWAYS refresh the preference from the individual controller
      // This ensures we capture the latest selections from the select screens
      // even if data was previously loaded from SharedPreferences
      updateSpecificPreference(type);

      debugPrint('🔄 Refreshed preference from controller');

      // Get the profile controller to call the API
      final profileController = Get.find<ProfileController>();

      // Prepare data based on type
      Map<String, dynamic> preferenceData = {};

      switch (type) {
        case 'reason':
          // Convert icon paths to reason names
          final reasonNames = selectedReasons.keys.map((key) {
            return key.contains('assets/icons/')
                ? _getReasonNameFromIconPath(key)
                : key;
          }).toList();
          preferenceData['reasons'] = reasonNames;
          debugPrint('📤 Selected Reasons: $reasonNames');
          break;
        case 'important':
          // Convert icon paths to important names
          final importantNames = selectedImportants.keys.map((key) {
            return key.contains('assets/icons/')
                ? _getImportantNameFromIconPath(key)
                : key;
          }).toList();
          preferenceData['important'] = importantNames;
          debugPrint('📤 Selected Important: $importantNames');
          break;
        case 'time':
          // Send only the time names (keys) to the API
          preferenceData['time'] = selectedTimes.keys.toList();
          debugPrint('📤 Selected Times: ${selectedTimes.keys.toList()}');
          break;
        case 'goal':
          // Convert icon paths to goal names
          final goalNames = selectedGoals.keys.map((key) {
            return key.contains('assets/icons/')
                ? _getGoalNameFromIconPath(key)
                : key;
          }).toList();
          preferenceData['goals'] = goalNames;
          debugPrint('📤 Selected Goals: $goalNames');
          break;
        default:
          debugPrint('❌ Unknown preference type: $type');
          return false;
      }

      debugPrint('📤 Sending preference data: $preferenceData');

      // Call the API through ProfileController
      final success = await profileController.updatePreferenceViaApi(
        preferenceType: type,
        preferenceData: preferenceData,
      );

      if (success) {
        debugPrint('✅ Preference $type updated successfully on API');
        debugPrint('✅ Preference $type saved to SharedPreferences');

        debugPrint(
          '🟢🟢🟢 UPDATE PREFERENCE SYNC COMPLETED SUCCESSFULLY 🟢🟢🟢\n\n',
        );
        return true;
      } else {
        debugPrint('❌ Failed to update preference $type');
        debugPrint('🔴🔴🔴 UPDATE PREFERENCE SYNC FAILED 🔴🔴🔴\n\n');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error updating preference: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
      debugPrint(
        '🔴🔴🔴 UPDATE PREFERENCE SYNC FAILED WITH EXCEPTION 🔴🔴🔴\n\n',
      );
      return false;
    }
  }

  /// Map reason names to their icon paths
  String _getReasonIconPath(String reasonName) {
    switch (reasonName) {
      case "Sleep & Rest":
        return IconsPath.sleepicon;
      case "Stress & Calm":
        return IconsPath.stress;
      case "Build Confidence":
        return IconsPath.build;
      case "Focus & Discipline":
        return IconsPath.focusicon;
      case "Fatherhood & Family":
        return IconsPath.fatherhgood;
      case "Purpose & Mission":
        return IconsPath.discover;
      case "Anger & Emotional Strength":
        return IconsPath.angreicon;
      case "Brotherhood & Connection":
        return IconsPath.brotherhood;
      default:
        return IconsPath.sleepicon; // Default fallback
    }
  }

  /// Map icon paths back to reason names (for backward compatibility with old saved data)
  String _getReasonNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/sleepicon.png":
        return "Sleep & Rest";
      case "assets/icons/stress.png":
        return "Stress & Calm";
      case "assets/icons/build.png":
        return "Build Confidence";
      case "assets/icons/focusicon.png":
        return "Focus & Discipline";
      case "assets/icons/fatherhgood.png":
        return "Fatherhood & Family";
      case "assets/icons/discover.png":
        return "Purpose & Mission";
      case "assets/icons/angreicon.png":
        return "Anger & Emotional Strength";
      case "assets/icons/brotherhood.png":
        return "Brotherhood & Connection";
      default:
        return iconPath; // Return as-is if it's already a name
    }
  }

  /// Map important names to their icon paths
  String _getImportantIconPath(String importantName) {
    switch (importantName) {
      case "Stay Calm Under Pressure":
        return IconsPath.stay;
      case "Lead with Confidence":
        return IconsPath.build;
      case "Find My Purpose":
        return IconsPath.find;
      case "Be Present as a Father":
        return IconsPath.fatherhgood;
      case "Improve Relationships":
        return IconsPath.improve;
      case "Sleep Better & Recharge":
        return IconsPath.sleepicon;
      case "Strengthen Discipline & Habits":
        return IconsPath.stranged;
      case "Mental Peace & Clarity":
        return IconsPath.mantal;
      case "Release Stress & Anger":
        return IconsPath.relese;
      // Legacy names for backward compatibility
      case "Find Inner Peace":
        return IconsPath.find;
      case "Fatherhood & Family":
        return IconsPath.fatherhgood;
      case "Build Confidence":
        return IconsPath.build;
      case "Sleep & Rest":
        return IconsPath.sleepicon;
      default:
        return IconsPath.find; // Default fallback
    }
  }

  /// Map icon paths back to important names (for backward compatibility)
  String _getImportantNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/stay.png":
        return "Stay Calm Under Pressure";
      case "assets/icons/build.png":
        return "Lead with Confidence";
      case "assets/icons/find.png":
        return "Find My Purpose";
      case "assets/icons/fatherhgood.png":
        return "Be Present as a Father";
      case "assets/icons/improve.png":
        return "Improve Relationships";
      case "assets/icons/sleepicon.png":
        return "Sleep Better & Recharge";
      case "assets/icons/stranged.png":
        return "Strengthen Discipline & Habits";
      case "assets/icons/mantal.png":
        return "Mental Peace & Clarity";
      case "assets/icons/relese.png":
        return "Release Stress & Anger";
      default:
        return iconPath; // Return as-is if it's already a name
    }
  }

  /// Map goal names to their icon paths
  String _getGoalIconPath(String goalName) {
    switch (goalName) {
      case "Discover New Practices":
        return IconsPath.discover;
      case "Build Consistency":
        return IconsPath.build;
      case "Find Inner Peace":
        return IconsPath.find;
      case "Sleep & Rest":
        return IconsPath.sleepicon;
      default:
        return IconsPath.discover; // Default fallback
    }
  }

  /// Map icon paths back to goal names (for backward compatibility)
  String _getGoalNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/discover.png":
        return "Discover New Practices";
      case "assets/icons/build.png":
        return "Build Consistency";
      case "assets/icons/find.png":
        return "Find Inner Peace";
      case "assets/icons/sleepicon.png":
        return "Sleep & Rest";
      default:
        return iconPath; // Return as-is if it's already a name
    }
  }
}
