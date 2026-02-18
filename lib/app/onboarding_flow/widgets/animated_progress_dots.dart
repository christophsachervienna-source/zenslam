import 'package:flutter/material.dart';
import '../theme/questionnaire_theme.dart';

/// Animated progress dots for the onboarding carousel
/// Features smooth transitions and gold accent for active step
class AnimatedProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const AnimatedProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.dotSize = 8.0,
    this.activeDotWidth = 24.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isPast = index < currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? activeDotWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dotSize / 2),
            color: isActive
                ? QuestionnaireTheme.accentGold
                : isPast
                    ? QuestionnaireTheme.accentGold.withValues(alpha:0.5)
                    : QuestionnaireTheme.borderDefault.withValues(alpha:0.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha:0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Circular progress indicator with percentage display
class CircularProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double size;

  const CircularProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
              ),
            ),
          ),
          // Progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    QuestionnaireTheme.accentGold,
                  ),
                ),
              );
            },
          ),
          // Center text
          Center(
            child: Text(
              '${currentStep + 1}/$totalSteps',
              style: QuestionnaireTheme.caption(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Line progress indicator for step-by-step flows
class LineProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;

  const LineProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            final isFirst = index == 0;
            final isLast = index == totalSteps - 1;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: height,
                margin: EdgeInsets.only(
                  left: isFirst ? 0 : 2,
                  right: isLast ? 0 : 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: isActive
                      ? QuestionnaireTheme.accentGold
                      : QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                QuestionnaireTheme.accentGold.withValues(alpha:0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
