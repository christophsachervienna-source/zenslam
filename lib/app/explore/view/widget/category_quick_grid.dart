import 'dart:ui';

import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';

/// Category data model
class CategoryItem {
  final String name;
  final IconData icon;
  final int index;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.index,
  });
}

/// Premium category quick grid for browsing
class CategoryQuickGrid extends StatelessWidget {
  final Function(int categoryIndex) onCategorySelected;
  final List<String> categories;

  const CategoryQuickGrid({
    super.key,
    required this.onCategorySelected,
    required this.categories,
  });

  // Map category names to icons
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'confidence':
        return Icons.emoji_events;
      case 'purpose':
        return Icons.explore;
      case 'focus':
        return Icons.center_focus_strong;
      case 'discipline':
        return Icons.schedule;
      case 'friendship':
        return Icons.people;
      case 'dating':
        return Icons.favorite;
      case 'manhood':
        return Icons.person;
      case 'relationship':
        return Icons.favorite_border;
      case 'others':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Take first 8 categories for the grid
    final displayCategories = categories.take(8).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final category = displayCategories[index];
              return _CategoryGridItem(
                category: category,
                icon: _getCategoryIcon(category),
                onTap: () => onCategorySelected(index),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryGridItem extends StatefulWidget {
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CategoryGridItem> createState() => _CategoryGridItemState();
}

class _CategoryGridItemState extends State<_CategoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          AppColors.primaryColor.withValues(alpha: 0.4),
                          AppColors.primaryColor.withValues(alpha: 0.2),
                        ]
                      : [
                          QuestionnaireTheme.cardBackground,
                          QuestionnaireTheme.backgroundSecondary,
                        ],
                ),
                border: Border.all(
                  color: _isPressed
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withValues(alpha: 0.3),
                  width: _isPressed ? 1.5 : 1,
                ),
                boxShadow: [
                  if (_isPressed)
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: _isPressed
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Category name
            Text(
              widget.category,
              style: QuestionnaireTheme.caption(
                color: _isPressed
                    ? AppColors.primaryColor
                    : QuestionnaireTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
