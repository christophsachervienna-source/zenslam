import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/auth/register/controller/register_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller = Get.put(RegisterController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadOnboardingName();
  }

  Future<void> _loadOnboardingName() async {
    final name = await SharedPrefHelper.getOnboardingName();
    if (name != null && name.isNotEmpty) {
      controller.nameController.text = name;
      debugPrint('✅ Auto-filled name from onboarding: $name');
    }
  }

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

                              const SizedBox(height: 32),

                              // Header
                              _buildHeader(),

                              const SizedBox(height: 32),

                              // Form fields
                              _buildNameField(),
                              const SizedBox(height: 16),
                              _buildEmailField(),
                              const SizedBox(height: 16),
                              _buildPasswordField(),
                              const SizedBox(height: 16),
                              _buildConfirmPasswordField(),

                              const SizedBox(height: 32),

                              // Register button
                              _buildRegisterButton(),

                              const Spacer(),

                              // Login link
                              _buildLoginLink(),

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
          'Create account',
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your transformation journey',
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textPrimary,
          ),
          cursorColor: AppColors.primaryColor,
          decoration: _inputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
          ),
          validator: controller.validateName,
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
            textInputAction: TextInputAction.next,
            style: QuestionnaireTheme.bodyLarge(
              color: QuestionnaireTheme.textPrimary,
            ),
            cursorColor: AppColors.primaryColor,
            decoration: _inputDecoration(
              hintText: 'Create a password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: GestureDetector(
                onTap: () => controller.obscurePassword.value = !controller.obscurePassword.value,
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

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirmPassword.value,
            textInputAction: TextInputAction.done,
            style: QuestionnaireTheme.bodyLarge(
              color: QuestionnaireTheme.textPrimary,
            ),
            cursorColor: AppColors.primaryColor,
            decoration: _inputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: GestureDetector(
                onTap: () => controller.obscureConfirmPassword.value = !controller.obscureConfirmPassword.value,
                child: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: QuestionnaireTheme.textTertiary,
                  size: 20,
                ),
              ),
            ),
            validator: controller.validateConfirmPassword,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_formKey.currentState!.validate()) {
          controller.registerRequest(_formKey);
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
            'Create Account',
            style: QuestionnaireTheme.titleMedium(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Get.off(() => LoginScreen()),
          child: Text(
            'Sign In',
            style: QuestionnaireTheme.bodyMedium(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
