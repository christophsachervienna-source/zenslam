import 'package:flutter/foundation.dart';

/// Supabase configuration for Zenslam
/// Set these values via --dart-define or .env.json
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous key (public, safe for client-side)
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Validate that Supabase configuration is present
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Print config for debugging
  static void printConfig() {
    if (!kDebugMode) return;
    debugPrint('=== Supabase Configuration ===');
    debugPrint('URL: $url');
    debugPrint('Anon Key: ${anonKey.isNotEmpty ? "${anonKey.substring(0, 10)}..." : "(not set)"}');
    debugPrint('==============================');
  }
}
