import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/explore/view/widget/premium_content_card.dart';
import 'package:zenslam/app/explore/view/widget/section_header.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Recently played section with horizontal scroll
class RecentlyPlayedSection extends StatelessWidget {
  final RxList<ExploreItem> recentlyPlayed;
  final Function(ExploreItem item) onItemTap;
  final VoidCallback? onSeeAllPressed;

  const RecentlyPlayedSection({
    super.key,
    required this.recentlyPlayed,
    required this.onItemTap,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (recentlyPlayed.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recently Played',
            onSeeAllPressed: onSeeAllPressed,
            showSeeAll: recentlyPlayed.length > 5,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recentlyPlayed.length.clamp(0, 10),
              itemBuilder: (context, index) {
                final item = recentlyPlayed[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < recentlyPlayed.length - 1 ? 16 : 0,
                  ),
                  child: CompactContentCard(
                    item: item,
                    onTap: () => onItemTap(item),
                    width: 140,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

/// Empty state for recently played when no history
class RecentlyPlayedEmptyState extends StatelessWidget {
  const RecentlyPlayedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.headphones,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Your Journey',
                  style: QuestionnaireTheme.titleMedium(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your recently played content will appear here',
                  style: QuestionnaireTheme.bodySmall(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
