# Zenslam - Winning the Mental Game of Tennis

## Project Overview
Zenslam is a Flutter mobile app offering 120+ guided meditation and visualization sessions for tennis players. Sessions cover technical visualization (forehand, backhand, serve, etc.), mental foundations (confidence, focus, flow state), critical match moments, and a "Winning" section.

## Architecture
- **Framework:** Flutter (Dart)
- **State Management:** GetX (`Get.put`, `Get.find`, `GetxController`)
- **Auth & Database:** Supabase (`supabase_flutter`)
- **Push Notifications:** Firebase Messaging (`firebase_core` + `firebase_messaging` only)
- **In-App Purchases:** RevenueCat (`purchases_flutter`)
- **Audio Playback:** `audioplayers` + `audio_service` for background playback
- **Crash Reporting:** Sentry (`sentry_flutter`)
- **Localization:** `easy_localization` with JSON files in `assets/translations/`

## Project Structure
```
lib/
  main.dart                           # Entry point, initializes Supabase/Firebase/Sentry
  firebase_options.dart               # Firebase config (FCM only)
  core/
    config/
      env_config.dart                 # Environment variables (Supabase URL, keys, Sentry DSN)
      supabase_config.dart            # Supabase connection config
    const/
      app_colors.dart                 # Color palette (navy blue, court blue, tennis yellow)
      endpoints.dart                  # Supabase table names (Tables class) and storage buckets
      shared_pref_helper.dart         # SharedPreferences wrapper
    data/
      tennis_content_library.dart     # 130 session definitions across 13 categories
    services/
      supabase_auth_service.dart      # Auth via Supabase (email, Google, password reset)
      google_sign_in_service.dart     # Google Sign-In → Supabase ID token auth
      notification_service.dart       # FCM push notifications + local notifications
      revenuecat_service.dart         # Subscription management (entitlement: 'Zenslam Pro')
    global_widegts/                   # Note: intentional typo in directory name (legacy)
      network_response.dart           # API service wrapper
  app/
    auth/                             # Login, register, forgot password, social auth
    onboarding_flow/                  # Splash, onboarding carousel, subscription paywall
    home_flow/                        # Home screen, recommendations, daily sessions
    explore/                          # Browse by category, audio player, mini player
    mentor_flow/                      # Coach/mentor chat (WebSocket)
    favorite_flow/                    # Favorites, bottom nav bar
    profile_flow/                     # Profile, settings, edit info, privacy policy
    bottom_nav_bar/                   # Navigation (Home, Explore, Coach, Favorite, Profile)
```

## Color Palette
| Token | Hex | Usage |
|---|---|---|
| `primaryColor` | `#2563EB` | Primary blue, buttons, interactive |
| `primaryLight` | `#3B82F6` | Lighter blue accents |
| `primaryDark` | `#1A3A5C` | Deep navy, app bars |
| `accentYellow` | `#C8E020` | Tennis ball yellow, highlights |
| `bgDark` | `#0D1B2A` | Main dark background |
| `bgCard` | `#1B2D44` | Card/surface backgrounds |

## Bundle IDs & Identifiers
- **iOS Bundle ID:** `com.zenslam.app`
- **Android Application ID:** `com.zenslam.app`
- **Dart Package Name:** `zenslam`
- **RevenueCat Entitlement:** `Zenslam Pro`
- **Audio Channel ID:** `com.zenslam.channel.audio`

## Supabase Tables
- `profiles`, `categories`, `sessions`, `series`, `coaches`, `favorites`, `user_preferences`, `daily_sessions`
- Storage buckets: `audio-files`, `images`, `avatars`

## Key Commands
```bash
flutter pub get          # Install dependencies
dart analyze lib/        # Check for errors (0 errors expected)
flutter run              # Run on connected device
flutter build ios        # Build for iOS
flutter build appbundle  # Build for Android
```

## Conventions
- All user-facing text uses `easy_localization` keys from `assets/translations/en.json`
- Navigation tabs: Home, Explore, Coach, Favorite, Profile
- The "Mentor" feature is internally called `mentor_flow/` but displayed as "Coach" to users
- Environment config loaded from `.env.json` (not committed to git)
- Firebase is ONLY used for push notifications (FCM) - all auth and data goes through Supabase
