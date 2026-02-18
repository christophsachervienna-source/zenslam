import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/questionnaire_theme.dart';
import 'questionnaire_progress.dart';
import 'premium_button.dart';

/// Premium scaffold for questionnaire screens
/// Provides consistent layout, animations, and styling
class QuestionnaireScaffold extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget content;
  final String buttonTitle;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final bool isLoading;
  final bool showBackButton;

  const QuestionnaireScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    required this.content,
    this.buttonTitle = 'Continue',
    this.onContinue,
    this.onBack,
    this.isLoading = false,
    this.showBackButton = true,
  });

  @override
  State<QuestionnaireScaffold> createState() => _QuestionnaireScaffoldState();
}

class _QuestionnaireScaffoldState extends State<QuestionnaireScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button and progress
                _buildHeader(),

                // Main content area
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuestionnaireTheme.paddingHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),

                            // Title
                            Text(
                              widget.title,
                              style: QuestionnaireTheme.displayMedium(),
                            ),

                            // Subtitle
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                widget.subtitle!,
                                style: QuestionnaireTheme.bodyLarge(
                                  color: QuestionnaireTheme.textSecondary,
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            // Scrollable content
                            Expanded(child: widget.content),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom button area
                _buildBottomArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal - 8,
        12,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              if (widget.showBackButton && widget.onBack != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onBack!();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: QuestionnaireTheme.backgroundSecondary
                          .withValues(alpha: 0.6),
                      border: Border.all(
                        color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: QuestionnaireTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                )
              else
                const SizedBox(width: 44),

              // Progress indicator (centered)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuestionnaireProgressDots(
                    currentStep: widget.currentStep,
                    totalSteps: widget.totalSteps,
                  ),
                ),
              ),

              // Placeholder for balance
              const SizedBox(width: 44),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal,
        16,
        QuestionnaireTheme.paddingHorizontal,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.8),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: PremiumButton(
        title: widget.buttonTitle,
        onTap: widget.onContinue,
        isLoading: widget.isLoading,
      ),
    );
  }
}
