import 'dart:async';
import 'dart:convert';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/app/auth/login/controller/create_new_password_screen.dart';
import 'package:zenslam/app/auth/login/view/success_screen.dart';
import 'package:zenslam/app/auth/forgot_password_flow/view/verify_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/const/shared_pref_helper.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var errorMessage = ''.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  RxInt remainingSeconds = 300.obs;
  Timer? _timer;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Please enter your email";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

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

  String get formattedTime {
    int seconds = remainingSeconds.value;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> sendResetCode() async {
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Please enter your email address';
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    try {
      EasyLoading.show(
        status: 'Sending reset code...',
        maskType: EasyLoadingMaskType.black,
      );

      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text.trim()}),
      );

      debugPrint('📡 Forgot Password API Response: ${response.statusCode}');
      debugPrint('📡 Forgot Password API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          EasyLoading.dismiss();

          startTimer();

          EasyLoading.showSuccess(
            'Reset code sent to your email',
            duration: Duration(seconds: 2),
          );

          await Future.delayed(Duration(milliseconds: 500));
          Get.to(() => VerifyScreen(email: ''));
        } else {
          EasyLoading.dismiss();
          errorMessage.value =
              responseData['message'] ?? 'Failed to send reset code';
        }
      } else {
        EasyLoading.dismiss();
        final errorData = jsonDecode(response.body);
        errorMessage.value =
            errorData['message'] ??
            'Failed to send reset code. Please try again.';
      }
    } catch (e) {
      debugPrint('💥 Exception during forgot password: $e');
      EasyLoading.dismiss();
      errorMessage.value =
          'Network error. Please check your connection and try again.';
    }
  }

  Future<void> resendOtp() async {
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Email is required to resend OTP';
      return;
    }

    try {
      EasyLoading.show(
        status: 'Resending code...',
        maskType: EasyLoadingMaskType.black,
      );

      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text.trim()}),
      );

      debugPrint('📡 Resend OTP API Response: ${response.statusCode}');
      debugPrint('📡 Resend OTP API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          EasyLoading.dismiss();

          // Restart the timer
          startTimer();

          EasyLoading.showSuccess(
            'New code sent to your email',
            duration: Duration(seconds: 2),
          );
        } else {
          EasyLoading.dismiss();
          errorMessage.value =
              responseData['message'] ?? 'Failed to resend code';
        }
      } else {
        EasyLoading.dismiss();
        final errorData = jsonDecode(response.body);
        errorMessage.value =
            errorData['message'] ?? 'Failed to resend code. Please try again.';
      }
    } catch (e) {
      debugPrint('💥 Exception during resend OTP: $e');
      EasyLoading.dismiss();
      errorMessage.value =
          'Network error. Please check your connection and try again.';
    }
  }

  // Future<void> verifyOtp() async {
  // final email = emailController.text.trim();

  Future<void> verifyOtp({required String email}) async {
    if (otpController.text.isEmpty || otpController.text.length != 4) {
      errorMessage.value = 'Please enter a valid 4-digit OTP';
      return;
    }

    errorMessage.value = '';

    try {
      EasyLoading.show(
        status: 'Verifying OTP...',
        maskType: EasyLoadingMaskType.black,
      );

      final response = await http.patch(
        Uri.parse('${Urls.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'otp': otpController.text.trim(),
        }),
      );

      debugPrint('📡 Verify OTP API Response: ${response.statusCode}');
      debugPrint('📡 Verify OTP API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          EasyLoading.dismiss();

          EasyLoading.showSuccess(
            'OTP verified successfully',
            duration: Duration(seconds: 2),
          );
          var token = responseData["data"]["accessToken"];
          SharedPrefHelper.saveRefreshToken(token);

          Get.to(() => CreateNewPasswordScreen());
        } else {
          EasyLoading.dismiss();
          errorMessage.value = responseData['message'] ?? 'Invalid OTP';
        }
      } else {
        EasyLoading.dismiss();
        final errorData = jsonDecode(response.body);
        errorMessage.value =
            errorData['message'] ?? 'Failed to verify OTP. Please try again.';
      }
    } catch (e) {
      debugPrint('💥 Exception during OTP verification: $e');
      EasyLoading.dismiss();
      errorMessage.value =
          'Network error. Please check your connection and try again.';
    }
  }

  Future<void> resetPassword() async {
    errorMessage.value = '';

    // Reset individual field errors
    passwordError.value = '';
    confirmPasswordError.value = '';

    // Validate individual fields
    bool hasValidationErrors = false;

    if (passwordController.text.isEmpty) {
      passwordError.value = 'Please enter a new password';
      hasValidationErrors = true;
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters long';
      hasValidationErrors = true;
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
      hasValidationErrors = true;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
      hasValidationErrors = true;
    }

    if (hasValidationErrors) {
      return;
    }

    try {
      EasyLoading.show(
        status: 'Resetting password...',
        maskType: EasyLoadingMaskType.black,
      );

      final token = await SharedPrefHelper.getAccessToken();

      debugPrint('🔑 Token available: ${token != null}');

      if (token == null) {
        EasyLoading.dismiss();
        errorMessage.value =
            'Authorization token is missing. Please login again.';
        return;
      }

      final response = await http.patch(
        Uri.parse('${Urls.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      debugPrint('📡 Reset Password API Response: ${response.statusCode}');
      debugPrint('📡 Reset Password API Body: ${response.body}');

      if (response.body.isEmpty) {
        EasyLoading.dismiss();
        errorMessage.value = 'Empty response from server';
        return;
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess(
            'Password reset successfully',
            duration: Duration(seconds: 2),
          );
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAll(() => SuccessScreen());
        } else {
          EasyLoading.dismiss();
          errorMessage.value =
              responseData['message'] ?? 'Failed to reset password';
        }
      } else {
        EasyLoading.dismiss();
        errorMessage.value =
            responseData['message'] ??
            'Failed to reset password. Please try again.';
      }
    } catch (e) {
      debugPrint('💥 Exception during password reset: $e');
      EasyLoading.dismiss();

      if (e is FormatException) {
        errorMessage.value = 'Invalid response from server';
      } else if (e is http.ClientException) {
        errorMessage.value = 'Network error. Please check your connection.';
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
    }
  }

  // Add these RxString variables to your controller class
  final passwordError = RxString('');
  final confirmPasswordError = RxString('');
  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
