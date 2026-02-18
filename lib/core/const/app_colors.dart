import 'package:flutter/material.dart';

/// Centralized color definitions for Zenslam app
/// Tennis-inspired palette: deep navy, court blue, white, tennis ball yellow
class AppColors {
  // Primary brand colors — deep navy to court blue
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1A3A5C);

  // Accent — tennis ball yellow/green
  static const Color accentYellow = Color(0xFFC8E020);
  static const Color accentYellowDark = Color(0xFFA8C000);

  // Background colors — deep navy tones
  static const Color scaffoldBgColor = Color(0xFF0D1B2A);
  static const Color bgPrimary = Color(0xFF0D1B2A);
  static const Color bgCard = Color(0xFF1B2D44);
  static const Color bgDark = Color(0xFF0D1B2A);
  static const Color bgDialog = Color(0xFF1B2D44);
  static const Color bgInput = Color(0xFF1B2D44);

  // Text colors
  static const Color textWhite = Colors.white;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0C4DE);
  static const Color textMuted = Color(0xFF6B8CAE);
  static const Color textGrey = Color(0xFFB0C4DE);
  static const Color textGrey2 = Color(0xFF8BA4C4);
  static const Color textGrey3 = Color(0xFF6B8CAE);
  static const Color textBlack = Colors.black;
  static const Color textColor = Color(0xFFB0C4DE);
  static const Color titleTextColor = Color(0xFF3B82F6);
  static const Color textTtileColor = Color(0xFFFFFFFF);

  // UI element colors
  static const Color white = Colors.white;
  static const Color appColor = Color(0xFF1A3A5C);
  static const Color hintText = Color(0xFF6B8CAE);
  static const Color grey = Color(0xFF6B8CAE);
  static const Color textPrimaryColor = Color(0xFF3B82F6);
  static const Color questionBorder = Color(0xFF2563EB);
  static const Color containerBg = Color(0xFF1B2D44);
  static Color containerBacground = const Color(0xFF1B2D44);
  static Color borderColor = const Color(0xFF2563EB).withValues(alpha: 0.25);
  static const Color inputBorder = Color(0xFF3B5068);

  // Feedback colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color buttonColor = Color(0xFF2563EB);
  static const Color red = Color(0xFFF20707);
  static const Color errorRed = Color(0xFFF20707);
  static const Color pink = Color(0xFFF72585);
  static const Color starYellow = Color(0xFFC8E020);

  // Other colors
  static const Color greyBack = Color(0xFF1B2D44);
  static const Color greyTextPoint = Color(0xFF6B8CAE);
  static const Color litePrimaryColor = Color(0xFF1B2D44);

  // Warm white for improved readability on dark backgrounds
  static const Color textWarm = Color(0xFFF5F0EB);
}
