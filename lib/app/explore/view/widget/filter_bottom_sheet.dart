import 'dart:ui';

import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';

/// Sort options enum
enum SortOption {
  popular('Popular'),
  newest('Newest');

  final String label;
  const SortOption(this.label);
}

/// Premium filter bottom sheet with glassmorphism
class FilterBottomSheet extends StatefulWidget {
  final int initialSortIndex;
  final Function(int sortIndex) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialSortIndex = 0,
    required this.onApply,
  });

  static void show({
    required BuildContext context,
    int initialSortIndex = 0,
    required Function(int sortIndex) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialSortIndex: initialSortIndex,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int _selectedSortIndex;

  @override
  void initState() {
    super.initState();
    _selectedSortIndex = widget.initialSortIndex;
  }

  void _reset() {
    setState(() {
      _selectedSortIndex = 0;
    });
  }

  void _apply() {
    widget.onApply(_selectedSortIndex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QuestionnaireTheme.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: QuestionnaireTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort By',
                      style: QuestionnaireTheme.headline(),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: QuestionnaireTheme.cardBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: QuestionnaireTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Sort section
              _buildSortSection(),
              const SizedBox(height: 32),
              // Action buttons
              _buildActionButtons(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: SortOption.values.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedSortIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSortIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index < SortOption.values.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.2),
                            AppColors.primaryColor.withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                  color: isSelected ? null : QuestionnaireTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : QuestionnaireTheme.borderDefault,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
                      style: QuestionnaireTheme.bodyMedium(
                        color: isSelected
                            ? AppColors.primaryColor
                            : QuestionnaireTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Reset button
          Expanded(
            child: GestureDetector(
              onTap: _reset,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: QuestionnaireTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: QuestionnaireTheme.borderDefault,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Reset',
                    style: QuestionnaireTheme.label(
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Apply button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _apply,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: QuestionnaireTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Apply Filters',
                    style: QuestionnaireTheme.label(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
