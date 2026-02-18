import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/questionnaire_theme.dart';

/// A premium glass morphism card widget with blur effect and subtle borders
/// Used throughout the premium onboarding flow for elegant content containers
class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showBorder;
  final Color? borderColor;
  final double blurAmount;
  final double opacity;
  final Gradient? gradient;

  const GlassMorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.showBorder = true,
    this.borderColor,
    this.blurAmount = 10.0,
    this.opacity = 0.1,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha:opacity + 0.05),
                      Colors.white.withValues(alpha:opacity),
                    ],
                  ),
              border: showBorder
                  ? Border.all(
                      color: borderColor ??
                          QuestionnaireTheme.accentGold.withValues(alpha:0.2),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A variant of GlassMorphismCard with gold accent glow
class GoldGlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isHighlighted;

  const GoldGlowCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  QuestionnaireTheme.cardBackground.withValues(alpha:0.9),
                  QuestionnaireTheme.backgroundSecondary.withValues(alpha:0.85),
                ],
              ),
              border: Border.all(
                color: isHighlighted
                    ? QuestionnaireTheme.accentGold.withValues(alpha:0.5)
                    : QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
                width: isHighlighted ? 1.5 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Simple feature card for displaying value propositions
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: QuestionnaireTheme.cardBackground.withValues(alpha:0.6),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  QuestionnaireTheme.accentGold.withValues(alpha:0.2),
                  QuestionnaireTheme.accentGoldDark.withValues(alpha:0.1),
                ],
              ),
            ),
            child: Icon(
              icon,
              color: QuestionnaireTheme.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: QuestionnaireTheme.titleMedium(),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: QuestionnaireTheme.bodySmall(
                      color: QuestionnaireTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
