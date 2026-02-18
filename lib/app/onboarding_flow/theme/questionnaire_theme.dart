import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium questionnaire theme for Zenslam onboarding
/// Aesthetic: Tennis-inspired — deep navy, court blue, tennis ball yellow
class QuestionnaireTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - Deep navy tennis aesthetic
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary background - deep navy
  static const Color backgroundPrimary = Color(0xFF0D1B2A);

  /// Secondary background - elevated surface
  static const Color backgroundSecondary = Color(0xFF122438);

  /// Card background - glass effect base
  static const Color cardBackground = Color(0xFF1B2D44);

  /// Card selected background
  static const Color cardSelectedBackground = Color(0xFF1E3A5F);

  /// Accent blue - interactive elements
  static const Color accentGold = AppColors.primaryColor;

  /// Accent blue light - highlight
  static const Color accentGoldLight = Color(0xFF3B82F6);

  /// Accent blue dark - depth
  static const Color accentGoldDark = Color(0xFF1A3A5C);

  /// Text primary - crisp white
  static const Color textPrimary = Color(0xFFFAFAFA);

  /// Text secondary - muted light blue
  static const Color textSecondary = Color(0xFFB0C4DE);

  /// Text tertiary - subtle hint
  static const Color textTertiary = Color(0xFF6B8CAE);

  /// Border default - subtle edge
  static const Color borderDefault = Color(0xFF2A3F55);

  /// Border selected - blue accent
  static const Color borderSelected = AppColors.primaryColor;

  /// Success green
  static const Color success = Color(0xFF4ADE80);

  /// Error red
  static const Color error = Color(0xFFEF4444);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS - Rich depth and atmosphere
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main background gradient - deep navy atmospheric
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF122438),
      Color(0xFF0D1B2A),
      Color(0xFF081420),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Card gradient - glass morphism effect
  static LinearGradient cardGradient({bool isSelected = false}) {
    if (isSelected) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A5F),
          Color(0xFF1B2D44),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1B2D44),
        Color(0xFF122438),
      ],
    );
  }

  /// Blue accent gradient - for buttons and highlights
  static LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      AppColors.primaryColor,
      Color(0xFF1A3A5C),
    ],
  );

  /// Subtle blue glow gradient
  static const RadialGradient goldGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x302563EB),
      Color(0x002563EB),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - Distinctive and refined
  // ═══════════════════════════════════════════════════════════════════════════

  /// Display font - bold for headlines
  static TextStyle displayLarge({Color? color}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  /// Display medium - section headers
  static TextStyle displayMedium({Color? color}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 26,
      fontWeight: FontWeight.w500,
      color: color ?? textPrimary,
      letterSpacing: -0.3,
      height: 1.25,
    );
  }

  /// Headline - question titles
  static TextStyle headline({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: -0.2,
      height: 1.3,
    );
  }

  /// Title large - card titles
  static TextStyle titleLarge({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: 0,
      height: 1.4,
    );
  }

  /// Title medium
  static TextStyle titleMedium({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ?? textPrimary,
      letterSpacing: 0,
      height: 1.4,
    );
  }

  /// Body large - descriptions
  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondary,
      letterSpacing: 0.1,
      height: 1.5,
    );
  }

  /// Body medium
  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondary,
      letterSpacing: 0.1,
      height: 1.5,
    );
  }

  /// Body small - hints
  static TextStyle bodySmall({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? textTertiary,
      letterSpacing: 0.2,
      height: 1.4,
    );
  }

  /// Label - buttons and chips
  static TextStyle label({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: 0.5,
      height: 1.2,
    );
  }

  /// Caption - progress indicators
  static TextStyle caption({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color ?? textTertiary,
      letterSpacing: 1.0,
      height: 1.2,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING - Generous and balanced
  // ═══════════════════════════════════════════════════════════════════════════

  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 20.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Refined curves
  // ═══════════════════════════════════════════════════════════════════════════

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 100.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS - Subtle depth
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> cardShadow({bool isSelected = false}) {
    if (isSelected) {
      return [
        BoxShadow(
          color: accentGold.withValues(alpha: 0.15),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 10,
          spreadRadius: 0,
          offset: Offset(0, 2),
        ),
      ];
    }
    return [
      const BoxShadow(
        color: Color(0x20000000),
        blurRadius: 8,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: accentGold.withValues(alpha: 0.3),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);

  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationCurveIn = Curves.easeInCubic;
  static const Curve animationCurveBounce = Curves.elasticOut;
}
