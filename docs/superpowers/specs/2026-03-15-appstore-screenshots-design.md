# App Store Screenshots — Design Spec

## Goal

Automate generation of App Store screenshots for Brainy app: 6 screens × 2 languages × 2 device sizes = 24 final images with text captions.

## Architecture

Two-phase pipeline:

1. **Flutter integration test** captures raw screenshots from the running app on simulators
2. **Python script (Pillow)** composites final images with gradient header + caption text

## Phase 1: Integration Test

**File:** `brainy-app/integration_test/screenshot_test.dart`

### Test Setup

The test must handle several prerequisites before capturing screenshots:

1. **Firebase mock/init:** Use `setupFirebaseAnalyticsMocks()` or `Firebase.initializeApp()` with test options to prevent crashes from `FirebaseAnalytics` / `FirebaseCrashlytics` used in router and main.
2. **Hive initialization:** Register adapters (`GameSessionAdapter`, `UserProgressAdapter`, `CharacterDataAdapter`), open all required boxes (`sessionsBox`, `recordsBox`, `userBox`, `characterBox`, `progressBox`).
3. **Onboarding bypass:** Set `Hive.box(AppConstants.userBox).put(AppConstants.userKeyOnboardingCompleted, true)` so the router redirects `/onboarding` → `/home`.
4. **Parent PIN bypass:** Set `parentPinVerifiedSession = true` (imported from `parent_provider.dart`) before navigating to parent screens.
5. **Custom router:** Create a test-specific `GoRouter` without `FirebaseAnalyticsObserver` to avoid Firebase dependency. Keep the same routes and redirect logic.

### Mock State (via Riverpod overrides + Hive seeding)

**UserProgress (Hive `progressBox`):**

| Field | Value |
|---|---|
| coins | 350 |
| currentStreak | 15 |
| longestStreak | 15 |
| level | 10 |
| xp | 1500 |
| activeCharacterId | "brainy" |
| unlockedAchievements | ["first_game", "personal_record", "streak_3", "streak_7", "speed_demon"] |

**GameSession (Hive `sessionsBox`):** Seed ~20 sessions over the past 15 days so progress screen and parent dashboard show meaningful data. Example session:

| Field | Value |
|---|---|
| id | "session_1" (unique per session) |
| gridSize | 5 |
| durationSeconds | 18 |
| mistakesCount | 1 |
| isPersonalRecord | true |
| mode | "classic" |
| coinsEarned | 25 |
| playedAt | today (vary across past 15 days) |

**Records (Hive `recordsBox`):** Seed best times: `{3: 7, 4: 14, 5: 18}`.

**Characters (Hive `characterBox`):** Seed `CharacterData` objects — Brainy unlocked (selected), Zap unlocked (level >= 10 check uses `>=`), others locked.

**Providers:** Override `userProgressProvider` and `characterProvider` via `ProviderScope(overrides: [...])` to read from the seeded Hive boxes.

### Screens Captured

| # | Screen | Route | Special Handling |
|---|---|---|---|
| 1 | home | `/home` | Standard navigation. Shows character, play button, coins, streak, last result. |
| 2 | game | `/game?size=5` | After navigation, wait for countdown to finish, then programmatically tap numbers 1-8 via `tester.tap()` to show mid-game state (8 of 25 found). Take screenshot before tapping more. |
| 3 | result | `/result` with `extra` | Navigate directly with `extra: { 'session': mockSession, 'isRecord': true, 'xpEarned': 25, 'totalXp': 1500, 'level': 10, 'newAchievements': [firstGame] }`. Wait for animations (confetti, stars) to settle (~2s). |
| 4 | characters | `/character` | Standard navigation. Brainy selected, Zap unlocked, others locked with grayscale. |
| 5 | progress | `/progress` | Standard navigation. Shows level card, stats, achievements (5/10), records. |
| 6 | parent | `/parent/dashboard` | Set `parentPinVerifiedSession = true` first. Shows weekly summary, progress chart, best results. |

### Locale Switching

The test creates the app with explicit locale override:
```dart
MaterialApp.router(
  locale: Locale(testLocale), // 'ru' or 'en'
  localizationsDelegates: [...],
  ...
)
```

Run the full test twice per simulator — once with `ru`, once with `en`. Locale passed via environment variable or test parameter.

### Raw Screenshot Output

Path: `brainy-app/screenshots/raw/{device}/{locale}/{screen_name}.png`

Device dimension included in path to prevent overwrites between simulator runs.

Screen names: `home`, `game`, `result`, `characters`, `progress`, `parent`.

## Phase 2: Python Compositing Script

**File:** `brainy-app/scripts/compose_screenshots.py`

### Dependencies

- Python 3, Pillow
- Nunito Bold font file (from `brainy-app/assets/fonts/Nunito-Bold.ttf` — already bundled with the app)

### Output Layout

Final image at target resolution (e.g., 1290×2796 for 6.7"):

```
┌─────────────────────┐
│                     │
│  Caption text       │  ~15% height
│  (white, centered)  │  gradient #6C5CE7 → #00CEC9
│                     │
├─────────────────────┤
│                     │
│                     │
│   Raw screenshot    │  ~85% height
│   (scaled to fit)   │  app background color #0D0D1A
│                     │
│                     │
└─────────────────────┘
```

- Caption area: gradient from primary purple (#6C5CE7) to teal (#00CEC9), horizontal
- Text: white, Nunito Bold, auto-sized to fit width with padding
- Screenshot: centered, scaled proportionally to fill width, cropped if needed

### Captions

| # | Screen | RU | EN |
|---|---|---|---|
| 1 | home | Тренируй внимание каждый день | Train your focus daily |
| 2 | game | Таблицы Шульте от 3×3 до 9×9 | Schulte tables from 3×3 to 9×9 |
| 3 | result | Ставь рекорды и получай звёзды | Set records and earn stars |
| 4 | characters | Собирай персонажей | Collect characters |
| 5 | progress | Следи за прогрессом | Track your progress |
| 6 | parent | Контроль для родителей | Parent controls |

### Device Sizes

| App Store Slot | Simulator | Resolution |
|---|---|---|
| 6.7" | iPhone 15 Pro Max | 1290 × 2796 |
| 6.5" | iPhone 11 Pro Max | 1242 × 2688 |

Note: The 6.5" slot requires 1242×2688 resolution (iPhone 11 Pro Max class). iPhone 14 Plus produces 6.7" class screenshots despite having a different resolution.

### Output

Final screenshots: `brainy-app/screenshots/final/{device}/{locale}/{screen_name}.png`

## Running

```bash
# Step 1: Raw screenshots
cd brainy-app

# 6.7" device
flutter test integration_test/screenshot_test.dart -d "iPhone 15 Pro Max" --dart-define=LOCALE=ru
flutter test integration_test/screenshot_test.dart -d "iPhone 15 Pro Max" --dart-define=LOCALE=en

# 6.5" device
flutter test integration_test/screenshot_test.dart -d "iPhone 11 Pro Max" --dart-define=LOCALE=ru
flutter test integration_test/screenshot_test.dart -d "iPhone 11 Pro Max" --dart-define=LOCALE=en

# Step 2: Compose final images
python3 scripts/compose_screenshots.py
```

## Deliverables

- 24 final PNG files ready for App Store Connect upload
- Repeatable pipeline: change app → re-run → new screenshots
