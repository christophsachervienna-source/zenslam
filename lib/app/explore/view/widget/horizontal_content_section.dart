import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/explore/view/widget/premium_content_card.dart';
import 'package:zenslam/app/explore/view/widget/section_header.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Horizontal content section with lazy loading
class HorizontalContentSection extends StatelessWidget {
  final String title;
  final RxList<ExploreItem> items;
  final Function(ExploreItem item) onItemTap;
  final Function(ExploreItem item)? onFavoritePressed;
  final VoidCallback? onSeeAllPressed;
  final VoidCallback? onLoadMore;
  final RxBool? isLoading;
  final bool showSeeAll;
  final double cardWidth;
  final double cardHeight;

  const HorizontalContentSection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.onFavoritePressed,
    this.onSeeAllPressed,
    this.onLoadMore,
    this.isLoading,
    this.showSeeAll = true,
    this.cardWidth = 180,
    this.cardHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (items.isEmpty && (isLoading?.value ?? false)) {
        return _buildLoadingState();
      }

      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            onSeeAllPressed: onSeeAllPressed,
            showSeeAll: showSeeAll && items.length > 3,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 100 &&
                    onLoadMore != null) {
                  onLoadMore!();
                }
                return false;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length + ((isLoading?.value ?? false) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return _buildLoadingCard();
                  }

                  final item = items[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < items.length - 1 ? 16 : 0,
                    ),
                    child: PremiumContentCard(
                      item: item,
                      onTap: () => onItemTap(item),
                      onFavoritePressed: onFavoritePressed != null
                          ? () => onFavoritePressed!(item)
                          : null,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          showSeeAll: false,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
                child: _buildShimmerCard(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(left: 16),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primaryColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBar(width: cardWidth * 0.7, height: 14),
                const SizedBox(height: 8),
                _buildShimmerBar(width: cardWidth * 0.5, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: QuestionnaireTheme.textTertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Featured content section with larger cards
class FeaturedContentSection extends StatelessWidget {
  final RxList<ExploreItem> items;
  final Function(ExploreItem item) onItemTap;
  final Function(ExploreItem item)? onFavoritePressed;

  const FeaturedContentSection({
    super.key,
    required this.items,
    required this.onItemTap,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalContentSection(
      title: 'Featured',
      items: items,
      onItemTap: onItemTap,
      onFavoritePressed: onFavoritePressed,
      showSeeAll: false,
      cardWidth: 240,
      cardHeight: 280,
    );
  }
}

/// Popular content section
class PopularContentSection extends StatelessWidget {
  final String categoryName;
  final RxList<ExploreItem> items;
  final Function(ExploreItem item) onItemTap;
  final Function(ExploreItem item)? onFavoritePressed;
  final VoidCallback? onSeeAllPressed;

  const PopularContentSection({
    super.key,
    required this.categoryName,
    required this.items,
    required this.onItemTap,
    this.onFavoritePressed,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalContentSection(
      title: 'Popular in $categoryName',
      items: items,
      onItemTap: onItemTap,
      onFavoritePressed: onFavoritePressed,
      onSeeAllPressed: onSeeAllPressed,
    );
  }
}
