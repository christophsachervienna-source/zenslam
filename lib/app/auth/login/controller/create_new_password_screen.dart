import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/auth/forgot_password_flow/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  CreateNewPasswordScreen({super.key});

  final controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xff94A3B8), width: 1.5),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController textController,
    required String hint,
    required String? Function(String?) validator,
    required RxBool obscureText,
    required RxString error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: textController,
            obscureText: obscureText.value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _inputBorder(),
              errorBorder: _errorBorder(),
              focusedErrorBorder: _errorBorder(),
              suffixIcon: IconButton(
                icon: Image.asset(
                  obscureText.value
                      ? IconsPath.visibilityOff
                      : IconsPath.visibilityOn,
                  color: Color(0xff6A7381),
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                onPressed: () => obscureText.value = !obscureText.value,
              ),
            ),
            validator: validator,
            onChanged: (value) {
              // Clear error when user starts typing
              if (error.isNotEmpty) {
                error.value = '';
              }
            },
          ),
        ),
        Obx(
          () => error.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    error.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.appBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 15,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Create New Password",
                        style: globalTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        label: "Password",
                        textController: controller.passwordController,
                        hint: "Password",
                        validator: controller.validatePassword,
                        obscureText: controller.obscurePassword,
                        error: controller.passwordError,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: "Confirm Password",
                        textController: controller.confirmPasswordController,
                        hint: "Retype Password",
                        validator: controller.validateConfirmPassword,
                        obscureText: controller.obscureConfirmPassword,
                        error: controller.confirmPasswordError,
                      ),
                      const Spacer(),
                      // Global error message
                      Obx(
                        () => controller.errorMessage.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      CustomButton(
                        title: "Reset Password",
                        onTap: () {
                          // Clear all errors first
                          controller.errorMessage.value = '';
                          controller.passwordError.value = '';
                          controller.confirmPasswordError.value = '';

                          // Validate form
                          if (_formKey.currentState!.validate()) {
                            controller.resetPassword();
                          }
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
