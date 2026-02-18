import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';

/// Base shimmer loader widget
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: QuestionnaireTheme.cardBackground,
      highlightColor: QuestionnaireTheme.backgroundSecondary,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: QuestionnaireTheme.cardBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Card skeleton loader
class CardSkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;

  const CardSkeletonLoader({
    super.key,
    this.width,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

/// List item skeleton loader
class ListItemSkeletonLoader extends StatelessWidget {
  const ListItemSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: QuestionnaireTheme.cardBackground,
      highlightColor: QuestionnaireTheme.backgroundSecondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: QuestionnaireTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: QuestionnaireTheme.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: QuestionnaireTheme.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list skeleton loader
class HorizontalListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const HorizontalListSkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.itemWidth = 140,
    this.itemHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SkeletonLoader(
          width: itemWidth,
          height: itemHeight,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Grid skeleton loader
class GridSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const GridSkeletonLoader({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonLoader(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Home screen skeleton loader
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CardSkeletonLoader(height: 200),
          ),
          const SizedBox(height: 24),

          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoader(
              width: 150,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal list
          const HorizontalListSkeletonLoader(),
          const SizedBox(height: 24),

          // Another section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoader(
              width: 120,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          const HorizontalListSkeletonLoader(
            itemWidth: 160,
            itemHeight: 200,
          ),
        ],
      ),
    );
  }
}
