import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';

/// A premium styled widget to display when there's no internet connection
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool isCompact;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactVersion();
    }
    return _buildFullVersion();
  }

  Widget _buildFullVersion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuestionnaireTheme.cardBackground,
                    border: Border.all(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 36,
                    color: QuestionnaireTheme.accentGold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'No Connection',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: QuestionnaireTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Please check your internet connection\nand try again',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: QuestionnaireTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Retry button
            if (onRetry != null)
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: QuestionnaireTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: QuestionnaireTheme.backgroundPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: QuestionnaireTheme.backgroundPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactVersion() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 24,
              color: QuestionnaireTheme.accentGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Connection',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: QuestionnaireTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Check your internet and try again',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A widget that shows content or no internet placeholder based on connection status
class ConnectionAwareWidget extends StatelessWidget {
  final bool hasConnection;
  final bool hasData;
  final Widget child;
  final VoidCallback? onRetry;
  final bool useCompactPlaceholder;

  const ConnectionAwareWidget({
    super.key,
    required this.hasConnection,
    required this.hasData,
    required this.child,
    this.onRetry,
    this.useCompactPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasConnection && !hasData) {
      return NoInternetWidget(
        onRetry: onRetry,
        isCompact: useCompactPlaceholder,
      );
    }
    return child;
  }
}

/// Empty state widget for when data hasn't loaded
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: QuestionnaireTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: QuestionnaireTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: QuestionnaireTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
