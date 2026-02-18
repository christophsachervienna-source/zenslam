/// Supabase table names and storage buckets for Zenslam
class Tables {
  static const String profiles = 'profiles';
  static const String categories = 'categories';
  static const String sessions = 'sessions';
  static const String series = 'series';
  static const String coaches = 'coaches';
  static const String favorites = 'favorites';
  static const String userPreferences = 'user_preferences';
  static const String dailySessions = 'daily_sessions';
}

class StorageBuckets {
  static const String audioFiles = 'audio-files';
  static const String images = 'images';
  static const String avatars = 'avatars';
}

/// Legacy URL class kept for backward compatibility during migration
class Urls {
  static const String baseUrl = '';
}
