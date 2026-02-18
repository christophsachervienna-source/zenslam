import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/nav_controller.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/mentor_flow/view/notification_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/app/profile_flow/view/account_information_screen.dart';
import 'package:zenslam/app/profile_flow/view/download_screen.dart';
import 'package:zenslam/app/profile_flow/view/prefarance_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/view/privacy_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Premium header - matching Explore page style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final navController = Get.find<NavController>();
                          navController.changeTab(0);
                        },
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
                        'Profile',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.loadProfile();
                    },
                    color: AppColors.primaryColor,
                    backgroundColor: Colors.transparent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          // Profile card with premium styling
                          _buildProfileCard(controller),

                          const SizedBox(height: 24),

                          // Menu section with premium styling
                          _buildMenuSection(),

                          const SizedBox(height: 20),

                          // Debug premium toggle (debug builds only)
                          if (kDebugMode) _buildDebugPremiumToggle(controller),

                          if (kDebugMode) const SizedBox(height: 20),

                          // Login/Logout button
                          _buildAuthButton(controller),

                          const SizedBox(height: 120), // Space for mini player
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gold ring
          Container(
            padding: const EdgeInsets.all(3),
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
            ),
            child: Obx(() {
              final userName = controller.fullName.value;
              final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';

              return Container(
                width: 56,
                height: 56,
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
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 16),
          // Name and email
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.fullName.value.isNotEmpty
                        ? controller.fullName.value
                        : "Guest User",
                    style: QuestionnaireTheme.titleLarge(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.email.value.isNotEmpty
                        ? controller.email.value
                        : "Not logged in",
                    style: QuestionnaireTheme.bodyMedium(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            text: "Account Information",
            onTap: () => Get.to(() => const AccountInformationScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.tune_rounded,
            text: "Preferences",
            onTap: () => Get.to(() => const PrefaranceScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.download_rounded,
            text: "Downloads",
            onTap: () => Get.to(() => DownloadScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.workspace_premium_rounded,
            text: "Premium",
            onTap: () => Get.to(() => const SubscriptionScreenV2()),
            isPremium: true,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            text: "Notifications",
            onTap: () => Get.to(() => const NotificationScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            text: "Privacy Policy",
            onTap: () => Get.to(() => PrivacyPolicy()),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPremium
                      ? AppColors.primaryColor.withValues(alpha: 0.15)
                      : QuestionnaireTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isPremium
                      ? AppColors.primaryColor
                      : QuestionnaireTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: QuestionnaireTheme.titleMedium(
                    color: isPremium ? AppColors.primaryColor : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isPremium
                    ? AppColors.primaryColor
                    : QuestionnaireTheme.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: QuestionnaireTheme.borderDefault,
      ),
    );
  }

  Widget _buildDebugPremiumToggle(ProfileController controller) {
    return Obx(() {
      final isPremium = controller.activeSubscription.value;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: QuestionnaireTheme.cardGradient(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.orange.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.activeSubscription.value = !isPremium;
              controller.isTrialExpired.value = isPremium;
              Get.snackbar(
                'Debug',
                isPremium ? 'Premium DISABLED' : 'Premium ENABLED',
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPremium ? Icons.star : Icons.star_border,
                      color: isPremium ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEBUG: Premium ${isPremium ? "ON" : "OFF"}',
                          style: QuestionnaireTheme.titleMedium(
                            color: isPremium ? Colors.green : Colors.orange,
                          ),
                        ),
                        Text(
                          'Tap to toggle premium access',
                          style: QuestionnaireTheme.bodySmall(
                            color: QuestionnaireTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isPremium,
                    onChanged: (val) {
                      controller.activeSubscription.value = val;
                      controller.isTrialExpired.value = !val;
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAuthButton(ProfileController controller) {
    return Obx(
      () => controller.isLoggedIn.value
          ? _buildLogoutButton()
          : _buildLoginButton(),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestionnaireTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: QuestionnaireTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: QuestionnaireTheme.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  "Log Out",
                  style: QuestionnaireTheme.titleMedium(
                    color: QuestionnaireTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.2),
            AppColors.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.offAll(() => LoginScreen()),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign In",
                        style: QuestionnaireTheme.titleMedium(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        "Experience the full Zenslam journey",
                        style: QuestionnaireTheme.bodySmall(
                          color: QuestionnaireTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: QuestionnaireTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: QuestionnaireTheme.borderDefault,
            width: 1,
          ),
        ),
        title: Text(
          "Log Out",
          style: QuestionnaireTheme.titleLarge(),
        ),
        content: Text(
          "Are you sure you want to log out of your account?",
          style: QuestionnaireTheme.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Cancel",
              style: QuestionnaireTheme.titleMedium(
                color: QuestionnaireTheme.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: QuestionnaireTheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () async {
                Get.back();

                // Show loading indicator
                Get.dialog(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: QuestionnaireTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          QuestionnaireTheme.error,
                        ),
                      ),
                    ),
                  ),
                  barrierDismissible: false,
                );

                await SharedPrefHelper.clearTokens();
                await Future.delayed(const Duration(milliseconds: 500));

                Get.back();
                Get.offAll(() => LoginScreen());
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Log Out",
                style: QuestionnaireTheme.titleMedium(
                  color: QuestionnaireTheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
