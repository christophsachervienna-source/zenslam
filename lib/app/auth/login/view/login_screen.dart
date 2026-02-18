import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/services/google_sign_in_service.dart';
import 'package:zenslam/app/auth/login/view/forgot_email_screen.dart';
import 'package:zenslam/app/auth/login/controller/login_controller.dart';
import 'package:zenslam/app/auth/login/controller/social_auth_controller.dart';
import 'package:zenslam/app/auth/register/view/register_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              // Back button
                              _buildBackButton(),

                              const SizedBox(height: 40),

                              // Logo and welcome
                              _buildHeader(),

                              const SizedBox(height: 40),

                              // Form fields
                              _buildEmailField(),
                              const SizedBox(height: 20),
                              _buildPasswordField(),

                              const SizedBox(height: 12),

                              // Forgot password
                              _buildForgotPassword(),

                              const SizedBox(height: 32),

                              // Login button
                              _buildLoginButton(),

                              const SizedBox(height: 24),

                              // Divider
                              _buildDivider(),

                              const SizedBox(height: 24),

                              // Google sign in
                              _buildGoogleButton(),

                              const Spacer(),

                              // Register link
                              _buildRegisterLink(),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.back();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: QuestionnaireTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.primaryColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome back',
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your journey',
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textPrimary,
          ),
          cursorColor: AppColors.primaryColor,
          decoration: _inputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
          ),
          validator: controller.validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            style: QuestionnaireTheme.bodyLarge(
              color: QuestionnaireTheme.textPrimary,
            ),
            cursorColor: AppColors.primaryColor,
            decoration: _inputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: GestureDetector(
                onTap: controller.togglePassword,
                child: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: QuestionnaireTheme.textTertiary,
                  size: 20,
                ),
              ),
            ),
            validator: controller.validatePassword,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: QuestionnaireTheme.bodyMedium(
        color: QuestionnaireTheme.textTertiary,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(
          prefixIcon,
          color: QuestionnaireTheme.textTertiary,
          size: 20,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 16),
              child: suffixIcon,
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: QuestionnaireTheme.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: QuestionnaireTheme.borderDefault,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: QuestionnaireTheme.borderDefault,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFE57373),
        fontSize: 12,
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Get.to(() => ForgotEmailScreen()),
        child: Text(
          'Forgot Password?',
          style: QuestionnaireTheme.bodySmall(
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_formKey.currentState!.validate()) {
          controller.login(_formKey);
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Sign In',
            style: QuestionnaireTheme.titleMedium(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: QuestionnaireTheme.borderDefault,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: QuestionnaireTheme.borderDefault,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: QuestionnaireTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: QuestionnaireTheme.borderDefault,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImagePath.googleimage,
              height: 22,
              width: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Get.off(() => const RegisterScreen()),
          child: Text(
            'Create Account',
            style: QuestionnaireTheme.bodyMedium(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _handleGoogleSignIn() async {
  try {
    HapticFeedback.lightImpact();
    debugPrint('🚀 Starting Google Sign-In process...');

    final userData = await GoogleSignInService.signInWithGoogle();

    if (userData == null) {
      return;
    }

    final String name = userData['name'];
    final String email = userData['email'];
    final String imageUrl = userData['photoUrl'];

    debugPrint('✅ Google user obtained: $name - $email');

    Get.snackbar(
      'Processing...',
      'Setting up your account',
      backgroundColor: QuestionnaireTheme.cardBackground,
      colorText: QuestionnaireTheme.textPrimary,
    );

    final SocialAuthController socialAuthController = Get.put(
      SocialAuthController(),
    );

    await socialAuthController.socialLogin(
      name: name,
      email: email,
      isFromSignUp: false,
      imageUrl: imageUrl,
    );
  } on GoogleSignInException catch (e) {
    debugPrint('💥 Google Sign-In Error: ${e.code} - ${e.details}');

    if (e.code != GoogleSignInExceptionCode.canceled) {
      Get.snackbar(
        'Sign-In Failed',
        _getUserFriendlyErrorMessage(e),
        backgroundColor: const Color(0xFF1A1A1F),
        colorText: Colors.white,
      );
    }
  } catch (e) {
    debugPrint('💥 Unexpected Error: $e');
    Get.snackbar(
      'Sign-In Failed',
      'Unable to sign in. Please try again.',
      backgroundColor: const Color(0xFF1A1A1F),
      colorText: Colors.white,
    );
  }
}

String _getUserFriendlyErrorMessage(dynamic error) {
  if (error is GoogleSignInException) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return '';
      case GoogleSignInExceptionCode.interrupted:
        return 'Sign-in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Client configuration error. Please contact support.';
      default:
        return 'Unable to sign in with Google. Please try again.';
    }
  }

  if (error is AuthException) {
    return error.message;
  }
  return 'An unexpected error occurred. Please try again.';
}
