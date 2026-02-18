import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/questionnaire_theme.dart';

/// Premium animated button for questionnaire actions
/// Features: Gradient fill, press animation, subtle glow
class PremiumButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final bool showArrow;

  const PremiumButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.showArrow = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onTap == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: QuestionnaireTheme.animationMedium,
              curve: QuestionnaireTheme.animationCurve,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isDisabled
                    ? LinearGradient(
                        colors: [
                          QuestionnaireTheme.borderDefault,
                          QuestionnaireTheme.borderDefault.withValues(alpha: 0.8),
                        ],
                      )
                    : QuestionnaireTheme.accentGradient,
                boxShadow: isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: QuestionnaireTheme.accentGold
                              .withValues(alpha: _isPressed ? 0.5 : 0.35),
                          blurRadius: _isPressed ? 20 : 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // Subtle shine overlay
                  if (!isDisabled)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Button content
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                QuestionnaireTheme.backgroundPrimary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: isDisabled
                                      ? QuestionnaireTheme.textTertiary
                                      : QuestionnaireTheme.backgroundPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                              ],
                              Text(
                                widget.title,
                                style: QuestionnaireTheme.label(
                                  color: isDisabled
                                      ? QuestionnaireTheme.textTertiary
                                      : QuestionnaireTheme.backgroundPrimary,
                                ),
                              ),
                              if (widget.showArrow && !isDisabled) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: QuestionnaireTheme.backgroundPrimary,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Secondary/outline button style
class PremiumOutlineButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final IconData? icon;

  const PremiumOutlineButton({
    super.key,
    required this.title,
    this.onTap,
    this.icon,
  });

  @override
  State<PremiumOutlineButton> createState() => _PremiumOutlineButtonState();
}

class _PremiumOutlineButtonState extends State<PremiumOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      child: AnimatedContainer(
        duration: QuestionnaireTheme.animationFast,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _isPressed
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: QuestionnaireTheme.accentGold,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.title,
                style: QuestionnaireTheme.label(
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
