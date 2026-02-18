import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:get/get.dart';

void showFullAccessBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1F),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Lock icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Premium Content',
              style: globalTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Unlock this content and all premium features with a Zenslam subscription.',
              textAlign: TextAlign.center,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
                lineHeight: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            // Features list
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildFeatureRow(Icons.all_inclusive, 'Unlimited access to all content'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.download_outlined, 'Download for offline listening'),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.star_outline, 'Exclusive premium meditations'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CTA Button
            CustomButton(
              title: "Get Full Access",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => SubscriptionScreenV2());
              },
            ),

            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe Later',
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      );
    },
  );
}

Widget _buildFeatureRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: AppColors.primaryColor, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ),
    ],
  );
}
