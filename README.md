# ZenSlam

**Neuroscience-based mental training for tennis players.**

A Flutter mobile application delivering 100+ guided audio sessions for tennis mental performance improvement.

## Tech Stack

- **Mobile:** Flutter (iOS & Android)
- **State Management:** Riverpod
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **AI:** OpenAI GPT API
- **Subscriptions:** RevenueCat
- **Analytics:** Firebase Analytics + Mixpanel
- **Admin Panel:** React/Next.js

## Project Structure

```
zenslam/
├── app/                    # Flutter mobile app
├── admin/                  # React/Next.js admin panel
├── supabase/              # Supabase migrations and functions
└── docs/                  # Documentation
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+
- Node.js 18+ (for admin panel)
- Supabase CLI

### Setup

1. Clone the repository
2. Install Flutter dependencies: `cd app && flutter pub get`
3. Configure environment variables
4. Run the app: `flutter run`

## Documentation

See `ZENSLAM_FLUTTER_APP_SPECIFICATION.md` for complete technical specification.

## License

Proprietary - All rights reserved.
