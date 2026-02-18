// services/preferences_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/app/notification_flow/model/preference_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PreferencesService {
  // Replace with your actual API base URL

  /// Fetch preferences from API
  static Future<PreferencesResponse?> getPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/prefereances'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        log('✅ Preferences loaded successfully: $jsonData');
        return PreferencesResponse.fromJson(jsonData);
      } else {
        debugPrint('Failed to load preferences: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching preferences: $e');
      return null;
    }
  }
}
