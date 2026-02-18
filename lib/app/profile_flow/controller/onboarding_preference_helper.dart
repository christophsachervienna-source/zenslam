import 'dart:convert';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/profile_flow/controller/select_goal_controller.dart';
import 'package:zenslam/app/profile_flow/controller/select_reason_controller.dart';
import 'package:zenslam/app/onboarding_flow/controller/select_time_controller.dart';
import 'package:zenslam/app/onboarding_flow/controller/selected_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Helper class to manage onboarding preferences
/// Saves user selections during onboarding flow to SharedPreferences
class OnboardingPreferenceHelper {
  
  /// Save all onboarding preferences to SharedPreferences
  static Future<void> saveAllPreferences() async {
    try {
      debugPrint('\n========== SAVING ONBOARDING PREFERENCES ==========');
      
      // Save Reason Here
      await _saveReasonHere();
      
      // Save Practice Commit (Time)
      await _savePracticeCommit();
      
      // Save Most Important
      await _saveMostImportant();
      
      // Save Top Goals
      await _saveTopGoals();
      
      debugPrint('✅ All onboarding preferences saved successfully');
      debugPrint('====================================================\n');
    } catch (e) {
      debugPrint('❌ Error saving onboarding preferences: $e');
    }
  }

  /// Save Reason Here preferences
  static Future<void> _saveReasonHere() async {
    try {
      final controller = Get.find<SelectReasonController>();
      final selectedReasons = controller.reasonModel.value.selectedReasons;
      
      if (selectedReasons.isNotEmpty) {
        // Extract only the reason names (keys), not the icon paths
        final reasonNames = selectedReasons.keys.toList();
        final reasonJson = jsonEncode(reasonNames);
        
        await SharedPrefHelper.saveReasonHere(reasonJson);
        debugPrint('✅ Saved reasonHere: $reasonJson');
      } else {
        debugPrint('⚠️ No reasons selected');
      }
    } catch (e) {
      debugPrint('⚠️ Could not save reasonHere: $e');
    }
  }

  /// Save Practice Commit (Time) preferences
  static Future<void> _savePracticeCommit() async {
    try {
      final controller = Get.find<SelectTimeController>();
      final selectedTimes = controller.timeModel.value.selectedTimes.toList();
      
      if (selectedTimes.isNotEmpty) {
        final timeJson = jsonEncode(selectedTimes);
        
        await SharedPrefHelper.savePracticeCommit(timeJson);
        debugPrint('✅ Saved practiceCommit: $timeJson');
      } else {
        debugPrint('⚠️ No times selected');
      }
    } catch (e) {
      debugPrint('⚠️ Could not save practiceCommit: $e');
    }
  }

  /// Save Most Important preferences
  static Future<void> _saveMostImportant() async {
    try {
      final controller = Get.find<SelectedController>();
      final selectedImportants = controller.importantModel.value.selectedImportants;
      
      if (selectedImportants.isNotEmpty) {
        // Extract only the important names (keys), not the icon paths
        final importantNames = selectedImportants.keys.toList();
        final importantJson = jsonEncode(importantNames);
        
        await SharedPrefHelper.saveMostImportant(importantJson);
        debugPrint('✅ Saved mostImportant: $importantJson');
      } else {
        debugPrint('⚠️ No importants selected');
      }
    } catch (e) {
      debugPrint('⚠️ Could not save mostImportant: $e');
    }
  }

  /// Save Top Goals preferences
  static Future<void> _saveTopGoals() async {
    try {
      final controller = Get.find<SelectGoalController>();
      final selectedGoals = controller.goalModel.value.selectedGoals;
      
      if (selectedGoals.isNotEmpty) {
        // Extract only the goal names (keys), not the icon paths
        final goalNames = selectedGoals.keys.toList();
        final goalJson = jsonEncode(goalNames);
        
        await SharedPrefHelper.saveTopGoals(goalJson);
        debugPrint('✅ Saved topGoals: $goalJson');
      } else {
        debugPrint('⚠️ No goals selected');
      }
    } catch (e) {
      debugPrint('⚠️ Could not save topGoals: $e');
    }
  }

  /// Get all saved preferences for API update
  static Future<Map<String, dynamic>> getAllPreferencesForApi() async {
    try {
      debugPrint('\n========== LOADING PREFERENCES FOR API ==========');
      
      final Map<String, dynamic> preferences = {};
      
      // Load Reason Here
      final reasonJson = await SharedPrefHelper.getReasonHere();
      if (reasonJson != null && reasonJson.isNotEmpty) {
        final reasons = jsonDecode(reasonJson) as List<dynamic>;
        preferences['reasonHere'] = reasons;
        debugPrint('📤 reasonHere: $reasons');
      }
      
      // Load Practice Commit
      final commitJson = await SharedPrefHelper.getPracticeCommit();
      if (commitJson != null && commitJson.isNotEmpty) {
        final commits = jsonDecode(commitJson) as List<dynamic>;
        preferences['practiceCommit'] = commits;
        debugPrint('📤 practiceCommit: $commits');
      }
      
      // Load Most Important
      final importantJson = await SharedPrefHelper.getMostImportant();
      if (importantJson != null && importantJson.isNotEmpty) {
        final importants = jsonDecode(importantJson) as List<dynamic>;
        preferences['mostImportant'] = importants;
        debugPrint('📤 mostImportant: $importants');
      }
      
      // Load Top Goals
      final goalsJson = await SharedPrefHelper.getTopGoals();
      if (goalsJson != null && goalsJson.isNotEmpty) {
        final goals = jsonDecode(goalsJson) as List<dynamic>;
        preferences['topGoals'] = goals;
        debugPrint('📤 topGoals: $goals');
      }
      
      debugPrint('✅ Loaded ${preferences.length} preference fields');
      debugPrint('=================================================\n');
      
      return preferences;
    } catch (e) {
      debugPrint('❌ Error loading preferences for API: $e');
      return {};
    }
  }

  /// Clear all onboarding preferences after successful account creation
  static Future<void> clearAllPreferences() async {
    try {
      debugPrint('🧹 Clearing onboarding preferences...');
      await SharedPrefHelper.clearPreferences();
      await SharedPrefHelper.clearOnboardingName();
      debugPrint('✅ Onboarding preferences cleared');
    } catch (e) {
      debugPrint('❌ Error clearing preferences: $e');
    }
  }
}

