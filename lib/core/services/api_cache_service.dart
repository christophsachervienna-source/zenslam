import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching API responses locally
class ApiCacheService {
  static const String _cachePrefix = 'api_cache_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  /// Get cached data
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('$_cachePrefix$key');

      if (cachedString == null) return null;

      final cachedData = jsonDecode(cachedString);
      final timestamp = DateTime.parse(cachedData['timestamp']);
      final duration = Duration(milliseconds: cachedData['duration']);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > duration) {
        await clearCache(key);
        return null;
      }

      return cachedData['data'];
    } catch (e) {
      debugPrint('Error getting cached data: $e');
      return null;
    }
  }

  /// Set cached data
  static Future<void> setCachedData(
    String key,
    Map<String, dynamic> data, {
    Duration duration = _defaultCacheDuration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'duration': duration.inMilliseconds,
      };

      await prefs.setString('$_cachePrefix$key', jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Error setting cached data: $e');
    }
  }

  /// Clear specific cache
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear all API caches
  static Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing all caches: $e');
    }
  }
}
