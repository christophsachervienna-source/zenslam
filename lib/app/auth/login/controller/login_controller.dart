import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/core/services/notification_service.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';

// Custom exception classes for better error categorization
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class TokenException implements Exception {
  final String message;

  TokenException(this.message);

  @override
  String toString() => 'TokenException: $message';
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class LoginController extends GetxController {
  // Observables
  final obscurePassword = true.obs;
  final errorMessage = ''.obs;
  final RxString fcmToken = ''.obs;
  final String? redirectTo = Get.arguments as String?;
  final RxBool isLoggingIn = false.obs;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Constants
  static const _minPasswordLength = 6;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      debugPrint(
        '🔔 Initializing Notification Service from LoginController...',
      );
      await NotificationService.initialize();
      final token = await NotificationService.getFcmToken();
      if (token != null) {
        fcmToken.value = token;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to initialize notifications: $e');
      // Non-critical, continue without FCM token
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validation methods
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
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < _minPasswordLength) {
      return "Password must be at least $_minPasswordLength characters";
    }
    return null;
  }

  /// Enhanced error handling method
  void _handleError(
    dynamic error, {
    String fallbackMessage = 'Something went wrong. Please try again.',
    bool showSnackbar = true,
    bool dismissLoading = true,
  }) {
    if (dismissLoading) {
      EasyLoading.dismiss();
    }

    isLoggingIn.value = false;

    debugPrint('💥 Error Details:');
    debugPrint('  Type: ${error.runtimeType}');
    debugPrint('  Message: ${error.toString()}');
    if (error is ApiException) {
      debugPrint('  Status Code: ${error.statusCode}');
    }
    if (error is http.ClientException) {
      debugPrint('  URL: ${error.uri}');
    }

    // Determine user-friendly message based on error type
    String userMessage;

    if (error is ApiException) {
      userMessage = error.message;
    } else if (error is NetworkException) {
      userMessage = error.message;
    } else if (error is TimeoutException) {
      userMessage =
          'Request timeout. Please check your connection and try again.';
    } else if (error is SocketException || error is http.ClientException) {
      userMessage = 'Network error. Please check your internet connection.';
    } else if (error is FormatException || error is TypeError) {
      userMessage = 'Data format error. Please try again later.';
    } else if (error is ValidationException) {
      userMessage = error.message;
    } else if (error is TokenException) {
      userMessage = error.message;
    } else if (error is AuthException) {
      userMessage = error.message;
    } else {
      userMessage = fallbackMessage;
    }

    // Update error state
    errorMessage.value = userMessage;

    // Show snackbar if requested
    if (showSnackbar) {
      Get.snackbar('Error', userMessage, margin: const EdgeInsets.all(10));
    }
  }

  /// Enhanced API response handler
  Map<String, dynamic> _handleApiResponse(http.Response response) {
    debugPrint('📡 API Response Status: ${response.statusCode}');

    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          return responseData;
        } else {
          final errorMsg =
              responseData['data']?['message'] ??
              responseData['message'] ??
              'Request failed';
          throw ApiException(
            message: errorMsg,
            statusCode: response.statusCode,
            data: responseData,
          );
        }
      } else {
        // Handle different HTTP error status codes
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage =
                responseData['data']?['message'] ??
                'Bad request. Please check your input.';
            break;
          case 401:
            errorMessage = 'Invalid email or password.';
            throw AuthException(errorMessage);
          case 403:
            errorMessage = 'Access denied. Your account may be restricted.';
            break;
          case 404:
            errorMessage = 'Service not found. Please try again later.';
            break;
          case 422:
            errorMessage =
                responseData['data']?['message'] ??
                'Validation failed. Please check your input.';
            break;
          case 429:
            errorMessage =
                'Too many attempts. Please try again in a few minutes.';
            break;
          case 500:
          case 502:
          case 503:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage =
                responseData['data']?['message'] ??
                responseData['message'] ??
                'Request failed with status ${response.statusCode}';
        }

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          data: responseData,
        );
      }
    } on FormatException {
      throw ApiException(
        message: 'Invalid response from server. Please try again.',
        statusCode: response.statusCode,
      );
    } on AuthException {
      rethrow; // Re-throw auth exceptions for special handling
    } catch (e) {
      if (e is ApiException || e is AuthException) rethrow;
      throw ApiException(
        message: 'Failed to process server response',
        statusCode: response.statusCode,
      );
    }
  }

  /// Main login method
  Future<void> login(GlobalKey<FormState> formKey) async {
    // Prevent multiple simultaneous logins
    if (isLoggingIn.value) return;

    // Validate form
    if (!formKey.currentState!.validate()) {
      _handleError(
        ValidationException('Please fill all required fields correctly'),
        showSnackbar: true,
        dismissLoading: false,
      );
      return;
    }

    // Clear previous errors
    errorMessage.value = '';
    isLoggingIn.value = true;

    try {
      EasyLoading.show(
        status: 'Logging in...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      final response = await http
          .post(
            Uri.parse('${Urls.baseUrl}/auth/login-with-email'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': emailController.text.trim(),
              'password': passwordController.text,
              'fcmToken': fcmToken.value.isNotEmpty ? fcmToken.value : '',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = _handleApiResponse(response);

      // Process successful login
      await _processSuccessfulLogin(responseData);
    } on TimeoutException catch (e) {
      _handleError(e, showSnackbar: true);
    } on SocketException {
      _handleError(
        NetworkException(
          'No internet connection. Please check your network and try again.',
        ),
        showSnackbar: true,
      );
    } on http.ClientException {
      _handleError(
        NetworkException('Network request failed. Please try again.'),
        showSnackbar: true,
      );
    } on AuthException catch (e) {
      // Special handling for auth errors
      _handleError(
        e,
        showSnackbar: true,
        fallbackMessage:
            'Invalid credentials. Please check your email and password.',
      );
    } on ApiException catch (e) {
      _handleError(e, showSnackbar: true);
    } catch (e) {
      _handleError(
        e,
        showSnackbar: true,
        fallbackMessage: 'An unexpected error occurred. Please try again.',
      );
    } finally {
      isLoggingIn.value = false;
    }
  }

  /// Process successful login response
  Future<void> _processSuccessfulLogin(
    Map<String, dynamic> responseData,
  ) async {
    try {
      debugPrint('\n✅ Login successful, processing response...');

      final data = responseData['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      final userId = data['id']?.toString();

      // Validate required tokens
      if (accessToken == null || accessToken.isEmpty) {
        throw TokenException('Access token is missing. Please try again.');
      }

      if (refreshToken == null || refreshToken.isEmpty) {
        throw TokenException('Refresh token is missing. Please try again.');
      }

      if (userId == null || userId.isEmpty) {
        throw ValidationException('User ID is missing. Please try again.');
      }

      // Save tokens securely
      await _saveTokensSecurely(accessToken, refreshToken, userId);

      // Show success message
      EasyLoading.showSuccess(
        'Welcome back!',
        duration: const Duration(seconds: 1),
      );

      // Fetch user profile in background (non-critical)
      _fetchAndSaveUserProfile(accessToken);

      // Clear form fields
      _clearFields();

      // Small delay before navigation
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh profile data and all home sections to ensure UI updates
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refreshProfile();
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refreshAllControls();
      }

      // Navigate based on requirements
      _navigateAfterLogin();
    } on TokenException catch (e) {
      _handleError(e, showSnackbar: true);
    } on ValidationException catch (e) {
      _handleError(e, showSnackbar: true);
    } catch (e) {
      _handleError(
        ApiException(
          message: 'Failed to process login data. Please try again.',
        ),
        showSnackbar: true,
      );
    }
  }

  /// Save tokens with validation
  Future<void> _saveTokensSecurely(
    String accessToken,
    String refreshToken,
    String userId,
  ) async {
    try {
      debugPrint('🔐 Saving tokens...');

      // Save tokens
      await SharedPrefHelper.saveAccessToken(accessToken);
      await SharedPrefHelper.saveRefreshToken(refreshToken);
      await SharedPrefHelper.saveUserId(userId);

      // Verify tokens were saved correctly
      final savedAccessToken = await SharedPrefHelper.getAccessToken();
      final savedRefreshToken = await SharedPrefHelper.getRefreshToken();
      final savedUserId = await SharedPrefHelper.getUserId();

      if (savedAccessToken != accessToken) {
        throw TokenException(
          'Failed to save access token correctly. Please try again.',
        );
      }

      if (savedRefreshToken != refreshToken) {
        throw TokenException(
          'Failed to save refresh token correctly. Please try again.',
        );
      }

      if (savedUserId != userId) {
        throw TokenException(
          'Failed to save user ID correctly. Please try again.',
        );
      }

      debugPrint('✅ Tokens saved and verified successfully');
    } on PlatformException catch (e) {
      throw TokenException(
        'Failed to save tokens: ${e.message ?? "Storage error"}',
      );
    } catch (e) {
      throw TokenException('Unexpected error saving tokens. Please try again.');
    }
  }

  /// Navigate after successful login
  void _navigateAfterLogin() {
    if (redirectTo == 'subscription') {
      // Get.offAll(() => SubcriptionScreen());
      Get.offAll(() => NavBarScreen()); // Fallback for now
    } else {
      Get.offAll(() => NavBarScreen());
    }
  }

  /// Clear text fields after successful login
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
    obscurePassword.value = true;
  }

  /// Helper method to clear all fields manually if needed
  void clearAllFields() {
    _clearFields();
  }

  /// Fetch user profile from /auth/me endpoint using ApiService
  Future<void> _fetchAndSaveUserProfile(String accessToken) async {
    debugPrint('\n📞 Fetching user profile...');

    try {
      final apiResponse = await ApiService.get(
        endpoint: 'auth/me',
        token: accessToken,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📡 Profile API Response Status: ${apiResponse.statusCode}');

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final userData = responseData['data']['user'] as Map<String, dynamic>;
          await _saveUserDataToPrefs(userData);
          debugPrint('✅ User profile saved successfully');
        } else {
          debugPrint('⚠️ Profile API returned success: false');
        }
      } else {
        debugPrint('⚠️ Failed to fetch user profile: ${apiResponse.error}');
      }
    } on TimeoutException {
      debugPrint('⚠️ Profile fetch timeout - will retry later');
      _scheduleProfileRetry(accessToken);
    } catch (e, stackTrace) {
      debugPrint('💥 Error fetching user profile: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
      // Non-critical error - don't disrupt the login flow
    }
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData) async {
    try {
      final fullName = userData['fullName']?.toString() ?? '';
      final email = userData['email']?.toString() ?? '';
      final image = userData['image']?.toString() ?? '';
      final role = userData['role']?.toString() ?? '';

      // Save basic user info
      await SharedPrefHelper.saveUserName(fullName);
      await SharedPrefHelper.saveUserEmail(email);

      if (image.isNotEmpty) {
        await SharedPrefHelper.saveUserImage(image);
      }
      if (role.isNotEmpty) {
        await SharedPrefHelper.saveUserRole(role);
      }

      // Save preferences
      await _saveUserPreferences(userData);

      debugPrint('💾 User data saved to SharedPreferences');
    } catch (e) {
      debugPrint('⚠️ Error saving user data: $e');
      // Non-critical - continue
    }
  }

  /// Save user preferences to SharedPreferences
  Future<void> _saveUserPreferences(Map<String, dynamic> userData) async {
    try {
      final reasonHere = userData['reasonHere'] as List<dynamic>?;
      final mostImportant = userData['mostImportant'] as List<dynamic>?;
      final practiceCommit = userData['practiceCommit'] as List<dynamic>?;
      final topGoals = userData['topGoals'] as List<dynamic>?;

      if (reasonHere != null && reasonHere.isNotEmpty) {
        await SharedPrefHelper.saveReasonHere(jsonEncode(reasonHere));
      }

      if (mostImportant != null && mostImportant.isNotEmpty) {
        await SharedPrefHelper.saveMostImportant(jsonEncode(mostImportant));
      }

      if (practiceCommit != null && practiceCommit.isNotEmpty) {
        await SharedPrefHelper.savePracticeCommit(jsonEncode(practiceCommit));
      }

      if (topGoals != null && topGoals.isNotEmpty) {
        await SharedPrefHelper.saveTopGoals(jsonEncode(topGoals));
      }

      debugPrint('✅ Preferences saved successfully');
    } catch (e) {
      debugPrint('⚠️ Error saving preferences: $e');
    }
  }

  /// Schedule profile retry
  void _scheduleProfileRetry(String accessToken) {
    // You could implement retry logic here
    // For example, save to a queue and retry when app resumes
    debugPrint('📅 Scheduling profile retry for later...');
  }
}
