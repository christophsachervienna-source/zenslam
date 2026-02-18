// lib/feature/auth/login/controller/social_auth_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/profile_flow/controller/onboarding_preference_helper.dart';

class SocialAuthController extends GetxController {
  var isLoading = false.obs;
  var socialLoginError = ''.obs;

  Future<void> socialLogin({
    required String name,
    required String email,
    String? imageUrl,
    required bool isFromSignUp,
  }) async {
    try {
      EasyLoading.show(status: 'Signing in...');
      isLoading.value = true;
      socialLoginError.value = '';

      debugPrint('🔐 Starting social login for: $email');
      debugPrint('👤 User name: $name');
      debugPrint('🖼️ Image URL: ${imageUrl ?? 'None'}');

      // ✅ SAVE GOOGLE ACCOUNT DATA IMMEDIATELY
      await SharedPrefHelper.saveUserName(name);
      await SharedPrefHelper.saveUserEmail(email);
      // if (imageUrl != null) {
      //   await SharedPrefHelper.saveUserPhotoUrl(imageUrl);
      // }
      debugPrint('✅ Google account data saved: $name, $email');

      final fcmToken = await NotificationService.getFcmToken();

      final uri = Uri.parse('${Urls.baseUrl}/auth/login-with-google');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "fullName": name,
              "email": email,
              "role": "USER",
              "image": imageUrl,
              "fcmToken": fcmToken ?? "",
            }),
          )
          .timeout(const Duration(seconds: 30));

      // Add this debug log:
      debugPrint('📤 Sent to backend:');
      debugPrint('   fullName: $name');
      debugPrint('   email: $email');
      debugPrint('   image: $imageUrl');
      debugPrint('   🔍 Image is null: ${imageUrl == null}');
      debugPrint('   🔍 Image is empty: ${imageUrl?.isEmpty ?? true}');

      debugPrint(
        '📡 Social Login Response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          await _handleSuccess(
            responseData,
            userName: name, // Pass the Google name
            userEmail: email, // Pass the Google email
            isFromSignUp: isFromSignUp,
            role: 'USER',
          );
        } else {
          _handleError(responseData['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        _handleError(responseData['message'] ?? 'Bad request');
      } else if (response.statusCode == 401) {
        _handleError('Authentication failed');
      } else if (response.statusCode == 500) {
        _handleError('Server error. Please try again later.');
      } else {
        _handleError('Request failed. Status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ Social login timeout: $e');
      _handleError('Request timed out. Please check your connection.');
    } catch (e) {
      debugPrint('💥 Social login error: $e');
      _handleError('Network error. Please try again.');
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  /// Handle successful social login response - UPDATED VERSION
  Future<void> _handleSuccess(
    Map<String, dynamic> responseData, {
    required String userName, // Add Google name parameter
    required String userEmail, // Add Google email parameter
    required bool isFromSignUp,
    required String role,
  }) async {
    try {
      debugPrint('🎉 Social login successful, processing response...');
      debugPrint('👤 Using Google account name: $userName');

      // FIX: Access the data directly based on your API response structure
      final Map<String, dynamic> apiData = responseData['data']; // This exists
      final String? accessToken = apiData['accessToken'];
      final String? refreshToken = apiData['refreshToken'];
      final String userId = apiData['id']; // Use 'id' from the response
      final String userRole = apiData['role'] ?? 'USER';

      debugPrint('🔑 Access Token: ${accessToken != null ? "✅" : "❌"}');
      debugPrint('🆔 User ID: $userId');
      debugPrint('🎭 Role: $userRole');

      // Save user ID
      await SharedPrefHelper.saveUserId(userId);
      debugPrint('✅ User ID saved: $userId');

      // ✅ GOOGLE ACCOUNT DATA IS ALREADY SAVED - Just confirm it
      final String? savedName = await SharedPrefHelper.getUserName();
      debugPrint('✅ Confirmed saved Google name: $savedName');

      // Save access token
      if (accessToken != null) {
        await SharedPrefHelper.saveAccessToken(accessToken);
        debugPrint('✅ Access token saved successfully');

        // Sync onboarding preferences
        await _updatePreferencesAfterLogin(accessToken, userName);
      } else {
        debugPrint('⚠️ No access token found in response');
      }

      // Save refresh token if available
      if (refreshToken != null) {
        await SharedPrefHelper.saveRefreshToken(refreshToken);
        debugPrint('✅ Refresh token saved successfully');
      }

      // Show personalized success message with Google name
      Get.snackbar(
        "Welcome, $userName!",
        "Signed in successfully!",
        duration: const Duration(seconds: 3),
      );

      debugPrint('🎯 Navigating to NavBarScreen...');

      // Refresh profile data to ensure UI updates
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshProfile();
      }

      // Navigate to main screen
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAll(() => NavBarScreen());
    } catch (e, stacktrace) {
      debugPrint('💥 Error handling success response: $e');
      debugPrint('💥 Stack trace: $stacktrace');
      _handleError('Failed to process login response: $e');
    }
  }

  void _handleError(String message) {
    socialLoginError.value = message;
    Get.snackbar('Login Failed', message, duration: const Duration(seconds: 4));
  }

  void cleanup() {
    socialLoginError.value = '';
    isLoading.value = false;
  }

  /// Update user preferences via API after successful login
  Future<void> _updatePreferencesAfterLogin(
    String accessToken,
    String userName,
  ) async {
    try {
      debugPrint('\n========== UPDATING PREFERENCES AFTER LOGIN ==========');

      // Get all saved preferences from SharedPreferences
      final preferences =
          await OnboardingPreferenceHelper.getAllPreferencesForApi();

      // Prepare data to send to API
      Map<String, dynamic> dataToSend = {};

      if (userName.isNotEmpty) {
        dataToSend['fullName'] = userName;
      }

      if (preferences.isNotEmpty) {
        dataToSend.addAll(preferences);
      }

      if (dataToSend.isEmpty) {
        debugPrint('⚠️ No data to update');
        return;
      }

      debugPrint('🌐 Calling update-profile API...');

      final apiResponse = await ApiService.patch(
        endpoint: 'user/update-profile',
        data: dataToSend,
        token: accessToken,
      );

      if (apiResponse.success) {
        debugPrint('✅ Profile updated successfully via API');
        await OnboardingPreferenceHelper.clearAllPreferences();
        await SharedPrefHelper.clearOnboardingName();
      } else {
        debugPrint('⚠️ Failed to update profile: ${apiResponse.error}');
      }
    } catch (e) {
      debugPrint('💥 Error updating profile: $e');
    }
  }
}
