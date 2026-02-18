import 'package:flutter/foundation.dart';

/// Environment configuration class that reads values from dart-define or .env
/// Usage: flutter run --dart-define-from-file=.env.json
class EnvConfig {
  EnvConfig._();

  /// Current environment (dev, staging, prod)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// Supabase URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// RevenueCat Apple API Key
  static const String revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: '',
  );

  /// RevenueCat Google API Key
  static const String revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
    defaultValue: '',
  );

  /// Sentry DSN for crash reporting
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Check if running in debug mode
  static bool get isDebug => kDebugMode;

  /// Check if running in production
  static bool get isProduction => environment == 'prod';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in development
  static bool get isDevelopment => environment == 'dev';

  /// Check if Supabase is configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Validate that required configuration is present
  static void validateConfig() {
    final List<String> missingKeys = [];

    if (revenueCatAppleApiKey.isEmpty && revenueCatGoogleApiKey.isEmpty) {
      missingKeys.add('REVENUECAT_APPLE_API_KEY or REVENUECAT_GOOGLE_API_KEY');
    }

    if (!isSupabaseConfigured) {
      missingKeys.add('SUPABASE_URL and SUPABASE_ANON_KEY');
    }

    if (missingKeys.isNotEmpty && !kDebugMode) {
      throw StateError(
        'Missing required environment configuration: ${missingKeys.join(', ')}\n'
        'Please provide these values via --dart-define when building.',
      );
    }

    if (missingKeys.isNotEmpty && kDebugMode) {
      debugPrint('WARNING: Missing environment config: ${missingKeys.join(', ')}');
      debugPrint('Some features may not work correctly.');
    }
  }

  /// Print current configuration (for debugging - masks sensitive values)
  static void printConfig() {
    if (!kDebugMode) return;

    debugPrint('=== Environment Configuration ===');
    debugPrint('Environment: $environment');
    debugPrint('Supabase URL: $supabaseUrl');
    debugPrint('Supabase Anon Key: ${_maskKey(supabaseAnonKey)}');
    debugPrint('Sentry DSN: ${_maskKey(sentryDsn)}');
    debugPrint('RevenueCat Apple Key: ${_maskKey(revenueCatAppleApiKey)}');
    debugPrint('RevenueCat Google Key: ${_maskKey(revenueCatGoogleApiKey)}');
    debugPrint('================================');
  }

  /// Mask sensitive keys for logging
  static String _maskKey(String key) {
    if (key.isEmpty) return '(not set)';
    if (key.length < 10) return '***';
    return '${key.substring(0, 7)}...${key.substring(key.length - 4)}';
  }
}
