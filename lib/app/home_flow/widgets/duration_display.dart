import 'package:flutter/material.dart';

class DurationDisplay extends StatelessWidget {
  final String durationString;
  final TextStyle? style;
  final String separator;

  const DurationDisplay({
    super.key,
    required this.durationString,
    this.style,
    this.separator = ' • ',
  });

  // Method to parse duration string
  static Map<String, dynamic> parseDurationDetails(String durationString) {
    try {
      // Split by ':' to handle formats like "1:20", "0:27", "1:57"
      final parts = durationString.split(':');

      if (parts.length >= 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        final totalSeconds = (minutes * 60) + seconds;

        // Calculate rounded minutes for display
        final displayMinutes = _calculateRoundedMinutes(minutes, seconds);
        final displaySeconds = seconds;

        return {
          'minutes': minutes,
          'seconds': seconds,
          'totalSeconds': totalSeconds,
          'displayText': _getDisplayText(minutes, seconds),
          'displayMinutes': displayMinutes,
          'displaySeconds': displaySeconds,
          'originalMinutes': minutes,
          'originalSeconds': seconds,
        };
      } else if (durationString.contains('min')) {
        // Handle if string already has "min" (e.g., "2 min")
        final number = int.tryParse(durationString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return {
          'minutes': number,
          'seconds': 0,
          'totalSeconds': number * 60,
          'displayText': '$number min',
          'displayMinutes': number,
          'displaySeconds': 0,
          'originalMinutes': number,
          'originalSeconds': 0,
        };
      } else if (durationString.contains('sec')) {
        // Handle if string already has "sec" (e.g., "30 sec")
        final number = int.tryParse(durationString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return {
          'minutes': 0,
          'seconds': number,
          'totalSeconds': number,
          'displayText': '$number sec',
          'displayMinutes': 0,
          'displaySeconds': number,
          'originalMinutes': 0,
          'originalSeconds': number,
        };
      } else {
        // Try to parse as a number (assuming minutes)
        final number = int.tryParse(durationString) ?? 0;
        return {
          'minutes': number,
          'seconds': 0,
          'totalSeconds': number * 60,
          'displayText': '$number min',
          'displayMinutes': number,
          'displaySeconds': 0,
          'originalMinutes': number,
          'originalSeconds': 0,
        };
      }
    } catch (e) {
      // Return default if parsing fails
      return {
        'minutes': 0,
        'seconds': 0,
        'totalSeconds': 0,
        'displayText': '0 sec',
        'displayMinutes': 0,
        'displaySeconds': 0,
        'originalMinutes': 0,
        'originalSeconds': 0,
      };
    }
  }

  // Helper method to calculate rounded minutes
  static int _calculateRoundedMinutes(int minutes, int seconds) {
    if (minutes == 0) {
      // Under 1 minute, show seconds
      return 0;
    }

    // For 1 minute or more, apply rounding rules:
    // - seconds < 30: round down (keep minutes as is)
    // - seconds >= 30: round up (add 1 minute)
    return seconds >= 30 ? minutes + 1 : minutes;
  }

  // Helper method to get display text
  static String _getDisplayText(int minutes, int seconds) {
    if (minutes == 0) {
      // Under 1 minute, show seconds
      return '$seconds sec';
    } else {
      // 1 minute or more, apply rounding rules
      final displayMinutes = _calculateRoundedMinutes(minutes, seconds);
      return '$displayMinutes min';
    }
  }

  // Static method that returns formatted display text
  static String parseDuration(String durationString) {
    return parseDurationDetails(durationString)['displayText'] as String;
  }

  // Static method that returns rounded minutes (with proper rounding rules)
  static int getRoundedMinutes(String durationString) {
    final details = parseDurationDetails(durationString);
    final minutes = details['originalMinutes'] as int;
    final seconds = details['originalSeconds'] as int;

    return _calculateRoundedMinutes(minutes, seconds);
  }

  // Static method to get minutes and seconds separately
  static Map<String, int> getMinutesAndSeconds(String durationString) {
    final details = parseDurationDetails(durationString);
    return {
      'minutes': details['originalMinutes'] as int,
      'seconds': details['originalSeconds'] as int,
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayText = parseDuration(durationString);

    return Text(
      displayText,
      style: style,
    );
  }
}