import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/mentor_flow/controller/mentor_controller.dart';
import 'package:zenslam/app/notification_flow/view/message_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MentorScreen extends StatelessWidget {
  MentorScreen({super.key});
  final ChatController controller = Get.put(ChatController());
  final ProfileController profileController = Get.find<ProfileController>();
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: QuestionnaireTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      // Animated glow icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.25),
                              AppColors.primaryColor.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 32,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Title
                      Text(
                        'AI TENNIS COACH',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: QuestionnaireTheme.textPrimary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your personal mental game advisor.\nAsk anything about tennis psychology.',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: QuestionnaireTheme.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Feature cards
                      _buildFeatureCard(
                        icon: Icons.psychology_rounded,
                        title: 'Mental Training',
                        description: 'Get personalized strategies for focus, confidence, and composure',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.sports_tennis_rounded,
                        title: 'Match Preparation',
                        description: 'Build pre-match routines and visualization techniques',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Performance Analysis',
                        description: 'Identify mental patterns and overcome pressure situations',
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // CTA Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Obx(
                  () {
                    final isLoggedIn = controller.isLoggedIn.value;
                    final hasSubscription = profileController.activeSubscription.value;

                    String buttonText;
                    IconData buttonIcon;

                    if (!isLoggedIn) {
                      buttonText = "Sign In to Start";
                      buttonIcon = Icons.login_rounded;
                    } else if (!hasSubscription) {
                      buttonText = "Unlock AI Coach";
                      buttonIcon = Icons.workspace_premium_rounded;
                    } else {
                      buttonText = "Start Conversation";
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
                            color: AppColors.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
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
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  buttonText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: QuestionnaireTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: QuestionnaireTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
