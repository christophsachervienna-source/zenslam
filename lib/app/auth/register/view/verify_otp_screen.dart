import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/auth/register/controller/register_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class RegVerifyOtpScreen extends StatelessWidget {
  RegVerifyOtpScreen({super.key});

  final RegisterController controller = Get.put(RegisterController());

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  _buildBackButton(),

                  const SizedBox(height: 40),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: 48),

                  // PIN Input
                  _buildPinInput(),

                  const SizedBox(height: 40),

                  // Resend code section
                  _buildResendSection(),

                  const Spacer(),

                  // Verify button
                  _buildVerifyButton(),

                  const SizedBox(height: 40),
                ],
              ),
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
        Text(
          'Verify account',
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'The code has been sent to ',
            style: QuestionnaireTheme.bodyLarge(
              color: QuestionnaireTheme.textSecondary,
            ),
            children: [
              TextSpan(
                text: controller.emailController.text,
                style: QuestionnaireTheme.bodyLarge(
                  color: QuestionnaireTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the code to verify your account.',
          style: QuestionnaireTheme.bodyMedium(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: QuestionnaireTheme.displayMedium(),
      decoration: BoxDecoration(
        color: QuestionnaireTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.primaryColor.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.primaryColor,
      ),
    );

    return Center(
      child: Pinput(
        length: 4,
        controller: controller.otpController,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
        showCursor: true,
        pinAnimationType: PinAnimationType.fade,
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
            Obx(
              () => controller.remainingSeconds.value > 0
                  ? Text(
                      'Resend Code',
                      style: QuestionnaireTheme.bodyMedium(
                        color: QuestionnaireTheme.textTertiary,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.sendResetCode();
                      },
                      child: Text(
                        'Resend Code',
                        style: QuestionnaireTheme.bodyMedium(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => controller.remainingSeconds.value > 0
              ? Text(
                  'Resend code in ${controller.formattedRemainingTime}',
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textTertiary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        controller.verify();
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
            'Verify OTP',
            style: QuestionnaireTheme.titleMedium(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
