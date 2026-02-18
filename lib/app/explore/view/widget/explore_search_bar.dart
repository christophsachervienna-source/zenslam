import 'dart:ui';

import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';

/// Premium glassmorphism search bar with filter button
class ExploreSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final String hintText;
  final bool showFilterIndicator;

  const ExploreSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterPressed,
    this.hintText = 'Search meditations...',
    this.showFilterIndicator = false,
  });

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 52,
      decoration: BoxDecoration(
        color: QuestionnaireTheme.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _isFocused
              ? AppColors.primaryColor.withValues(alpha: 0.5)
              : AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.search,
                  color: _isFocused
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              // Text field
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _isFocused = focused);
                  },
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    style: QuestionnaireTheme.bodyMedium(
                      color: QuestionnaireTheme.textPrimary,
                    ),
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: QuestionnaireTheme.bodyMedium(
                        color: QuestionnaireTheme.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              // Clear button (shows when text is entered)
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: QuestionnaireTheme.textTertiary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              // Divider
              Container(
                height: 28,
                width: 1,
                color: AppColors.primaryColor.withValues(alpha: 0.2),
              ),
              // Filter button with indicator
              GestureDetector(
                onTap: widget.onFilterPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.tune,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                      if (widget.showFilterIndicator)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: QuestionnaireTheme.cardBackground,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned search bar delegate for CustomScrollView
class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final bool showFilterIndicator;

  SearchBarDelegate({
    this.controller,
    this.onChanged,
    this.onFilterPressed,
    this.showFilterIndicator = false,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = 1.0 - (shrinkOffset / maxExtent).clamp(0.0, 0.3);

    return Container(
      color: QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.95),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Opacity(
        opacity: opacity,
        child: ExploreSearchBar(
          controller: controller,
          onChanged: onChanged,
          onFilterPressed: onFilterPressed,
          showFilterIndicator: showFilterIndicator,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 68;

  @override
  double get minExtent => 68;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
