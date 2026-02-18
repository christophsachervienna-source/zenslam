import 'dart:async';
import 'dart:convert';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/auth/register/view/verify_otp_screen.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/app/profile_flow/controller/onboarding_preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController {
  // Observables
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final errorMessage = ''.obs;
  final remainingSeconds = 300.obs;

  // Controllers
  final nameController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Constants
  static const _timeoutDuration = 120;
  static const _minPasswordLength = 6;
  static const _otpLength = 4;

  final String _keyReasonHere = 'reasonHere';
  final String _keyMostImportant = 'mostImportant';
  final String _keyPracticeCommit = 'practiceCommit';
  final String _keyTopGoals = 'topGoals';

  // Timer instance
  Timer? _timer;
  void startTimer() {
    _timer?.cancel();
    remainingSeconds.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Validation methods
  String? validateName(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  String? validateEmail(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return "Please enter your email";
    }
    if (!GetUtils.isEmail(trimmedValue)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Common error handling method
  void _handleError(
    dynamic e, {
    String fallbackMessage = 'Network error. Please try again.',
  }) {
    debugPrint('💥 Error: $e');
    EasyLoading.dismiss();
    errorMessage.value = fallbackMessage;
    Get.snackbar('Error', fallbackMessage);
  }

  /// Common API response handler
  bool _handleApiResponse(
    http.Response response, {
    required String successMessage,
  }) {
    debugPrint("📡 API Response: ${response.statusCode} ${response.body}");

    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (successMessage.isNotEmpty) {
          EasyLoading.showSuccess(
            successMessage,
            duration: const Duration(seconds: 2),
          );
        } else {
          EasyLoading.dismiss();
        }
        errorMessage.value = ''; // Clear any previous errors
        return true;
      } else {
        final errorMsg = responseData['message'] ?? 'Something went wrong';
        errorMessage.value = errorMsg;
        EasyLoading.dismiss();
        Get.snackbar('Error', errorMsg);
        return false;
      }
    } catch (e) {
      final errorMsg = 'Invalid response format';
      errorMessage.value = errorMsg;
      EasyLoading.dismiss();
      Get.snackbar('Error', errorMsg);
      return false;
    }
  }

  /// Register request
  Future<void> registerRequest(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    // Clear previous errors
    errorMessage.value = '';

    try {
      EasyLoading.show(status: 'Registering...');

      final prefs = await SharedPreferences.getInstance();

      final String? reasonHereJson = prefs.getString(_keyReasonHere);
      final String? mostImportantJson = prefs.getString(_keyMostImportant);
      final String? practiceCommitJson = prefs.getString(_keyPracticeCommit);
      final String? topGoalsJson = prefs.getString(_keyTopGoals);

      List<String> reasonHere = [];
      List<String> mostImportant = [];
      List<String> practiceCommit = [];
      List<String> topGoals = [];

      if (reasonHereJson != null) {
        reasonHere = List<String>.from(jsonDecode(reasonHereJson));
      }

      if (mostImportantJson != null) {
        mostImportant = List<String>.from(jsonDecode(mostImportantJson));
      }

      if (practiceCommitJson != null) {
        practiceCommit = List<String>.from(jsonDecode(practiceCommitJson));
      }

      if (topGoalsJson != null) {
        topGoals = List<String>.from(jsonDecode(topGoalsJson));
      }
      final fcmToken = await NotificationService.getFcmToken();

      debugPrint("📤 Registering user: ${emailController.text.trim()}");
      final response = await http
          .post(
            Uri.parse('${Urls.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': nameController.text.trim(),
              'email': emailController.text.trim().toLowerCase(),
              'password': passwordController.text.trim(),
              'confirmPassword': confirmPasswordController.text.trim(),
              'reasonHere': reasonHere,
              'practiceCommit': practiceCommit,
              'mostImportant': mostImportant,
              'topGoals': topGoals,
              'fcmToken': fcmToken ?? '',
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint("📡 Registration Response Status: ${response.statusCode}");

      if (_handleApiResponse(
        response,
        successMessage: 'OTP sent to your email',
      )) {
        startTimer();
        Get.to(() => RegVerifyOtpScreen());
      }
    } on TimeoutException {
      _handleError(
        'Timeout',
        fallbackMessage: 'Request timeout. Please try again.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> sendResetCode() async {
    // Use the existing validateEmail method instead of creating a new one
    final emailError = validateEmail(emailController.text);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }

    // Clear previous errors
    errorMessage.value = '';

    try {
      EasyLoading.show(
        status: 'Sending reset code...',
        maskType: EasyLoadingMaskType.black,
      );

      final response = await http
          .post(
            Uri.parse('${Urls.baseUrl}/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': emailController.text.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      if (_handleApiResponse(
        response,
        successMessage: 'Reset code sent to your email',
      )) {
        startTimer();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } on TimeoutException {
      _handleError(
        'Timeout',
        fallbackMessage: 'Request timeout. Please try again.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> verify() async {
    if (kDebugMode) {
      debugPrint("Name: ${nameController.text} Email: ${emailController.text}");
    }

    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != _otpLength) {
      errorMessage.value = 'Please enter a valid $_otpLength-digit OTP';
      return;
    }

    // Clear previous errors
    errorMessage.value = '';

    try {
      EasyLoading.show(
        status: 'Verifying OTP...',
        maskType: EasyLoadingMaskType.black,
      );

      final response = await http
          .patch(
            Uri.parse('${Urls.baseUrl}/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': emailController.text.trim(),
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final token = responseData["data"]["accessToken"]?.toString();

          if (token != null) {
            debugPrint('🔐 Saving tokens...');
            await SharedPrefHelper.saveRefreshToken(token);
            await SharedPrefHelper.saveAccessToken(token);

            EasyLoading.showSuccess(
              'OTP verified successfully',
              duration: const Duration(seconds: 2),
            );

            // Fetch and save user profile from /auth/me endpoint
            debugPrint('📞 Calling _fetchAndSaveUserProfile()...');
            await _fetchAndSaveUserProfile(token);

            // Update preferences via API after successful registration
            debugPrint('📞 Calling _updatePreferencesAfterRegistration()...');
            await _updatePreferencesAfterRegistration(token);

            // Refresh profile data to ensure UI updates
            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().refreshProfile();
            }

            // Refresh all home data after registration/OTP verification
            if (Get.isRegistered<HomeController>()) {
              await Get.find<HomeController>().refreshAllControls();
            }

            debugPrint('🚀 Navigating to NavBarScreen...');
            clearAllFields();
            Get.offAll(() => NavBarScreen());
          } else {
            final errorMsg = 'Invalid token received from server';
            errorMessage.value = errorMsg;
            EasyLoading.dismiss();
            Get.snackbar('Verification Failed', errorMsg);
          }
        } else {
          final errorMsg = responseData['message'] ?? 'Invalid OTP';
          errorMessage.value = errorMsg;
          EasyLoading.dismiss();
          Get.snackbar('Verification Failed', errorMsg);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'Failed to verify OTP';
        errorMessage.value = errorMsg;
        EasyLoading.dismiss();
        Get.snackbar('Verification Failed', errorMsg);
      }
    } on TimeoutException {
      _handleError('Timeout', fallbackMessage: 'OTP verification timeout.');
    } catch (e) {
      _handleError(e);
    }
  }

  // Helper method to clear all fields manually if needed
  void clearAllFields() {
    nameController.clear();
    otpController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    errorMessage.value = '';
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
    _timer?.cancel();
    remainingSeconds.value = _timeoutDuration;
  }

  // Helper method to check if timer is active
  bool get isTimerActive =>
      remainingSeconds.value > 0 && _timer?.isActive == true;

  // Format remaining time as MM:SS
  String get formattedRemainingTime {
    int seconds = remainingSeconds.value;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  /// Fetch user profile from /auth/me endpoint using ApiService
  Future<void> _fetchAndSaveUserProfile(String accessToken) async {
    try {
      debugPrint('🌐 Fetching user profile after registration...');

      // Use ApiService.get() instead of raw http.get()
      final apiResponse = await ApiService.get(
        endpoint: 'auth/me',
        token: accessToken,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final userData = responseData['data']['user'];

          final fullName = userData['fullName']?.toString() ?? '';
          final email = userData['email']?.toString() ?? '';
          final image = userData['image']?.toString() ?? '';
          final role = userData['role']?.toString() ?? '';

          // Save user data (always save, even if empty)
          await SharedPrefHelper.saveUserName(fullName);
          await SharedPrefHelper.saveUserEmail(email);
          if (image.isNotEmpty) {
            await SharedPrefHelper.saveUserImage(image);
          }
          if (role.isNotEmpty) {
            await SharedPrefHelper.saveUserRole(role);
          }

          debugPrint('✅ User profile saved successfully');
        } else {
          debugPrint('❌ API returned success: false');
        }
      } else {
        debugPrint('⚠️ API call failed: ${apiResponse.error}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error fetching user profile: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
    }
  }

  /// Update user preferences via API after successful registration
  Future<void> _updatePreferencesAfterRegistration(String accessToken) async {
    try {
      debugPrint(
        '\n========== UPDATING PREFERENCES AFTER REGISTRATION ==========',
      );

      // Get all saved preferences from SharedPreferences
      final preferences =
          await OnboardingPreferenceHelper.getAllPreferencesForApi();

      // Get the name from the name controller (most up-to-date value)
      final userName = nameController.text.trim();
      debugPrint('🔍 Retrieved name from controller: "$userName"');

      // Prepare data to send to API
      Map<String, dynamic> dataToSend = {};

      // Add name if available
      if (userName.isNotEmpty) {
        dataToSend['fullName'] = userName;
        debugPrint('📤 Full Name: $userName');
      } else {
        debugPrint('⚠️ Name is empty, not sending fullName');
      }

      // Add preferences if available
      if (preferences.isNotEmpty) {
        dataToSend.addAll(preferences);
        debugPrint('📤 Preferences: $preferences');
      }

      if (dataToSend.isEmpty) {
        debugPrint('⚠️ No data to update');
        return;
      }

      debugPrint('📤 Data to send: $dataToSend');
      debugPrint('🌐 Calling update-profile API...');

      // Call update-profile API with name and preferences
      final apiResponse = await ApiService.patch(
        endpoint: 'user/update-profile',
        data: dataToSend,
        token: accessToken,
      );

      debugPrint('📡 API Response Status: ${apiResponse.statusCode}');
      debugPrint('📋 API Response Success: ${apiResponse.success}');

      if (apiResponse.success) {
        debugPrint('✅ Profile updated successfully via API');

        // Save the updated name to SharedPreferences
        if (userName.isNotEmpty) {
          await SharedPrefHelper.saveUserName(userName);
          debugPrint('✅ Saved name to SharedPreferences: $userName');
        }

        // Clear onboarding data after successful update
        await OnboardingPreferenceHelper.clearAllPreferences();
        await SharedPrefHelper.clearOnboardingName();
        debugPrint('🧹 Cleared onboarding data from SharedPreferences');
      } else {
        debugPrint('⚠️ Failed to update profile: ${apiResponse.error}');
        // Don't block user flow if update fails
      }

      debugPrint(
        '=============================================================\n',
      );
    } catch (e, stackTrace) {
      debugPrint('💥 Error updating profile: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
      // Don't block user flow if update fails
    }
  }
}
