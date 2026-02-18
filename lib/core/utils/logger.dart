import 'package:flutter/foundation.dart';

/// A utility class for logging that only prints in debug mode.
/// This ensures no debug output is visible in production builds.
class AppLogger {
  /// Log a message. Only prints in debug mode.
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log an info message with 📘 prefix
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('📘 $prefix$message');
    }
  }

  /// Log a success message with ✅ prefix
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('✅ $prefix$message');
    }
  }

  /// Log an error message with ❌ prefix
  static void error(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
    }
  }

  /// Log a warning message with ⚠️ prefix
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $prefix$message');
    }
  }

  /// Log API/Network message with 🌐 prefix
  static void network(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🌐 $prefix$message');
    }
  }

  /// Log response data with 📥 prefix
  static void response(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('📥 $prefix$message');
    }
  }
}
