import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicy extends StatelessWidget {
  PrivacyPolicy({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Privacy Policy',
                    style: QuestionnaireTheme.headline(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    AppColors.primaryColor.withValues(alpha: 0.6),
                  ),
                  trackColor: WidgetStateProperty.all(
                    Colors.white.withValues(alpha: 0.05),
                  ),
                  trackBorderColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  thickness: WidgetStateProperty.all(4),
                  radius: const Radius.circular(8),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last updated: January 2026',
                          style: QuestionnaireTheme.bodySmall(
                            color: QuestionnaireTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildSection(
                          title: '1. Introduction',
                          content: 'Welcome to Zenslam. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n\nBy using Zenslam, you agree to the collection and use of information in accordance with this policy.',
                        ),

                        _buildSection(
                          title: '2. Information We Collect',
                          content: 'We collect information that you provide directly to us, including:\n\n• Account Information: Name, email address, and password when you create an account\n• Profile Information: Preferences, goals, and areas of focus you select during onboarding\n• Usage Data: Meditation sessions completed, listening history, and app interactions\n• Device Information: Device type, operating system, and unique device identifiers\n• Payment Information: Billing details processed securely through Apple App Store and Google Play Store',
                        ),

                        _buildSection(
                          title: '3. How We Use Your Information',
                          content: 'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Personalize your experience with tailored content recommendations\n• Process transactions and send related information\n• Send you technical notices, updates, and support messages\n• Respond to your comments, questions, and customer service requests\n• Monitor and analyze trends, usage, and activities\n• Detect, investigate, and prevent fraudulent transactions and unauthorized access',
                        ),

                        _buildSection(
                          title: '4. Data Storage & Security',
                          content: 'We implement appropriate technical and organizational security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction.\n\nYour data is stored on secure servers and encrypted during transmission. We regularly review and update our security practices to ensure your information remains protected.',
                        ),

                        _buildSection(
                          title: '5. Third-Party Services',
                          content: 'We may share your information with third-party service providers who perform services on our behalf, including:\n\n• Cloud hosting and storage providers\n• Payment processors (Apple App Store, Google Play Store)\n• Analytics providers\n• Customer support tools\n\nThese third parties are obligated to protect your information and may only use it for the specific services they provide to us.',
                        ),

                        _buildSection(
                          title: '6. Your Rights & Choices',
                          content: 'You have the right to:\n\n• Access, update, or delete your personal information\n• Opt out of marketing communications\n• Request a copy of your data\n• Withdraw consent at any time\n• Lodge a complaint with a data protection authority\n\nTo exercise these rights, contact us at support@zenslam.com',
                        ),

                        _buildSection(
                          title: '7. Data Retention',
                          content: 'We retain your personal information for as long as your account is active or as needed to provide you services. We will retain and use your information as necessary to comply with our legal obligations, resolve disputes, and enforce our agreements.',
                        ),

                        _buildSection(
                          title: '8. Children\'s Privacy',
                          content: 'Zenslam is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we learn that we have collected personal information from a child under 13, we will delete that information promptly.',
                        ),

                        _buildSection(
                          title: '9. Changes to This Policy',
                          content: 'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.\n\nYour continued use of the app after any changes constitutes your acceptance of the new Privacy Policy.',
                        ),

                        _buildSection(
                          title: '10. Contact Us',
                          content: 'If you have any questions about this Privacy Policy or our privacy practices, please contact us at:\n\nEmail: support@zenslam.com\n\nWe will respond to your inquiry within 30 days.',
                          isLast: true,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: QuestionnaireTheme.titleMedium(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: QuestionnaireTheme.bodyMedium(),
          ),
        ],
      ),
    );
  }
}
