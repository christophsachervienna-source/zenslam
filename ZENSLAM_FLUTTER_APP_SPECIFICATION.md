# ZenSlam Flutter Mobile App Specification

## Technical Implementation Document

**Version:** 1.0
**Last Updated:** January 2026
**Status:** Development Ready
**Platforms:** iOS & Android (Flutter)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Technical Architecture](#2-technical-architecture)
3. [Design System](#3-design-system)
4. [App Structure & Navigation](#4-app-structure--navigation)
5. [Screen Specifications](#5-screen-specifications)
6. [Feature Specifications](#6-feature-specifications)
7. [AI Mentor System](#7-ai-mentor-system)
8. [Authentication & Onboarding](#8-authentication--onboarding)
9. [Subscription & Monetization](#9-subscription--monetization)
10. [Offline & Downloads](#10-offline--downloads)
11. [Admin Panel Specification](#11-admin-panel-specification)
12. [Data Models](#12-data-models)
13. [API Specification](#13-api-specification)
14. [Error Handling & Copy](#14-error-handling--copy)
15. [Analytics & Tracking](#15-analytics--tracking)
16. [Accessibility](#16-accessibility)
17. [Phase Implementation](#17-phase-implementation)

---

## 1. Executive Summary

### 1.1 Product Overview

ZenSlam is a neuroscience-based mental training mobile application designed specifically for tennis players. The app delivers 100+ guided audio sessions covering motor imagery, nervous system regulation, sports psychology, attention training, and subconscious programming.

**Core Differentiator:** This is a performance system, not a wellness app. Every session is backed by sports neuroscience and designed for measurable on-court improvement.

### 1.2 Technical Stack

| Component | Technology |
|-----------|------------|
| Mobile Framework | Flutter (Dart) |
| State Management | Riverpod |
| Backend | Supabase (PostgreSQL + Auth + Storage + Edge Functions) |
| Audio Hosting | Supabase Storage |
| AI Integration | OpenAI GPT API |
| Subscriptions | RevenueCat |
| Analytics | Firebase Analytics + Mixpanel |
| Push Notifications | Firebase Cloud Messaging |
| Admin Panel | React/Next.js (Web) |

### 1.3 Platform Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 14.0+ |
| Android | API 24 (Android 7.0)+ |
| Tablet | Phone-only initially (not optimized for iPad/tablets) |

### 1.4 Language Support

- English only for MVP
- No internationalization infrastructure in Phase 1

---

## 2. Technical Architecture

### 2.1 Flutter Architecture Pattern

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
│       ├── colors.dart
│       ├── typography.dart
│       └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   ├── explore/
│   ├── mentor/
│   ├── favorites/
│   ├── profile/
│   ├── player/
│   ├── programs/
│   └── onboarding/
├── shared/
│   ├── widgets/
│   ├── providers/
│   └── models/
└── services/
    ├── audio_service.dart
    ├── ai_service.dart
    ├── analytics_service.dart
    └── notification_service.dart
```

### 2.2 State Management (Riverpod)

```dart
// Provider architecture
- authProvider: Manages authentication state
- userProvider: Current user data and profile
- sessionsProvider: Session library with caching
- playerProvider: Audio playback state
- favoritesProvider: User's favorited sessions
- downloadProvider: Offline download management
- mentorProvider: AI chat state
- analyticsProvider: Event tracking
```

### 2.3 Supabase Schema Overview

```sql
-- Core tables
users
sessions
categories
programs
program_sessions
user_progress
user_favorites
user_downloads
subscriptions
daily_featured
mentor_conversations
support_conversations
ratings
analytics_events
```

### 2.4 Audio Playback Architecture

- Use `just_audio` package for playback
- Background audio with `audio_service` package
- Lock screen controls on both platforms
- Smart pause on audio interruption (calls, other apps)
- Auto-resume after interruption ends
- Sessions always start from beginning (no position persistence)
- No variable playback speed (fixed 1x to preserve intended pacing)

---

## 3. Design System

### 3.1 Color Palette

```dart
class ZenSlamColors {
  // Primary
  static const Color deepBlue = Color(0xFF003366);      // Primary background
  static const Color summerBlue = Color(0xFF1991D0);    // Logo/Accent

  // Accent
  static const Color neonYellow = Color(0xFFCCFF00);    // Action/Energy highlights
  static const Color skyBlue = Color(0xFF97DDFF);       // Secondary accent

  // Surface
  static const Color white = Color(0xFFFFFFFF);         // Text/Surface

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepBlue, summerBlue],
  );

  // Glassmorphism
  static const Color glassWhite = Color(0x1AFFFFFF);    // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);   // 20% white border
}
```

### 3.2 Gradient Variations by Category

Each of the 12 content categories has a subtle gradient variation:

```dart
// Same color palette, different gradient angles/intensities
forehandGradient: 0° angle (top to bottom)
backhandGradient: 15° angle
serveGradient: 30° angle
volleyGradient: 45° angle
dropShotGradient: 60° angle
footworkGradient: 75° angle
eyesOnBallGradient: 90° angle (left to right)
confidenceGradient: 105° angle
concentrationGradient: 120° angle
flowStateGradient: 135° angle
innerGameGradient: 150° angle
criticalMomentsGradient: 165° angle
```

### 3.3 Typography

```dart
class ZenSlamTypography {
  static const String fontFamily = 'Inter'; // or SF Pro for iOS-native feel

  // Hierarchy
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
  );
}
```

### 3.4 Component Specifications

#### Glassmorphism Cards

```dart
Container(
  decoration: BoxDecoration(
    color: ZenSlamColors.glassWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ZenSlamColors.glassBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: content,
    ),
  ),
)
```

#### Primary CTA Button

```dart
// White button with Deep Blue text (highest accessibility)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: ZenSlamColors.white,
    foregroundColor: ZenSlamColors.deepBlue,
    minimumSize: Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Button Label'),
)
```

#### Session Card (Grid View)

```dart
// Card dimensions
width: (screenWidth - 48) / 2  // 2 columns with 16px padding
height: 180

// Content
- Tennis photography background (unique per session)
- Gradient overlay for text legibility
- Session title (bottom left)
- Duration badge "10 min" (top right)
- Lock icon overlay if premium + user is free
- Heart icon (favorite) top left
```

#### Session Card (List View)

```dart
// Card dimensions
width: full width - 32px padding
height: 80

// Content
- Square thumbnail (64x64) left side
- Title + category text
- Duration "10 min" right side
- Lock icon if locked
```

### 3.5 Iconography

- Style: Outlined, 2px stroke, rounded caps
- Library: Custom icons or Phosphor Icons
- Category icons: Custom illustrations for each of the 12 categories
- Session thumbnails: High-quality tennis photography (unique per session)

### 3.6 Neon Yellow Usage (Sparingly)

The neon yellow (#CCFF00) should only be used for:
- Live/active indicators
- Notification badges
- Special promotional highlights
- "New" badges on fresh content

Never use for primary buttons or large surfaces.

---

## 4. App Structure & Navigation

### 4.1 Bottom Navigation (5 Tabs)

```
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│  Home   │ Explore │ Mentor  │Favorites│ Profile │
│   🏠    │   🔍    │   💬    │   ❤️    │   👤    │
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

**Active State:** Color change (Summer Blue) + label highlight

### 4.2 Tab Descriptions

| Tab | Purpose | Key Features |
|-----|---------|--------------|
| Home | Personalized dashboard | Greeting, Featured, Quick Sessions, Categories |
| Explore | Content discovery | Search, Categories, Programs, All Sessions |
| Mentor | AI coaching chat | Premium-only AI mental coach |
| Favorites | Saved content | Favorite sessions + Recently played |
| Profile | Account & settings | Profile, Settings, Support AI, Subscription |

### 4.3 Navigation Flow

```
App Launch
    │
    ▼
Splash (Logo, 1-2s fade)
    │
    ▼
Auth Check ──── Not Logged In ──► Onboarding Flow
    │
    ▼ Logged In
Home Tab (Default)
    │
    ├── Session Card Tap ──► Session Detail ──► Player (Full Screen)
    ├── Category Tap ──► Category Sessions List
    ├── Quick Session Tap ──► Player (Full Screen)
    └── Featured Tap ──► Session Detail
```

---

## 5. Screen Specifications

### 5.1 Splash Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│           [ZenSlam Logo]            │
│        (Tennis ball motion          │
│         design - white)             │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘

Background: Gradient (Deep Blue → Summer Blue)
Duration: 1-2 seconds fade
Transition: Fade to Home or Onboarding
```

### 5.2 Home Screen

```
┌─────────────────────────────────────┐
│ Good morning                    [A] │  ← Time-based greeting, no name
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │     FEATURED SESSION            │ │  ← Manually curated daily
│ │     [Tennis Photo Background]   │ │
│ │     Session Title               │ │
│ │     10 min • Category          ▶│ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Quick Sessions          See all ▶  │
│ ┌─────┐┌─────┐┌─────┐┌─────┐┌───  │  ← Horizontal scroll carousel
│ │Calm ││Focus││Reset││Pre- ││     │
│ │Nerves││Now  ││After││Match││...  │
│ │5 min││4 min││4 min││6 min││     │
│ └─────┘└─────┘└─────┘└─────┘└───  │
├─────────────────────────────────────┤
│ Categories                          │
│ ┌───────────┐ ┌───────────┐        │
│ │ Forehand  │ │ Backhand  │        │  ← 12 content categories
│ │ [Icon]    │ │ [Icon]    │        │     2-column grid
│ └───────────┘ └───────────┘        │
│ ┌───────────┐ ┌───────────┐        │
│ │ Serve     │ │ Volley    │        │
│ └───────────┘ └───────────┘        │
│        ... (scrollable)             │
├─────────────────────────────────────┤
│ [Home] [Explore] [Mentor] [Fav] [P] │
└─────────────────────────────────────┘
```

**Quick Sessions Carousel Options:**
- Calm my nerves (5 min)
- Focus right now (4 min)
- Reset after mistake (4 min)
- Pre-match boost (6 min)
- Confidence boost (5 min)
- Between sets reset (4 min)
- Post-match wind down (8 min)
- Serving confidence (5 min)

### 5.3 Explore Screen

```
┌─────────────────────────────────────┐
│ Explore                             │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔍 Search sessions...           │ │  ← Text search only
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Programs                   See all ▶│
│ ┌─────────┐┌─────────┐┌─────────┐  │  ← Horizontal scroll
│ │Foundation││Pre-Season││Confidence│
│ │2 weeks   ││4 weeks   ││2 weeks  │
│ │[Locked]  ││[Locked]  ││[Locked] │
│ └─────────┘└─────────┘└─────────┘  │
├─────────────────────────────────────┤
│ Categories              [Grid][List]│  ← View toggle
│ ┌───────────┐ ┌───────────┐        │
│ │ Forehand  │ │ Backhand  │        │
│ │ 12 sessions│ 12 sessions│        │
│ └───────────┘ └───────────┘        │
│ ┌───────────┐ ┌───────────┐        │
│ │ Serve     │ │ Volley    │        │
│ │ 10 sessions│ 8 sessions │        │
│ └───────────┘ └───────────┘        │
│        ... (all 12 categories)      │
├─────────────────────────────────────┤
│ [Home] [Explore] [Mentor] [Fav] [P] │
└─────────────────────────────────────┘
```

### 5.4 Category Sessions Screen

```
┌─────────────────────────────────────┐
│ ←  Forehand               [Grid][L] │
├─────────────────────────────────────┤
│ 12 sessions                         │
├─────────────────────────────────────┤
│ Grid View:                          │
│ ┌─────────────┐ ┌─────────────┐    │
│ │ [Photo]     │ │ [Photo]     │    │
│ │ 🔒          │ │ ♡           │    │
│ │ Perfect     │ │ Forehand    │    │
│ │ Forehand    │ │ Winner      │    │
│ │ 12 min      │ │ 10 min      │    │
│ └─────────────┘ └─────────────┘    │
│                                     │
│ List View:                          │
│ ┌─────────────────────────────────┐│
│ │[□] Perfect Forehand Flow  12 min││
│ │    Motor Imagery          🔒    ││
│ └─────────────────────────────────┘│
│ ┌─────────────────────────────────┐│
│ │[□] Forehand Winner Vis.   10 min││
│ │    Motor Imagery          ♡     ││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### 5.5 Session Detail Screen (Minimal)

```
┌─────────────────────────────────────┐
│ ←                              ♡   │  ← Back + Favorite
├─────────────────────────────────────┤
│                                     │
│         [Session Photography]       │
│              (Large)                │
│                                     │
├─────────────────────────────────────┤
│                                     │
│ Perfect Forehand Flow               │  ← Title
│                                     │
│ 12 min • Forehand                   │  ← Duration + Category
│                                     │
│ Build automatic, confident          │  ← Brief description
│ forehand execution through          │
│ detailed motor imagery.             │
│                                     │
├─────────────────────────────────────┤
│                                     │
│      ┌─────────────────────┐        │
│      │    ▶ Play Session   │        │  ← Primary CTA
│      └─────────────────────┘        │
│                                     │
└─────────────────────────────────────┘
```

### 5.6 Player Screen (Full Screen) - Unlocked

```
┌─────────────────────────────────────┐
│                                     │
│   [Full Screen Tennis Photography   │
│         as Background]              │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│    Perfect Forehand Flow            │  ← Session title
│    Forehand                         │  ← Category
│                                     │
│  ════════════●══════════════════    │  ← Progress bar (always visible)
│  3:24                      12:00    │  ← Current / Total time
│                                     │
│     ⟲15      ▶ ⏸      15⟳          │  ← Skip back, Play/Pause, Skip fwd
│                                     │
│            ✕ Close                  │  ← Close button
│                                     │
└─────────────────────────────────────┘
```

### 5.7 Player Screen (Full Screen) - Locked/Premium

```
┌─────────────────────────────────────┐
│                                     │
│   [Full Screen Tennis Photography   │
│         as Background]              │
│                                     │
│                                     │
│             🔒                      │  ← Large lock icon overlay
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│    Perfect Forehand Flow            │
│    Forehand                         │
│                                     │
│  This session is for premium        │
│  members only.                      │
│                                     │
│      ┌─────────────────────┐        │
│      │  Get Full Access    │        │  ← Opens paywall
│      └─────────────────────┘        │
│                                     │
│            ✕ Close                  │
│                                     │
└─────────────────────────────────────┘
```

### 5.8 Session Complete Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│              ✓                      │  ← Checkmark animation + haptic
│                                     │
│       Session Complete              │
│                                     │
│  Perfect Forehand Flow              │
│  12 minutes                         │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  How was this session?              │
│                                     │
│     ☆   ☆   ☆   ☆   ☆              │  ← 5-star rating
│                                     │
├─────────────────────────────────────┤
│                                     │
│      ┌─────────────────────┐        │
│      │       Done          │        │
│      └─────────────────────┘        │
│                                     │
└─────────────────────────────────────┘
```

### 5.9 Mentor Screen (AI Chat)

```
┌─────────────────────────────────────┐
│ Mentor                              │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Hi! I'm your mental         │   │  ← AI message
│  │ performance mentor. How     │   │
│  │ can I help you today?       │   │
│  └─────────────────────────────┘   │
│                                     │
│         ┌─────────────────────┐    │
│         │ I have a match      │    │  ← User message
│         │ tomorrow and I'm    │    │
│         │ nervous about my    │    │
│         │ serve.              │    │
│         └─────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ That's completely normal.   │   │
│  │ Let me recommend a session: │   │
│  │                             │   │
│  │ ┌─────────────────────┐    │   │  ← Tappable session card
│  │ │ Serve Under Pressure│    │   │
│  │ │ 9 min • Serve       │    │   │
│  │ └─────────────────────┘    │   │
│  │                             │   │
│  │ What type of match is it?   │   │  ← Follow-up question
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│ [Pre-match prep] [Serving tips] ... │  ← Quick reply chips
├─────────────────────────────────────┤
│ ┌─────────────────────────┐ [Send] │
│ │ Type a message...       │        │  ← Text input
│ └─────────────────────────┘        │
├─────────────────────────────────────┤
│ [Home] [Explore] [Mentor] [Fav] [P] │
└─────────────────────────────────────┘
```

**Mentor Premium Gate (Free User):**
```
┌─────────────────────────────────────┐
│ Mentor                              │
├─────────────────────────────────────┤
│                                     │
│                                     │
│              🔒                     │
│                                     │
│     AI Mentor is a Premium          │
│     Feature                         │
│                                     │
│   Get personalized mental           │
│   coaching, session recommendations,│
│   and expert tennis psychology      │
│   advice.                           │
│                                     │
│      ┌─────────────────────┐        │
│      │  Unlock Premium     │        │
│      └─────────────────────┘        │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 5.10 Favorites Screen

```
┌─────────────────────────────────────┐
│ Favorites                           │
├─────────────────────────────────────┤
│ Your Favorites                      │
│ ┌─────────────────────────────────┐ │
│ │[□] Perfect Forehand Flow  12 min│ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │[□] Serve Under Pressure    9 min│ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │[□] Unshakeable Confidence 14 min│ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Recently Played                     │
│ ┌─────────────────────────────────┐ │
│ │[□] Ball Focus Mastery     10 min│ │
│ │    Played today                 │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │[□] Champion's Mindset     12 min│ │
│ │    Played yesterday             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Home] [Explore] [Mentor] [Fav] [P] │
└─────────────────────────────────────┘
```

**Empty State (No Favorites):**
```
┌─────────────────────────────────────┐
│ Favorites                           │
├─────────────────────────────────────┤
│                                     │
│                                     │
│              ♡                      │
│                                     │
│     No favorites yet                │
│                                     │
│   Tap the heart icon on any         │
│   session to save it here           │
│   for quick access.                 │
│                                     │
│      ┌─────────────────────┐        │
│      │   Browse Sessions   │        │
│      └─────────────────────┘        │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 5.11 Profile Screen

```
┌─────────────────────────────────────┐
│ Profile                             │
├─────────────────────────────────────┤
│                                     │
│           [User Avatar]             │
│           john@email.com            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Premium Member        ✓     │   │  ← or "Upgrade to Premium"
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│ Progress                            │
│ ┌─────────────────────────────────┐ │
│ │ This Week          │ All Time   │ │
│ │ 45 min             │ 12.5 hrs   │ │
│ │ 4 sessions         │ 68 sessions│ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Settings                            │
│ ┌─────────────────────────────────┐ │
│ │ Tennis Profile             ▶   │ │  ← Edit profile or re-take onboarding
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Notifications              ▶   │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Downloads                  ▶   │ │  ← Manage offline downloads
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Help & Support             ▶   │ │  ← Opens Support AI chat
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Manage Subscription        ▶   │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Sign Out                       │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Home] [Explore] [Mentor] [Fav] [P] │
└─────────────────────────────────────┘
```

### 5.12 Programs Screen

```
┌─────────────────────────────────────┐
│ ←  Programs                         │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [Program Image]                 │ │
│ │ Foundation                      │ │
│ │ Build your mental game basics   │ │
│ │ 2 weeks • 14 sessions     🔒   │ │  ← Minimal info
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [Program Image]                 │ │
│ │ Pre-Season Mental Prep          │ │
│ │ Tournament preparation          │ │
│ │ 4 weeks • 20 sessions     🔒   │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [Program Image]                 │ │
│ │ Confidence Rebuild              │ │
│ │ After slumps or tough losses    │ │
│ │ 2 weeks • 10 sessions     🔒   │ │
│ └─────────────────────────────────┘ │
│        ... (5 total programs)       │
└─────────────────────────────────────┘
```

### 5.13 Program Detail Screen

```
┌─────────────────────────────────────┐
│ ←  Foundation                       │
├─────────────────────────────────────┤
│ [Program Header Image]              │
│                                     │
│ Build your mental game basics       │
│ 2 weeks • 14 sessions               │
├─────────────────────────────────────┤
│ Week 1                              │
│ ┌─────────────────────────────────┐ │
│ │ Day 1: Ball Focus Mastery  10m │ │  ← Current/unlocked
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Day 2: Present Moment      10m │ │  ← Greyed out, locked
│ │ 🔒                             │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Day 3: Laser Focus         11m │ │  ← Greyed out, locked
│ │ 🔒                             │ │
│ └─────────────────────────────────┘ │
│        ...                          │
├─────────────────────────────────────┤
│ Week 2 (locked)                     │
│        ...                          │
└─────────────────────────────────────┘
```

### 5.14 Support AI Screen (Profile > Help & Support)

```
┌─────────────────────────────────────┐
│ ←  Help & Support                   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Hi! How can I help you      │   │
│  │ today? I can answer         │   │
│  │ questions about the app,    │   │
│  │ troubleshoot issues, or     │   │
│  │ take your feedback.         │   │
│  └─────────────────────────────┘   │
│                                     │
│         ┌─────────────────────┐    │
│         │ The audio keeps     │    │
│         │ cutting out during  │    │
│         │ sessions            │    │
│         └─────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ I'm sorry to hear that.     │   │
│  │ Let's troubleshoot:         │   │
│  │                             │   │
│  │ 1. Check your connection    │   │
│  │ 2. Try downloading the      │   │
│  │    session for offline use  │   │
│  │ 3. Close other apps         │   │
│  │                             │   │
│  │ Is this happening on        │   │
│  │ WiFi or cellular?           │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│ [Report a bug] [Give feedback] ...  │
├─────────────────────────────────────┤
│ ┌─────────────────────────────┐ [>]│
│ │ Type a message...           │    │
│ └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Free User Queue Notice:**
```
Support chat is available to all users.
Premium members receive priority responses.

[Current wait: ~2 minutes]  ← For free users only
```

---

## 6. Feature Specifications

### 6.1 Audio Playback

**Behavior:**
- Full-screen player only (no mini player)
- Sessions always start from the beginning (no position persistence)
- Fixed 1x playback speed (no speed controls)
- Background audio supported with lock screen controls
- Smart pause on audio interruption (calls, other audio apps)
- Auto-resume after interruption ends
- Progress bar always visible
- Skip backward 15 seconds
- Skip forward 15 seconds

**Completion Tracking:**
- Session marked "completed" at 90% progress threshold
- Completion triggers haptic feedback
- Completion prompts 5-star rating
- Completion data synced to user progress

**Controls:**
- Play/Pause (center, large)
- Skip back 15s (left)
- Skip forward 15s (right)
- Close button (bottom)
- Progress bar with scrubbing

### 6.2 Favorites System

**Behavior:**
- Heart icon on session cards and detail screen
- Tap to toggle favorite status
- Favorites appear in dedicated Favorites tab
- Favorites list sorted by most recently favorited
- Favorites sync across devices via Supabase

### 6.3 Download System

**Behavior:**
- Download button available on session detail screen
- Download button available in player screen
- Downloaded sessions accessible in Profile > Downloads
- Downloads require WiFi by default (can be changed in settings)
- Downloaded files persist until manually deleted
- Playback works fully offline for downloaded content
- No offline recommendations (only downloaded sessions available offline)

**Download States:**
- Not downloaded (cloud icon)
- Downloading (progress indicator)
- Downloaded (checkmark)
- Error (retry icon)

### 6.4 Search

**Behavior:**
- Text search only (no voice)
- Search sessions by title
- Search sessions by category name
- Results show session cards
- No search history persistence

**Search Location:**
- Explore tab (search bar at top)

### 6.5 Categories

**The 12 Content Categories:**

| # | Category | Sessions | Description |
|---|----------|----------|-------------|
| 1 | Forehand | 12 | Forehand visualization and execution |
| 2 | Backhand | 12 | All backhand types and situations |
| 3 | Serve | 10 | Complete serving mental arsenal |
| 4 | Volley | 8 | Net play confidence |
| 5 | Drop Shot | 6 | Touch and tactical awareness |
| 6 | Footwork & Movement | 8 | Court coverage automation |
| 7 | Eyes on the Ball | 6 | Visual attention training |
| 8 | Confidence & Self-Belief | 12 | Mental strength building |
| 9 | Concentration & Focus | 10 | Sustained attention skills |
| 10 | Flow State | 8 | Peak performance access |
| 11 | Inner Game & Trust | 8 | Trust in unconscious competence |
| 12 | Critical Match Moments | 10 | High-pressure situation prep |

**Category Icons:**
- Custom illustrated iconography for each category
- Consistent style across all 12

### 6.6 Programs

**Available Programs (5 total):**

| Program | Duration | Sessions | Purpose |
|---------|----------|----------|---------|
| Foundation | 2 weeks | 14 | Mental game basics for new users |
| Pre-Season Mental Prep | 4 weeks | 20 | Tournament preparation |
| Confidence Rebuild | 2 weeks | 10 | Recovery after slumps |
| Serve Mastery | 3 weeks | 15 | Complete serve mental training |
| Match Tough | 3 weeks | 18 | Competition focus |

**Program Behavior:**
- All programs visible to all users
- All programs premium-locked (free users see paywall on enrollment)
- Strict linear progression (must complete Day 1 before Day 2)
- Future sessions visible but greyed out with lock icon
- Can view upcoming session descriptions but cannot play
- Program progress tracked per-user

### 6.7 Ratings

**Behavior:**
- 5-star rating shown after session completion
- Rating is optional (user can skip via Done button)
- Ratings stored in database
- Average ratings calculated but not displayed to users (for internal use)

**App Store Review Trigger:**
- After user gives 5 stars on more than 5 sessions
- Show native iOS/Android app review prompt
- Only trigger once (track in user preferences)

### 6.8 Push Notifications

**Configuration:**
- Simple on/off toggle
- Single time picker for daily reminder
- No day-of-week selection

**Notification Content:**
- Personalized: "Time for your forehand visualization, [Name]"
- Based on user's profile challenges and recent activity
- Falls back to generic if no personalization available

### 6.9 Progress & Stats

**Weekly Stats:**
- Total minutes listened this week
- Total sessions completed this week
- Days active this week

**Lifetime Stats:**
- Total hours listened
- Total sessions completed
- Most played category
- Member since date

**No Streak Tracking** - no gamification through consecutive day tracking.

### 6.10 View Toggle (Grid/List)

**Available on:**
- Category sessions screen
- Explore > All sessions

**Grid View:**
- 2 columns
- Square cards with photography
- Title + duration overlay

**List View:**
- Full-width rows
- Small thumbnail + title + duration + category

**Persistence:**
- User's view preference saved locally
- Persists across app restarts

---

## 7. AI Mentor System

### 7.1 Overview

The AI Mentor ("Mentor") is a premium-only conversational AI feature powered by OpenAI's GPT API. It provides personalized mental coaching, session recommendations, and tennis psychology advice.

### 7.2 Access Control

- **Premium users:** Full access
- **Free users:** See locked screen with upgrade prompt

### 7.3 Mentor Persona

**Name:** Mentor

**Expertise Combination:**
- Tennis mental coaching expert
- Neuroscience-informed (5 pillars knowledge)
- Supportive performance coach tone

**Personality Traits:**
- Calm and authoritative
- Asks clarifying questions naturally
- Provides actionable advice
- References ZenSlam sessions when relevant
- Never generic or wellness-focused

**System Prompt (Core):**
```
You are Mentor, the AI mental performance coach for ZenSlam, a neuroscience-based
tennis mental training app. You have deep expertise in:

1. Tennis-specific mental coaching (match situations, pressure points, stroke psychology)
2. The 5 neuroscience pillars: Nervous System Regulation, Attention/Perception,
   Motor Imagery, Sports Psychology, and Subconscious Programming
3. The ZenSlam session library (100+ sessions across 12 categories)

Your communication style:
- Calm, precise, and authoritative
- Ask clarifying questions to give better recommendations
- Provide actionable, tennis-specific advice
- Reference specific ZenSlam sessions using [SESSION:session_id] format
- Never use generic wellness language
- Be conversational but not chatty

When recommending sessions, use this exact format:
[SESSION:session_id|Session Title|Duration|Category]

The user is a tennis player seeking mental performance improvement.
```

### 7.4 Session Recommendations

When Mentor references a session, it outputs:
```
[SESSION:forehand_under_pressure|Forehand Under Pressure|11 min|Forehand]
```

The app parses this and renders a tappable session card inline in the chat.

### 7.5 Quick Reply Chips

Suggested quick replies appear above the keyboard:
- "Pre-match prep"
- "Serving tips"
- "Handling nerves"
- "Focus help"
- "After a loss"
- "Confidence boost"

Dynamic chips based on conversation context.

### 7.6 Conversation History

- Session-based only (not persistent)
- Each time user opens Mentor tab, starts fresh conversation
- Previous conversations not stored or retrievable

### 7.7 Rate Limiting

- Maximum 10 messages per minute per user
- No daily cap for premium users
- Rate limit error handled gracefully with toast message

### 7.8 Support AI

The same AI system with different context is used for Help & Support:

**Support System Prompt:**
```
You are the ZenSlam Support Assistant. Help users with:
- App troubleshooting
- Feature questions
- Bug reports
- Feedback collection

Collect detailed information about issues.
Be helpful and solution-oriented.
Log feedback for product improvement.
```

**Access:**
- Available to all users
- Premium users get priority (instant responses)
- Free users may see brief queue message

**Conversation Logging:**
- All support conversations logged to database
- For product insights and issue tracking
- Associated with user_id for follow-up

---

## 8. Authentication & Onboarding

### 8.1 Authentication Methods

- Email + Password
- Apple Sign In (required for iOS)
- Google Sign In

All via Supabase Auth.

### 8.2 Onboarding Flow

```
Step 1: Welcome
────────────────
"ZenSlam"
[Logo]
"Neuroscience-based mental training for tennis"
[Get Started]
[I already have an account] → Login

Step 2: Player Profile
────────────────────────
"Tell us about your game"

Playing level:
○ Recreational
○ Club
○ Competitive
○ College
○ Pro/Aspiring Pro

Years playing tennis:
[Number input]

Primary hand:
○ Right
○ Left

Backhand type:
○ One-handed
○ Two-handed

[Continue]

Step 3: Current Challenges
────────────────────────────
"What's holding back your tennis?"
Select 1-3 challenges:

□ Nerves in matches
□ Inconsistent focus
□ Forehand breaks down
□ Backhand is a weakness
□ Serving under pressure
□ Net confidence
□ Closing out matches
□ Coming back from behind
□ Trusting my game

[Continue]

Step 4: Goals
────────────────
"What do you want from mental training?"
Select one:

○ Win more matches
○ Play with less stress
○ Execute effortlessly
○ Compete at higher level

[Continue]

Step 5: Create Account
────────────────────────
"Save your progress"

[Continue with Apple]
[Continue with Google]
─── or ───
Email: [________________]
Password: [________________]
[Create Account]

Step 6: Subscription Offer
────────────────────────────
"Unlock your full potential"

[Paywall Screen - see Section 9]

[Start Free] → Home (with free tier)
[Subscribe] → Payment → Home (premium)

Step 7: Personalized Start
────────────────────────────
"Based on your answers, we recommend:"

[First Session Card based on challenges]

[Start Training] → Session Player
[Browse Library] → Home
```

### 8.3 Profile Editing

Users can edit their tennis profile anytime via Profile > Tennis Profile:

**Options:**
- Edit individual fields (level, hand, backhand, challenges, goal)
- "Retake Onboarding" button to restart the full questionnaire

---

## 9. Subscription & Monetization

### 9.1 Subscription Tiers

| Tier | Price | Billing |
|------|-------|---------|
| Monthly | $12.99 | Recurring monthly |
| Annual | $99.99 | Recurring yearly (~36% savings) |

### 9.2 Free Tier

**Access:**
- 3-5 fixed curated sessions (always free)
- Full browse/search of library (can see all sessions)
- Session detail viewing
- Locked player screen on premium content
- No AI Mentor access
- Limited Support AI (with queue)

**Free Sessions (Fixed Selection):**
1. Ball Focus Mastery (10 min) - Eyes on Ball
2. Pre-Match Confidence (8 min) - Confidence
3. Laser Focus Protocol (7 min) - Winning Edge
4. Reset and Reload (5 min) - Winning Edge
5. Trust Your Training (10 min) - Inner Game

### 9.3 Premium Tier

**Access:**
- All 100+ sessions
- All 5 programs
- AI Mentor (full access)
- Priority Support AI
- Offline downloads
- Future features

### 9.4 Paywall Screen

```
┌─────────────────────────────────────┐
│                 ✕                   │
├─────────────────────────────────────┤
│                                     │
│   Unlock Your Full Potential        │
│                                     │
│   ┌─────────────────────────────┐  │
│   │ "ZenSlam transformed my     │  │  ← Testimonial
│   │  match mentality. I went    │  │
│   │  from choking on big        │  │
│   │  points to seeking them     │  │
│   │  out."                      │  │
│   │                             │  │
│   │  — Marcus T., 4.5 USTA     │  │
│   └─────────────────────────────┘  │
│                                     │
│   What you get:                     │
│   ✓ 100+ guided audio sessions     │
│   ✓ 5 structured training programs │
│   ✓ AI Mental Performance Coach    │
│   ✓ Offline downloads              │
│   ✓ New content monthly            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Annual (Best Value)         │   │  ← Selected by default
│  │ $99.99/year                 │   │
│  │ Just $8.33/month            │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Monthly                     │   │
│  │ $12.99/month                │   │
│  └─────────────────────────────┘   │
│                                     │
│      ┌─────────────────────┐        │
│      │    Subscribe Now    │        │
│      └─────────────────────┘        │
│                                     │
│   Restore Purchases                 │
│                                     │
└─────────────────────────────────────┘
```

### 9.5 RevenueCat Integration

- Handle subscription state
- Receipt validation
- Cross-platform subscription sync
- Restore purchases functionality
- Subscription analytics

### 9.6 Paywall Trigger Points

1. **Session Play:** Tap on locked session → Player screen with lock overlay → "Get Full Access" button
2. **AI Mentor:** Free user opens Mentor tab → Locked screen with upgrade
3. **Programs:** Free user tries to start program → Paywall
4. **Onboarding:** Step 6 shows subscription offer (can skip)

---

## 10. Offline & Downloads

### 10.1 Download Behavior

- Download button on session detail screen
- Download button in player screen
- Downloads saved to device local storage
- Default: WiFi-only downloads (configurable in settings)

### 10.2 Download Management

Location: Profile > Downloads

```
┌─────────────────────────────────────┐
│ ←  Downloads                        │
├─────────────────────────────────────┤
│ Storage Used: 156 MB                │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Perfect Forehand Flow    12 min │ │
│ │ 8.2 MB              [Delete]    │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Serve Under Pressure      9 min │ │
│ │ 6.1 MB              [Delete]    │ │
│ └─────────────────────────────────┘ │
│                                     │
│      [Delete All Downloads]         │
│                                     │
└─────────────────────────────────────┘
```

### 10.3 Offline Mode

When device is offline:
- Only downloaded sessions playable
- Browse/search shows all content but locked sessions show "Download required"
- AI Mentor unavailable
- Progress syncs when back online

### 10.4 Storage Estimates

- Average session: ~8 MB (10 min @ 128 kbps AAC)
- Full library: ~850 MB
- Typical user: 50-100 MB (5-12 sessions)

---

## 11. Admin Panel Specification

### 11.1 Overview

Separate web application built with React/Next.js for content management and user administration.

**Access:** Single admin user (no role-based permissions needed for MVP)

### 11.2 Admin Panel Features

#### Dashboard
- Total users count
- Active subscribers count
- Sessions played today/week/month
- Revenue overview (via RevenueCat)

#### Session Management
- List all sessions with search/filter
- Add new session:
  - Drag-and-drop audio upload
  - Manual metadata entry (title, category, duration, description, etc.)
  - Upload unique session photography
- Edit existing sessions
- Delete sessions
- Set session as free/premium

#### Category Management
- List all 12 categories
- Edit category info (name, description, icon)
- Reorder categories

#### Program Management
- List all programs
- Edit program details
- Manage session order within programs
- Create new programs

#### Daily Featured
- Select featured session for each day
- Schedule featured content in advance
- Calendar view for planning

#### User Management
- List all users
- View user details (profile, progress, subscription status)
- Search users by email
- Cannot edit user data (read-only)

#### Support Conversations
- View logged support conversations
- Filter by date, user, topic
- Mark conversations as resolved
- Export for analysis

#### Analytics
- Basic usage metrics
- Session popularity
- Category engagement
- Funnel views

### 11.3 Admin Tech Stack

```
- Framework: Next.js 14+
- UI: Tailwind CSS + shadcn/ui
- Auth: Supabase Auth (same as mobile)
- State: React Query
- Charts: Recharts
- File Upload: React Dropzone
```

### 11.4 Admin API

Admin panel connects to same Supabase backend with elevated permissions via service role key or admin-specific Edge Functions.

---

## 12. Data Models

### 12.1 Database Schema (Supabase PostgreSQL)

```sql
-- Users (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Player Profile
CREATE TABLE public.player_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  playing_level TEXT NOT NULL, -- recreational, club, competitive, college, pro
  years_playing INTEGER,
  primary_hand TEXT NOT NULL, -- left, right
  backhand_type TEXT NOT NULL, -- one_handed, two_handed
  challenges TEXT[] NOT NULL DEFAULT '{}', -- max 3
  primary_goal TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Categories
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  gradient_angle INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions
CREATE TABLE public.sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  duration_seconds INTEGER NOT NULL,
  audio_url TEXT NOT NULL,
  image_url TEXT NOT NULL,
  category_id UUID NOT NULL REFERENCES public.categories(id),
  is_free BOOLEAN NOT NULL DEFAULT FALSE,
  is_quick_session BOOLEAN NOT NULL DEFAULT FALSE,
  quick_session_label TEXT, -- "Calm nerves", "Focus now", etc.

  -- Metadata
  primary_pillars TEXT[] NOT NULL DEFAULT '{}',
  secondary_pillars TEXT[] DEFAULT '{}',
  arousal_target TEXT, -- down_significant, down_slight, stabilize, up_slight, up_moderate, up_high
  use_cases TEXT[] DEFAULT '{}',
  experience_level TEXT DEFAULT 'intermediate',
  backhand_relevance TEXT, -- one_handed, two_handed, both, null

  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Programs
CREATE TABLE public.programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  duration_weeks INTEGER NOT NULL,
  image_url TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Program Sessions (junction table with order)
CREATE TABLE public.program_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  week_number INTEGER NOT NULL,
  day_number INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  UNIQUE(program_id, session_id)
);

-- User Progress
CREATE TABLE public.user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  duration_listened_seconds INTEGER NOT NULL,
  rating INTEGER, -- 1-5, nullable
  UNIQUE(user_id, session_id, completed_at)
);

-- User Favorites
CREATE TABLE public.user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, session_id)
);

-- User Program Progress
CREATE TABLE public.user_program_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  program_id UUID NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
  current_session_index INTEGER NOT NULL DEFAULT 0,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(user_id, program_id)
);

-- Daily Featured
CREATE TABLE public.daily_featured (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.sessions(id),
  featured_date DATE NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscriptions (synced from RevenueCat)
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  revenuecat_customer_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  status TEXT NOT NULL, -- active, expired, cancelled
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Mentor Conversations (session-based, not persisted long-term)
-- Only used for rate limiting and analytics
CREATE TABLE public.mentor_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message_type TEXT NOT NULL, -- user, assistant
  message_preview TEXT, -- first 100 chars for analytics
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Support Conversations (fully logged)
CREATE TABLE public.support_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  messages JSONB NOT NULL DEFAULT '[]',
  status TEXT NOT NULL DEFAULT 'open', -- open, resolved
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Session Ratings (for app store review trigger)
CREATE TABLE public.session_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Preferences
CREATE TABLE public.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notification_time TIME, -- e.g., '09:00:00'
  download_wifi_only BOOLEAN NOT NULL DEFAULT TRUE,
  view_preference TEXT NOT NULL DEFAULT 'grid', -- grid, list
  app_review_prompted BOOLEAN NOT NULL DEFAULT FALSE,
  five_star_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Indexes
CREATE INDEX idx_sessions_category ON public.sessions(category_id);
CREATE INDEX idx_user_progress_user ON public.user_progress(user_id);
CREATE INDEX idx_user_favorites_user ON public.user_favorites(user_id);
CREATE INDEX idx_daily_featured_date ON public.daily_featured(featured_date);
CREATE INDEX idx_mentor_messages_user_created ON public.mentor_messages(user_id, created_at);
```

### 12.2 Flutter Data Models

```dart
// Session Model
class Session {
  final String id;
  final String slug;
  final String title;
  final String description;
  final int durationSeconds;
  final String audioUrl;
  final String imageUrl;
  final String categoryId;
  final bool isFree;
  final bool isQuickSession;
  final String? quickSessionLabel;
  final List<String> primaryPillars;
  final List<String> secondaryPillars;
  final String? arousalTarget;
  final List<String> useCases;
  final String experienceLevel;
  final String? backhandRelevance;
  final int displayOrder;
  final DateTime createdAt;

  // Computed
  String get durationFormatted => '${(durationSeconds / 60).round()} min';

  // Local state (not from API)
  bool isDownloaded = false;
  bool isFavorited = false;
  bool isCompleted = false;
}

// Category Model
class Category {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String iconUrl;
  final int displayOrder;
  final int gradientAngle;

  // Computed
  int sessionCount = 0;
}

// Program Model
class Program {
  final String id;
  final String slug;
  final String title;
  final String description;
  final int durationWeeks;
  final String? imageUrl;
  final List<ProgramSession> sessions;

  // Computed
  int get totalSessions => sessions.length;
}

// User Model
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final PlayerProfile profile;
  final UserPreferences preferences;
  final SubscriptionStatus subscription;

  bool get isPremium => subscription.status == 'active';
}

// Player Profile
class PlayerProfile {
  final String playingLevel;
  final int? yearsPlaying;
  final String primaryHand;
  final String backhandType;
  final List<String> challenges;
  final String primaryGoal;
}

// User Stats
class UserStats {
  // Weekly
  final int weeklyMinutes;
  final int weeklySessions;
  final int weeklyDaysActive;

  // Lifetime
  final int totalMinutes;
  final int totalSessions;
  final String? mostPlayedCategory;
  final DateTime memberSince;
}
```

---

## 13. API Specification

### 13.1 Supabase Edge Functions

```typescript
// /functions/get-ai-response
// POST - Get AI Mentor or Support response
{
  type: 'mentor' | 'support',
  messages: [
    { role: 'user' | 'assistant', content: string }
  ],
  user_context?: {
    profile: PlayerProfile,
    recent_sessions: string[],
    challenges: string[]
  }
}

// Rate limiting: 10 messages/minute per user
// Returns: { response: string, session_recommendations?: Session[] }

// /functions/verify-subscription
// POST - Verify RevenueCat receipt
{
  receipt: string,
  platform: 'ios' | 'android'
}

// /functions/get-personalized-notification
// GET - Generate personalized push notification content
// Returns: { title: string, body: string }
```

### 13.2 Supabase Realtime Subscriptions

```dart
// Subscribe to user's subscription status changes
supabase
  .from('subscriptions')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .listen((data) => updateSubscriptionState(data));
```

### 13.3 Storage Buckets

```
supabase-storage/
├── session-audio/
│   └── {session_slug}.m4a
├── session-images/
│   └── {session_slug}.jpg
├── category-icons/
│   └── {category_slug}.svg
├── program-images/
│   └── {program_slug}.jpg
└── user-avatars/
    └── {user_id}.jpg
```

### 13.4 Audio Specifications

| Specification | Requirement |
|---------------|-------------|
| Format | AAC (.m4a) |
| Bitrate | 128 kbps |
| Sample Rate | 44.1 kHz |
| Channels | Stereo |
| Loudness | -16 LUFS |
| Silence Padding | 1 sec lead-in, 2 sec lead-out |

---

## 14. Error Handling & Copy

### 14.1 Network Errors

**Audio Streaming Failure:**
```
Behavior: Auto-retry 2-3 times silently
On continued failure: Toast message

Toast: "Connection issue. Check your internet and try again."
Action: [Retry] button appears in player
```

**API Request Failure:**
```
Toast: "Something went wrong. Please try again."
```

**Offline Mode:**
```
Banner (top of screen): "You're offline. Only downloaded sessions available."
```

### 14.2 Authentication Errors

**Invalid Credentials:**
```
"Email or password is incorrect. Please try again."
```

**Email Already Exists:**
```
"An account with this email already exists. Try signing in instead."
```

**Password Too Weak:**
```
"Password must be at least 8 characters."
```

**Social Auth Failed:**
```
"Sign in with [Apple/Google] failed. Please try again."
```

### 14.3 Empty States

**No Favorites:**
```
Icon: ♡
Title: "No favorites yet"
Body: "Tap the heart icon on any session to save it here for quick access."
CTA: [Browse Sessions]
```

**No Downloads:**
```
Icon: ↓
Title: "No downloads yet"
Body: "Download sessions to listen offline."
CTA: [Browse Sessions]
```

**No Search Results:**
```
Icon: 🔍
Title: "No results found"
Body: "Try a different search term or browse categories."
```

**No Recently Played:**
```
Icon: ▶
Title: "No recent sessions"
Body: "Sessions you listen to will appear here."
CTA: [Start Listening]
```

**Mentor Rate Limited:**
```
Toast: "Slow down! Please wait a moment before sending another message."
```

### 14.4 Success States

**Download Complete:**
```
Toast: "Session downloaded for offline listening."
```

**Session Completed:**
```
Visual: Checkmark animation + haptic
No toast needed
```

**Rating Submitted:**
```
Toast: "Thanks for your feedback!"
```

**Profile Updated:**
```
Toast: "Profile updated."
```

**Subscription Activated:**
```
Screen transition to Home
Toast: "Welcome to ZenSlam Premium!"
```

### 14.5 Paywall Copy

**Locked Session:**
```
"This session is for premium members only."
CTA: [Get Full Access]
```

**Locked Mentor:**
```
Title: "AI Mentor is a Premium Feature"
Body: "Get personalized mental coaching, session recommendations, and expert tennis psychology advice."
CTA: [Unlock Premium]
```

**Locked Program:**
```
"Unlock all programs with ZenSlam Premium."
CTA: [Get Full Access]
```

---

## 15. Analytics & Tracking

### 15.1 Analytics Platforms

- **Firebase Analytics:** Core usage metrics
- **Mixpanel:** Product analytics and engagement

### 15.2 Event Tracking

#### Core Events

| Event | Properties | Trigger |
|-------|------------|---------|
| `app_open` | - | App launched |
| `session_started` | session_id, category, is_free | Play button tapped |
| `session_completed` | session_id, category, duration_listened, completion_percent | 90% threshold reached |
| `session_rated` | session_id, rating | Rating submitted |
| `session_favorited` | session_id | Heart icon tapped |
| `session_downloaded` | session_id | Download completed |
| `category_viewed` | category_id | Category screen opened |
| `search_performed` | query, results_count | Search submitted |

#### Engagement Events

| Event | Properties | Trigger |
|-------|------------|---------|
| `time_in_app` | duration_seconds | App backgrounded |
| `scroll_depth` | screen, percent | Scroll tracking |
| `player_paused` | session_id, timestamp_seconds | Pause button |
| `player_seeked` | session_id, from_seconds, to_seconds | Scrub/skip |
| `mentor_message_sent` | message_length | User sends message |
| `quick_session_tapped` | quick_session_label | Quick session selected |

#### Conversion Events

| Event | Properties | Trigger |
|-------|------------|---------|
| `onboarding_started` | - | Onboarding begins |
| `onboarding_completed` | - | Account created |
| `paywall_viewed` | trigger_source | Paywall shown |
| `subscription_started` | product_id, price | Subscription activated |
| `subscription_cancelled` | - | Subscription cancelled |
| `free_trial_started` | - | Trial begins (if applicable) |

### 15.3 User Properties

| Property | Values |
|----------|--------|
| `subscription_status` | free, premium |
| `playing_level` | recreational, club, competitive, college, pro |
| `backhand_type` | one_handed, two_handed |
| `primary_goal` | win_matches, less_stress, effortless, higher_level |
| `total_sessions_completed` | number |
| `account_age_days` | number |

---

## 16. Accessibility

### 16.1 Approach

Basic accessibility with semantic labels and reasonable defaults. Not full WCAG compliance in MVP.

### 16.2 Requirements

**Screen Reader Support:**
- All interactive elements have semantic labels
- Images have alt text
- Buttons clearly describe their action

**Visual:**
- Minimum touch target size: 44x44 points
- Reasonable color contrast (not full AAA compliance)
- Support for system font size preferences (within reason)

**Audio:**
- Background audio clearly distinguishable from UI sounds
- No flashing or strobing content

### 16.3 Implementation

```dart
Semantics(
  label: 'Play session: Perfect Forehand Flow, 12 minutes',
  button: true,
  child: SessionCard(...),
)

Semantics(
  label: 'Add to favorites',
  button: true,
  child: HeartIcon(...),
)
```

---

## 17. Phase Implementation

### 17.1 MVP Phase (Months 1-3)

**Must Have:**
- [ ] User authentication (Email + Apple + Google)
- [ ] Onboarding flow with player profile
- [ ] Full content library (100+ sessions)
- [ ] 12 content categories with browse
- [ ] Session playback (full-screen, background audio)
- [ ] Basic progress tracking (completions, weekly/lifetime stats)
- [ ] Favorites functionality
- [ ] Offline downloads (individual sessions)
- [ ] Text search
- [ ] 5-star session ratings
- [ ] Subscription system (RevenueCat)
- [ ] Free tier (3-5 sessions)
- [ ] Paywall implementation
- [ ] AI Mentor (premium only)
- [ ] Support AI
- [ ] Push notifications (daily reminder)
- [ ] Profile management
- [ ] View toggle (grid/list)
- [ ] Deep linking (session links)
- [ ] Admin Panel (web app, parallel development)

**Content Required:**
- [ ] 100+ audio sessions recorded and uploaded
- [ ] Unique photography for each session
- [ ] Category icons (12)
- [ ] All metadata tagged

### 17.2 Phase 2 - Engagement (Months 4-5)

- [ ] Programs (5 structured journeys)
- [ ] Match Prep Wizard
- [ ] Quick session carousel on home
- [ ] Enhanced daily featured curation
- [ ] Improved search with filters
- [ ] Program progress tracking

### 17.3 Phase 3 - Growth (Months 6-8)

- [ ] Apple Health / Google Fit integration
- [ ] Widget support
- [ ] Social sharing
- [ ] Referral program
- [ ] App store review optimization
- [ ] New content (10-20 additional sessions)

### 17.4 Phase 4 - Advanced (Months 9-12)

- [ ] AI-powered personalized recommendations
- [ ] Match logging and correlation
- [ ] Advanced analytics dashboard
- [ ] Coach/academy B2B foundation
- [ ] Tablet-optimized layouts

---

## Appendix A: Deep Link Specification

### URL Format

```
zenslam://session/{session_slug}
https://zenslam.app/session/{session_slug}
```

### Handling

1. Parse session slug from URL
2. If user not authenticated → Onboarding → Deep link preserved → Open session after auth
3. If user authenticated → Navigate directly to session detail screen
4. If session not found → Navigate to home with error toast

---

## Appendix B: Push Notification Specification

### Notification Payload

```json
{
  "title": "Time for your visualization",
  "body": "Ready for your forehand session, Chris?",
  "data": {
    "type": "daily_reminder",
    "session_id": "optional_recommended_session_id"
  }
}
```

### Notification Handling

- If app in foreground: Show in-app banner
- If app in background/closed: System notification
- Tap action: Open app → If session_id present, navigate to session

---

## Appendix C: Audio Player Technical Spec

### Packages

```yaml
dependencies:
  just_audio: ^0.9.x
  audio_service: ^0.18.x
  audio_session: ^0.1.x
```

### Implementation Notes

```dart
// Audio player initialization
final player = AudioPlayer();

// Background audio setup
await AudioService.init(
  builder: () => AudioPlayerHandler(player),
  config: AudioServiceConfig(
    androidNotificationChannelId: 'com.zenslam.audio',
    androidNotificationChannelName: 'ZenSlam Audio',
    androidNotificationOngoing: true,
  ),
);

// Handle interruptions
AudioSession.instance.then((session) {
  session.interruptionEventStream.listen((event) {
    if (event.begin) {
      player.pause();
    } else {
      player.play(); // Auto-resume after interruption
    }
  });
});

// Completion detection (90% threshold)
player.positionStream.listen((position) {
  final progress = position.inMilliseconds / player.duration!.inMilliseconds;
  if (progress >= 0.9 && !sessionMarkedComplete) {
    markSessionComplete();
  }
});
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 2026 | ZenSlam Team | Initial specification |

---

**End of Specification**
