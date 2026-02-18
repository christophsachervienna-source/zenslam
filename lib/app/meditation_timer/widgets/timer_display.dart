import 'dart:math' as math;
import 'package:zenslam/app/meditation_timer/controller/meditation_timer_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Circular timer display with gold progress ring
class TimerDisplay extends StatelessWidget {
  final double size;

  const TimerDisplay({
    super.key,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      final progress = controller.progress;
      final formattedTime = controller.formattedTime;
      final isRunning = controller.isRunning.value;
      final isPaused = controller.isPaused.value;

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold
                        .withValues(alpha: isRunning && !isPaused ? 0.2 : 0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Progress ring background
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(
                progress: 1.0,
                strokeWidth: 6,
                color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
              ),
            ),

            // Progress ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _CircularProgressPainter(
                    progress: value,
                    strokeWidth: 6,
                    color: QuestionnaireTheme.accentGold,
                    hasGlow: isRunning && !isPaused,
                  ),
                );
              },
            ),

            // Inner circle
            Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground.withValues(alpha: 0.5),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),

            // Time display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: GoogleFonts.dmSans(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.w300,
                    color: QuestionnaireTheme.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                if (isRunning && !isPaused)
                  Text(
                    'remaining',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                if (isPaused)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      'PAUSED',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: QuestionnaireTheme.accentGold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Custom painter for circular progress ring
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool hasGlow;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (hasGlow) {
      // Draw glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.hasGlow != hasGlow;
  }
}

/// Compact timer display for the top of the screen during meditation
class CompactTimerDisplay extends StatelessWidget {
  const CompactTimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeditationTimerController>();

    return Obx(() {
      final formattedTime = controller.formattedTime;
      final progress = controller.progress;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: QuestionnaireTheme.cardBackground,
          border: Border.all(
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor:
                    QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  QuestionnaireTheme.accentGold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formattedTime,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: QuestionnaireTheme.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    });
  }
}
