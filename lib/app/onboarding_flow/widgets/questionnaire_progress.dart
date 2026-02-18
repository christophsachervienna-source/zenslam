import 'package:flutter/material.dart';
import '../theme/questionnaire_theme.dart';

/// Premium progress indicator for questionnaire flow
/// Features: Segmented bar with animated fills and step labels
class QuestionnaireProgress extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const QuestionnaireProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  State<QuestionnaireProgress> createState() => _QuestionnaireProgressState();
}

class _QuestionnaireProgressState extends State<QuestionnaireProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _updateProgress();
  }

  @override
  void didUpdateWidget(QuestionnaireProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress = (widget.currentStep) / widget.totalSteps;
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _previousProgress = newProgress;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step counter text
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${widget.currentStep} OF ${widget.totalSteps}',
                style: QuestionnaireTheme.caption(
                  color: QuestionnaireTheme.textTertiary,
                ),
              ),
              Text(
                '${((widget.currentStep / widget.totalSteps) * 100).toInt()}%',
                style: QuestionnaireTheme.caption(
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ],
          ),
        ),

        // Segmented progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Background segments
                      Row(
                        children: List.generate(widget.totalSteps, (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : 2,
                                right: index == widget.totalSteps - 1 ? 0 : 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: QuestionnaireTheme.borderDefault
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        }),
                      ),

                      // Animated progress fill
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                QuestionnaireTheme.accentGoldDark,
                                QuestionnaireTheme.accentGold,
                                QuestionnaireTheme.accentGoldLight,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: QuestionnaireTheme.accentGold
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),

        // Step labels (if provided)
        if (widget.stepLabels != null && widget.stepLabels!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.stepLabels!.length, (index) {
              final isActive = index < widget.currentStep;
              final isCurrent = index == widget.currentStep - 1;
              return Expanded(
                child: Text(
                  widget.stepLabels![index],
                  textAlign: TextAlign.center,
                  style: QuestionnaireTheme.bodySmall(
                    color: isCurrent
                        ? QuestionnaireTheme.accentGold
                        : isActive
                            ? QuestionnaireTheme.textSecondary
                            : QuestionnaireTheme.textTertiary,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Compact dot-style progress indicator
class QuestionnaireProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const QuestionnaireProgressDots({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep - 1;

        return AnimatedContainer(
          duration: QuestionnaireTheme.animationMedium,
          curve: QuestionnaireTheme.animationCurve,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isCompleted || isCurrent
                ? QuestionnaireTheme.accentGold
                : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
