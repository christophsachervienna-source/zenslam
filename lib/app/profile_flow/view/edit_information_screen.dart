import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import 'account_information_screen.dart';

class EditInformationScreen extends StatefulWidget {
  const EditInformationScreen({super.key});

  @override
  State<EditInformationScreen> createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  final ProfileController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // Validation state
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _validateAllFields() {
    setState(() {
      _nameError = _validateName(nameController.text);
      _emailError = _validateEmail(emailController.text);
      _passwordError = _validatePassword(passController.text);
    });
  }

  bool get _isFormValid =>
      _nameError == null && _emailError == null && _passwordError == null;

  @override
  void initState() {
    super.initState();
    nameController.text = controller.fullName.value;
    emailController.text = controller.email.value;
    passController.text = controller.password.value;

    // Add listeners for real-time validation
    nameController.addListener(() {
      if (_nameError != null) {
        setState(() => _nameError = _validateName(nameController.text));
      }
    });
    emailController.addListener(() {
      if (_emailError != null) {
        setState(() => _emailError = _validateEmail(emailController.text));
      }
    });
    passController.addListener(() {
      if (_passwordError != null) {
        setState(() => _passwordError = _validatePassword(passController.text));
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Premium header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Edit Information',
                      style: QuestionnaireTheme.headline(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar with gold ring and edit button
                    _buildAvatarSection(),
                    const SizedBox(height: 32),

                    // Form fields in card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: QuestionnaireTheme.cardGradient(),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPremiumTextField(
                            label: "Full Name",
                            controller: nameController,
                            icon: Icons.person_outline_rounded,
                            errorText: _nameError,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 20),
                          _buildPremiumTextField(
                            label: "Email",
                            controller: emailController,
                            icon: Icons.email_outlined,
                            errorText: _emailError,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    _buildSaveButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar with gold ring
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.6),
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
          child: Container(
            width: 110,
            height: 110,
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
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Zenslam Avatar",
          style: QuestionnaireTheme.bodySmall(
            color: QuestionnaireTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: QuestionnaireTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: QuestionnaireTheme.bodySmall(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: QuestionnaireTheme.titleMedium(),
          decoration: InputDecoration(
            filled: true,
            fillColor: QuestionnaireTheme.backgroundSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : QuestionnaireTheme.borderDefault,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : QuestionnaireTheme.borderDefault,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: hasError
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                  )
                : null,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: QuestionnaireTheme.bodySmall(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final hasError = _passwordError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: QuestionnaireTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Password",
              style: QuestionnaireTheme.bodySmall(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => TextFormField(
            controller: passController,
            obscureText: controller.obscurePassword.value,
            style: QuestionnaireTheme.titleMedium(),
            decoration: InputDecoration(
              filled: true,
              fillColor: QuestionnaireTheme.backgroundSecondary,
              hintText: "Enter your password",
              hintStyle: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? Colors.red
                      : QuestionnaireTheme.borderDefault,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? Colors.red
                      : QuestionnaireTheme.borderDefault,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: GestureDetector(
                onTap: controller.togglePassword,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: QuestionnaireTheme.textTertiary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _passwordError!,
              style: QuestionnaireTheme.bodySmall(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return GestureDetector(
        onTap: isLoading
            ? null
            : () async {
                _validateAllFields();
                if (!_isFormValid) return;

                final success = await controller.updateUserProfileViaApi(
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passController.text,
                );

                if (success) {
                  Get.off(() => const AccountInformationScreen());
                }
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [
                      AppColors.primaryColor.withValues(alpha: 0.5),
                      AppColors.primaryColor.withValues(alpha: 0.4),
                    ]
                  : [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.85),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : Text(
                    "Save Changes",
                    style: QuestionnaireTheme.titleMedium(
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
