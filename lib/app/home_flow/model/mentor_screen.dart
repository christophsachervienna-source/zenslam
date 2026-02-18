import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/mentor_flow/controller/mentor_controller.dart';
import 'package:zenslam/app/notification_flow/view/message_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MentorScreen extends StatelessWidget {
  MentorScreen({super.key});
  final ChatController controller = Get.put(ChatController());
  final ProfileController profileController = Get.find<ProfileController>();
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Premium content area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AI Chat logo/icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.2),
                            AppColors.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        IconsPath.aiChat,
                        height: 80,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'AI Mentor',
                      style: QuestionnaireTheme.displayMedium(),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your personal guide to growth, clarity, and purpose',
                        style: QuestionnaireTheme.bodyMedium(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(
                () {
                  final isLoggedIn = controller.isLoggedIn.value;
                  final hasSubscription = profileController.activeSubscription.value;

                  String buttonText;
                  IconData buttonIcon;

                  if (!isLoggedIn) {
                    buttonText = "Login to Chat";
                    buttonIcon = Icons.login_rounded;
                  } else if (!hasSubscription) {
                    buttonText = "Subscribe to Chat";
                    buttonIcon = Icons.workspace_premium_rounded;
                  } else {
                    buttonText = "Start AI Chat";
                    buttonIcon = Icons.chat_rounded;
                  }

                  return Container(
                    width: double.infinity,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: !isLoggedIn
                            ? () => Get.to(() => LoginScreen())
                            : !hasSubscription
                                ? () => Get.to(() => const SubscriptionScreenV2())
                                : () => Get.to(() => AiChatScreen()),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                buttonIcon,
                                color: Colors.black,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                buttonText,
                                style: QuestionnaireTheme.titleMedium(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
