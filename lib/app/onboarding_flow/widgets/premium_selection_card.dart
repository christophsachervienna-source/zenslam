import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/questionnaire_theme.dart';

/// Premium animated selection card for questionnaire options
/// Features: Glass morphism, scale animations, gold accent glow
class PremiumSelectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final String? imageUrl;
  final bool isSelected;
  final bool allowMultiple;
  final VoidCallback onTap;
  final int index;

  const PremiumSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.imageUrl,
    required this.isSelected,
    this.allowMultiple = true,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<PremiumSelectionCard> createState() => _PremiumSelectionCardState();
}

class _PremiumSelectionCardState extends State<PremiumSelectionCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _checkController;
  late AnimationController _entryController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _entryAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Glow animation for selected state
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _entryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Stagger entry animation based on index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entryController.forward();
    });

    if (widget.isSelected) {
      _glowController.value = 1.0;
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PremiumSelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.forward();
        _checkController.forward();
      } else {
        _glowController.reverse();
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _checkController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _glowAnimation,
        _entryAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _entryAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: _handleTap,
                child: AnimatedContainer(
                  duration: QuestionnaireTheme.animationMedium,
                  curve: QuestionnaireTheme.animationCurve,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      QuestionnaireTheme.radiusLG,
                    ),
                    gradient: QuestionnaireTheme.cardGradient(
                      isSelected: widget.isSelected,
                    ),
                    border: Border.all(
                      color: widget.isSelected
                          ? QuestionnaireTheme.borderSelected.withValues(
                              alpha: 0.6 + (_glowAnimation.value * 0.4),
                            )
                          : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                      width: widget.isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      if (widget.isSelected)
                        BoxShadow(
                          color: QuestionnaireTheme.accentGold.withValues(
                            alpha: 0.12 * _glowAnimation.value,
                          ),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      QuestionnaireTheme.radiusLG,
                    ),
                    child: Stack(
                      children: [
                        // Subtle gradient overlay when selected
                        if (widget.isSelected)
                          Positioned.fill(
                            child: AnimatedOpacity(
                              duration: QuestionnaireTheme.animationMedium,
                              opacity: _glowAnimation.value * 0.3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      QuestionnaireTheme.accentGold
                                          .withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Main content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              // Icon/Emoji container
                              _buildLeadingIcon(),
                              const SizedBox(width: 16),

                              // Title and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration:
                                          QuestionnaireTheme.animationMedium,
                                      style:
                                          QuestionnaireTheme.titleMedium(
                                            color: widget.isSelected
                                                ? QuestionnaireTheme.textPrimary
                                                : QuestionnaireTheme.textPrimary
                                                    .withValues(alpha: 0.9),
                                          ),
                                      child: Text(widget.title),
                                    ),
                                    if (widget.subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            QuestionnaireTheme.animationMedium,
                                        style:
                                            QuestionnaireTheme.bodySmall(
                                              color: widget.isSelected
                                                  ? QuestionnaireTheme
                                                      .textSecondary
                                                  : QuestionnaireTheme
                                                      .textTertiary,
                                            ),
                                        child: Text(widget.subtitle!),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Selection indicator
                              _buildSelectionIndicator(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadingIcon() {
    // If emoji is provided
    if (widget.emoji != null && widget.emoji!.isNotEmpty) {
      final isUrl = widget.emoji!.startsWith('http');
      if (isUrl) {
        return AnimatedContainer(
          duration: QuestionnaireTheme.animationMedium,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
            color: widget.isSelected
                ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
                : QuestionnaireTheme.backgroundSecondary,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
            child: Image.network(
              widget.emoji!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_outlined,
                  color: QuestionnaireTheme.textTertiary,
                  size: 24,
                );
              },
            ),
          ),
        );
      }

      // It's an emoji character
      return AnimatedContainer(
        duration: QuestionnaireTheme.animationMedium,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
          color: widget.isSelected
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.12)
              : QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
        ),
        child: Center(
          child: Text(
            widget.emoji!,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    // If image URL is provided
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return AnimatedContainer(
        duration: QuestionnaireTheme.animationMedium,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
          color: widget.isSelected
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.15)
              : QuestionnaireTheme.backgroundSecondary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
          child: Image.network(
            widget.imageUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_outlined,
                color: QuestionnaireTheme.textTertiary,
                size: 24,
              );
            },
          ),
        ),
      );
    }

    // Default icon placeholder
    return AnimatedContainer(
      duration: QuestionnaireTheme.animationMedium,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
        color: widget.isSelected
            ? QuestionnaireTheme.accentGold.withValues(alpha: 0.12)
            : QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          color: widget.isSelected
              ? QuestionnaireTheme.accentGold
              : QuestionnaireTheme.textTertiary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: QuestionnaireTheme.animationMedium,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: widget.allowMultiple ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: widget.allowMultiple
                ? BorderRadius.circular(6)
                : null,
            color: widget.isSelected
                ? QuestionnaireTheme.accentGold
                : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.textTertiary.withValues(alpha: 0.4),
              width: widget.isSelected ? 0 : 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: widget.isSelected
              ? Transform.scale(
                  scale: _checkAnimation.value,
                  child: Icon(
                    widget.allowMultiple ? Icons.check_rounded : Icons.circle,
                    color: QuestionnaireTheme.backgroundPrimary,
                    size: widget.allowMultiple ? 18 : 10,
                  ),
                )
              : null,
        );
      },
    );
  }
}
