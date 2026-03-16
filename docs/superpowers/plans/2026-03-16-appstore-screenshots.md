# App Store Screenshots Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate App Store screenshot generation — 6 screens × 2 languages × 2 devices = 24 final images with gradient caption headers.

**Architecture:** Two-phase pipeline. Phase 1: Flutter integration test captures raw screenshots from simulator with mock state seeded into Hive. Phase 2: Python/Pillow script composites final images with gradient header + Nunito Bold caption text.

**Tech Stack:** Flutter integration_test, Riverpod overrides, Hive, Python 3, Pillow

**Spec:** `docs/superpowers/specs/2026-03-15-appstore-screenshots-design.md`

---

## File Structure

| Action | File | Responsibility |
|---|---|---|
| Create | `brainy-app/integration_test/screenshot_test.dart` | Main test: seeds Hive, builds app with locale, navigates screens, takes screenshots |
| Create | `brainy-app/scripts/compose_screenshots.py` | Reads raw PNGs, composites gradient header + caption + screenshot |
| Create | `brainy-app/scripts/requirements.txt` | Pillow dependency |
| Fix | `brainy-app/assets/fonts/Nunito-Bold.ttf` | Currently an HTML file, needs to be a real TTF |
| Create | `brainy-app/screenshots/.gitkeep` | Output directory for screenshots |

---

## Chunk 1: Fix Font + Integration Test

### Task 1: Fix Nunito-Bold.ttf font file

The file at `brainy-app/assets/fonts/Nunito-Bold.ttf` is currently an HTML page from GitHub, not a real TTF font. This will break both the Flutter app and the Python compositing script.

**Files:**
- Fix: `brainy-app/assets/fonts/Nunito-Bold.ttf`
- Fix: `brainy-app/assets/fonts/Nunito-ExtraBold.ttf` (likely same issue)
- Fix: `brainy-app/assets/fonts/Nunito-Regular.ttf` (likely same issue)

- [ ] **Step 1: Check all font files**

```bash
cd /Users/thatguy/src/brainy/brainy-app
file assets/fonts/Nunito-Bold.ttf
file assets/fonts/Nunito-ExtraBold.ttf
file assets/fonts/Nunito-Regular.ttf
```

Expected: some or all will say "HTML document" instead of "TrueType Font"

- [ ] **Step 2: Download real font files from Google Fonts**

```bash
cd /Users/thatguy/src/brainy/brainy-app/assets/fonts
curl -L -o Nunito-Regular.ttf "https://github.com/google/fonts/raw/main/ofl/nunito/static/Nunito-Regular.ttf"
curl -L -o Nunito-Bold.ttf "https://github.com/google/fonts/raw/main/ofl/nunito/static/Nunito-Bold.ttf"
curl -L -o Nunito-ExtraBold.ttf "https://github.com/google/fonts/raw/main/ofl/nunito/static/Nunito-ExtraBold.ttf"
```

- [ ] **Step 3: Verify they are real TTF files**

```bash
file assets/fonts/Nunito-Bold.ttf
```

Expected: `TrueType Font data` or similar

- [ ] **Step 4: Commit**

```bash
git add assets/fonts/Nunito-Bold.ttf assets/fonts/Nunito-ExtraBold.ttf assets/fonts/Nunito-Regular.ttf
git commit -m "fix: replace broken font files with real Nunito TTFs"
```

---

### Task 2: Create screenshot integration test

**Files:**
- Create: `brainy-app/integration_test/screenshot_test.dart`

**Key references (read before coding):**
- `lib/main.dart` — app bootstrap, Hive init, Firebase init
- `lib/app/router.dart` — routes, onboarding redirect, parent PIN guard
- `lib/constants/app_constants.dart` — Hive box names, keys
- `lib/models/user_progress.dart` — UserProgress fields
- `lib/models/session.dart` — GameSession fields + adapter
- `lib/models/character.dart` — CharacterData fields + adapter
- `lib/features/character/data/characters_data.dart` — defaultCharacters list
- `lib/features/game/providers/game_provider.dart` — GameState, countdown, tap handling
- `lib/features/parent/providers/parent_provider.dart` — parentPinVerifiedSession

- [ ] **Step 1: Create the test file with imports and helpers**

```dart
// integration_test/screenshot_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/app_colors.dart';
import 'package:brainy/app/theme.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/achievement.dart';
import 'package:brainy/features/character/data/characters_data.dart';
import 'package:brainy/features/parent/providers/parent_provider.dart';
import 'package:brainy/features/home/screens/home_screen.dart';
import 'package:brainy/features/game/screens/game_screen.dart';
import 'package:brainy/features/game/screens/result_screen.dart';
import 'package:brainy/features/character/screens/character_screen.dart';
import 'package:brainy/features/progress/screens/progress_screen.dart';
import 'package:brainy/features/parent/screens/parent_dashboard_screen.dart';
import 'package:brainy/features/parent/screens/parent_pin_screen.dart';
import 'package:brainy/features/parent/screens/parent_settings_screen.dart';
import 'package:brainy/features/onboarding/screens/onboarding_screen.dart';
import 'package:brainy/features/league/screens/league_screen.dart';
import 'package:brainy/features/subscription/screens/paywall_screen.dart';
import 'package:brainy/features/character/screens/accessories_screen.dart';
import 'package:brainy/features/progress/screens/grid_detail_screen.dart';
import 'package:brainy/app/main_shell.dart';

/// Locale passed via --dart-define=LOCALE=ru (default: ru)
const _locale = String.fromEnvironment('LOCALE', defaultValue: 'ru');

/// Device name for output path (detected from screen size at runtime)
String _deviceName = 'unknown';

/// Save a screenshot to screenshots/raw/{device}/{locale}/{name}.png
Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pumpAndSettle();
  final dir = Directory('screenshots/raw/$_deviceName/$_locale');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // Use binding.takeScreenshot which works on iOS simulators
  final bytes = await binding.takeScreenshot(name);
  File('${dir.path}/$name.png').writeAsBytesSync(bytes);
}

/// Create a test GoRouter without FirebaseAnalyticsObserver
GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final box = Hive.box(AppConstants.userBox);
      final completed =
          box.get(AppConstants.userKeyOnboardingCompleted) as bool? ?? false;
      if (completed && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      if (!state.matchedLocation.startsWith('/parent')) {
        parentPinVerifiedSession = false;
      }
      if (state.matchedLocation == '/parent/dashboard' ||
          state.matchedLocation == '/parent/settings') {
        if (!parentPinVerifiedSession) {
          return '/parent/pin';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/game',
            builder: (context, state) {
              final gridSize =
                  int.tryParse(state.uri.queryParameters['size'] ?? '') ?? 5;
              final mode = state.uri.queryParameters['mode'] ?? 'classic';
              return GameScreen(gridSize: gridSize, mode: mode);
            },
          ),
          GoRoute(
            path: '/result',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ResultScreen(extra: extra);
            },
          ),
          GoRoute(
            path: '/character',
            builder: (context, state) => const CharacterScreen(),
          ),
          GoRoute(
            path: '/accessories',
            builder: (context, state) => const AccessoriesScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/league',
            builder: (context, state) => const LeagueScreen(),
          ),
          GoRoute(
            path: '/progress/grid-detail',
            builder: (context, state) {
              final size =
                  int.tryParse(state.uri.queryParameters['size'] ?? '') ?? 5;
              return GridDetailScreen(gridSize: size);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/parent/pin',
        builder: (context, state) => const ParentPinScreen(),
      ),
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/parent/settings',
        builder: (context, state) => const ParentSettingsScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
}

/// Seed Hive boxes with mock data for beautiful screenshots
Future<void> _seedMockData() async {
  // UserProgress
  final progressBox = Hive.box<UserProgress>(AppConstants.progressBox);
  final progress = UserProgress(
    coins: 350,
    xp: 1500,
    level: 10,
    currentStreak: 15,
    longestStreak: 15,
    lastPlayedDate: DateTime.now(),
    childAge: '10-12',
    goals: ['concentration', 'reading'],
    dailyGoalMinutes: 10,
    activeCharacterId: 'brainy',
    lastSelectedGridSize: 5,
    unlockedAchievements: [
      'first_game',
      'personal_record',
      'streak_3',
      'streak_7',
      'speed_demon',
    ],
  );
  await progressBox.put(AppConstants.progressDataKey, progress);

  // Sessions — seed 20 over past 15 days
  final sessionsBox = Hive.box<GameSession>(AppConstants.sessionsBox);
  final now = DateTime.now();
  for (int i = 0; i < 20; i++) {
    final session = GameSession(
      id: 'screenshot_session_$i',
      playedAt: now.subtract(Duration(days: i % 15, hours: i)),
      gridSize: [3, 4, 5][i % 3],
      durationSeconds: 15 + (i * 2) % 20,
      mistakesCount: i % 3,
      isPersonalRecord: i == 0,
      mode: 'classic',
      coinsEarned: 10 + (i % 3) * 5,
    );
    await sessionsBox.put(session.id, session);
  }

  // Records
  final recordsBox = Hive.box<int>(AppConstants.recordsBox);
  await recordsBox.put('3', 7);
  await recordsBox.put('4', 14);
  await recordsBox.put('5', 18);

  // Characters — Brainy + Zap unlocked
  final characterBox = Hive.box<CharacterData>(AppConstants.characterBox);
  for (final info in defaultCharacters) {
    final data = CharacterData(
      id: info.id,
      nameRu: info.nameRu,
      nameEn: info.nameEn,
      isUnlocked: info.id == 'brainy' || info.id == 'zap',
    );
    await characterBox.put(info.id, data);
  }

  // Onboarding completed
  final userBox = Hive.box(AppConstants.userBox);
  await userBox.put(AppConstants.userKeyOnboardingCompleted, true);

  // Sound/haptic off for screenshots (no audio issues in test)
  await userBox.put(AppConstants.soundEnabledKey, false);
  await userBox.put(AppConstants.hapticEnabledKey, false);
}
```

- [ ] **Step 2: Add the main test function**

Append to the same file:

```dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Init Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Capture App Store screenshots ($_locale)', (tester) async {
    // Detect device name from screen size
    final size = tester.view.physicalSize;
    if (size.width >= 1290) {
      _deviceName = '6.7';
    } else {
      _deviceName = '6.5';
    }

    await _seedMockData();

    final testRouter = _createTestRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'Brainy',
          theme: AppTheme.darkTheme,
          routerConfig: testRouter,
          locale: Locale(_locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru'),
            Locale('en'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // --- Screen 1: Home ---
    await _takeScreenshot(binding, tester, 'home');

    // --- Screen 2: Game (mid-game) ---
    testRouter.go('/game?size=5');
    await tester.pumpAndSettle();
    // Wait for countdown (3 seconds)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    // Tap first 8 numbers to show mid-game state
    for (int num = 1; num <= 8; num++) {
      final finder = find.text('$num');
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'game');

    // --- Screen 3: Result (3 stars, record) ---
    final mockSession = GameSession(
      id: 'screenshot_result',
      playedAt: DateTime.now(),
      gridSize: 5,
      durationSeconds: 18,
      mistakesCount: 0,
      isPersonalRecord: true,
      mode: 'classic',
      coinsEarned: 25,
    );
    testRouter.go('/result', extra: {
      'session': mockSession,
      'isRecord': true,
      'xpEarned': 25,
      'totalXp': 1500,
      'level': 10,
      'newAchievements': <AchievementDef>[
        allAchievements.firstWhere((a) => a.id == AchievementId.firstGame),
      ],
    });
    // Wait for animations (confetti runs 3s, stars pop in, coins counter)
    // NOTE: Do NOT use pumpAndSettle() here — ConfettiWidget's particle
    // system may never "settle", causing a timeout. Use explicit pumps.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await _takeScreenshot(binding, tester, 'result');

    // --- Screen 4: Characters ---
    testRouter.go('/character');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'characters');

    // --- Screen 5: Progress ---
    testRouter.go('/progress');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'progress');

    // --- Screen 6: Parent Dashboard ---
    parentPinVerifiedSession = true;
    testRouter.go('/parent/dashboard');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'parent');
  });
}
```

- [ ] **Step 3: Verify the test compiles**

```bash
cd /Users/thatguy/src/brainy/brainy-app
flutter test integration_test/screenshot_test.dart --no-pub 2>&1 | head -20
```

Expected: compilation errors related to Firebase (not import errors). We'll handle those in the next step.

Note: The test intentionally does NOT import Firebase. If compilation fails due to transitive Firebase dependencies in the app code, we may need to conditionally exclude Firebase initialization. Address compilation errors as they arise — the most likely fix is adding `firebase_core` to dev_dependencies or using `Firebase.initializeApp()` in setUpAll with a try-catch.

- [ ] **Step 4: Commit**

```bash
git add integration_test/screenshot_test.dart
git commit -m "feat: add integration test for App Store screenshots"
```

---

## Chunk 2: Python Compositing Script

### Task 3: Create the Python compositing script

**Files:**
- Create: `brainy-app/scripts/compose_screenshots.py`
- Create: `brainy-app/scripts/requirements.txt`

**Key reference:** Spec section "Phase 2: Python Compositing Script"

- [ ] **Step 1: Create requirements.txt**

```
Pillow>=10.0
```

Save to `brainy-app/scripts/requirements.txt`.

- [ ] **Step 2: Create compose_screenshots.py**

```python
#!/usr/bin/env python3
"""
Compose App Store screenshots with gradient header and caption text.

Reads raw screenshots from screenshots/raw/{device}/{locale}/{name}.png
Outputs final images to screenshots/final/{device}/{locale}/{name}.png
"""
import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

# --- Configuration ---

SCRIPT_DIR = Path(__file__).parent
PROJECT_DIR = SCRIPT_DIR.parent
RAW_DIR = PROJECT_DIR / "screenshots" / "raw"
FINAL_DIR = PROJECT_DIR / "screenshots" / "final"
FONT_PATH = PROJECT_DIR / "assets" / "fonts" / "Nunito-Bold.ttf"

DEVICES = {
    "6.7": (1290, 2796),
    "6.5": (1242, 2688),
}

SCREENS = ["home", "game", "result", "characters", "progress", "parent"]

CAPTIONS = {
    "ru": {
        "home": "Тренируй внимание каждый день",
        "game": "Таблицы Шульте от 3×3 до 9×9",
        "result": "Ставь рекорды и получай звёзды",
        "characters": "Собирай персонажей",
        "progress": "Следи за прогрессом",
        "parent": "Контроль для родителей",
    },
    "en": {
        "home": "Train your focus daily",
        "game": "Schulte tables from 3×3 to 9×9",
        "result": "Set records and earn stars",
        "characters": "Collect characters",
        "progress": "Track your progress",
        "parent": "Parent controls",
    },
}

# Colors
COLOR_PRIMARY = (108, 92, 231)     # #6C5CE7
COLOR_SECONDARY = (0, 206, 201)    # #00CEC9
COLOR_BG = (13, 13, 26)           # #0D0D1A
COLOR_WHITE = (255, 255, 255)

HEADER_RATIO = 0.15  # Top 15% for caption


def create_gradient(width: int, height: int) -> Image.Image:
    """Create a horizontal gradient from primary to secondary color."""
    # Render a 1-pixel-high line then stretch vertically (fast)
    line = Image.new("RGB", (width, 1))
    for x in range(width):
        ratio = x / max(width - 1, 1)
        r = int(COLOR_PRIMARY[0] + (COLOR_SECONDARY[0] - COLOR_PRIMARY[0]) * ratio)
        g = int(COLOR_PRIMARY[1] + (COLOR_SECONDARY[1] - COLOR_PRIMARY[1]) * ratio)
        b = int(COLOR_PRIMARY[2] + (COLOR_SECONDARY[2] - COLOR_PRIMARY[2]) * ratio)
        line.putpixel((x, 0), (r, g, b))
    return line.resize((width, height), Image.NEAREST)


def find_font_size(draw: ImageDraw.ImageDraw, text: str, font_path: str,
                   max_width: int, max_height: int) -> ImageFont.FreeTypeFont:
    """Find the largest font size that fits within max_width and max_height."""
    size = 80
    while size > 20:
        font = ImageFont.truetype(str(font_path), size)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]
        if text_w <= max_width and text_h <= max_height:
            return font
        size -= 2
    return ImageFont.truetype(str(font_path), 20)


def compose_screenshot(raw_path: Path, output_path: Path,
                       caption: str, target_w: int, target_h: int) -> None:
    """Compose a single final screenshot."""
    header_h = int(target_h * HEADER_RATIO)
    body_h = target_h - header_h

    # Create final image
    final = Image.new("RGB", (target_w, target_h), COLOR_BG)

    # Draw gradient header
    gradient = create_gradient(target_w, header_h)
    final.paste(gradient, (0, 0))

    # Draw caption text
    draw = ImageDraw.Draw(final)
    padding = int(target_w * 0.08)
    font = find_font_size(draw, caption, FONT_PATH,
                          target_w - padding * 2, header_h - padding)
    bbox = draw.textbbox((0, 0), caption, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    text_x = (target_w - text_w) // 2
    text_y = (header_h - text_h) // 2 - bbox[1]  # correct for font top bearing
    draw.text((text_x, text_y), caption, fill=COLOR_WHITE, font=font)

    # Scale and paste raw screenshot
    raw = Image.open(raw_path).convert("RGB")  # drop alpha channel if present
    raw_ratio = raw.width / raw.height
    body_ratio = target_w / body_h

    if raw_ratio > body_ratio:
        # Wider than target: fit to width, crop height
        new_w = target_w
        new_h = int(target_w / raw_ratio)
    else:
        # Taller than target: fit to height, center horizontally
        new_h = body_h
        new_w = int(body_h * raw_ratio)

    raw_resized = raw.resize((new_w, min(new_h, body_h)), Image.LANCZOS)
    paste_x = max(0, (target_w - raw_resized.width) // 2)
    paste_y = header_h + max(0, (body_h - raw_resized.height) // 2)
    final.paste(raw_resized, (paste_x, paste_y))

    # Save
    output_path.parent.mkdir(parents=True, exist_ok=True)
    final.save(output_path, "PNG")
    print(f"  ✓ {output_path.relative_to(PROJECT_DIR)}")


def main():
    if not FONT_PATH.exists():
        print(f"ERROR: Font not found at {FONT_PATH}")
        return

    if not RAW_DIR.exists():
        print(f"ERROR: Raw screenshots directory not found at {RAW_DIR}")
        print("Run the Flutter integration test first.")
        return

    count = 0
    for device, (target_w, target_h) in DEVICES.items():
        for locale in ["ru", "en"]:
            raw_locale_dir = RAW_DIR / device / locale
            if not raw_locale_dir.exists():
                print(f"  Skipping {device}/{locale} — no raw screenshots")
                continue

            print(f"\n{device} / {locale}:")
            for screen in SCREENS:
                raw_path = raw_locale_dir / f"{screen}.png"
                if not raw_path.exists():
                    print(f"  ✗ Missing: {raw_path.relative_to(PROJECT_DIR)}")
                    continue

                caption = CAPTIONS[locale][screen]
                output_path = FINAL_DIR / device / locale / f"{screen}.png"
                compose_screenshot(raw_path, output_path, caption,
                                   target_w, target_h)
                count += 1

    print(f"\nDone! {count} screenshots composed.")


if __name__ == "__main__":
    main()
```

- [ ] **Step 3: Make script executable**

```bash
chmod +x scripts/compose_screenshots.py
```

- [ ] **Step 4: Create screenshots output directory**

```bash
mkdir -p screenshots/raw screenshots/final
printf '*\n!.gitkeep\n' > screenshots/raw/.gitignore
printf '*\n!.gitignore\n' > screenshots/final/.gitignore
```

- [ ] **Step 5: Install Pillow and test script runs without errors**

```bash
pip3 install Pillow
cd /Users/thatguy/src/brainy/brainy-app
python3 scripts/compose_screenshots.py
```

Expected: `ERROR: Raw screenshots directory not found` (no raw screenshots yet — this is correct)

- [ ] **Step 6: Commit**

```bash
git add scripts/compose_screenshots.py scripts/requirements.txt screenshots/
git commit -m "feat: add Python script for compositing App Store screenshots"
```

---

## Chunk 3: Run Pipeline End-to-End

### Task 4: Run integration test on simulators

- [ ] **Step 1: Boot the 6.7" simulator**

```bash
xcrun simctl boot "iPhone 15 Pro Max" 2>/dev/null || true
```

- [ ] **Step 2: Run screenshot test — RU, 6.7"**

```bash
cd /Users/thatguy/src/brainy/brainy-app
flutter test integration_test/screenshot_test.dart -d "iPhone 15 Pro Max" --dart-define=LOCALE=ru
```

Expected: test passes, screenshots saved to `screenshots/raw/6.7/ru/`

- [ ] **Step 3: Run screenshot test — EN, 6.7"**

```bash
flutter test integration_test/screenshot_test.dart -d "iPhone 15 Pro Max" --dart-define=LOCALE=en
```

Expected: screenshots saved to `screenshots/raw/6.7/en/`

- [ ] **Step 4: Shutdown 6.7" simulator, boot 6.5" simulator**

```bash
xcrun simctl shutdown "iPhone 15 Pro Max" 2>/dev/null || true
xcrun simctl boot "iPhone 11 Pro Max" 2>/dev/null || true
```

If this simulator doesn't exist, create it:
```bash
xcrun simctl create "iPhone 11 Pro Max" "iPhone 11 Pro Max"
```

- [ ] **Step 5: Run screenshot test — RU, 6.5"**

```bash
flutter test integration_test/screenshot_test.dart -d "iPhone 11 Pro Max" --dart-define=LOCALE=ru
```

- [ ] **Step 6: Run screenshot test — EN, 6.5"**

```bash
flutter test integration_test/screenshot_test.dart -d "iPhone 11 Pro Max" --dart-define=LOCALE=en
```

- [ ] **Step 7: Verify raw screenshots exist**

```bash
find screenshots/raw -name "*.png" | sort
```

Expected: 24 files (6 screens × 2 locales × 2 devices)

---

### Task 5: Compose final screenshots and verify

- [ ] **Step 1: Run compositing script**

```bash
cd /Users/thatguy/src/brainy/brainy-app
python3 scripts/compose_screenshots.py
```

Expected: 24 checkmarks, `Done! 24 screenshots composed.`

- [ ] **Step 2: Verify final screenshots exist with correct sizes**

```bash
cd /Users/thatguy/src/brainy/brainy-app
python3 -c "
from PIL import Image
from pathlib import Path
for f in sorted(Path('screenshots/final').rglob('*.png')):
    img = Image.open(f)
    print(f'{f}: {img.size[0]}x{img.size[1]}')
"
```

Expected: 6.7 files are 1290×2796, 6.5 files are 1242×2688

- [ ] **Step 3: Open a few screenshots to visually verify**

```bash
open screenshots/final/6.7/ru/home.png
open screenshots/final/6.7/en/result.png
```

Visually confirm: gradient header with text on top, screenshot below, correct caption language.

- [ ] **Step 4: Commit the test infrastructure**

```bash
git add integration_test/ scripts/ screenshots/.gitignore
git commit -m "feat: complete App Store screenshot pipeline (test + compositing)"
```

---

## Troubleshooting

**Firebase crash in test:** If the test crashes due to Firebase, wrap any Firebase calls in try-catch or add this to `setUpAll`:
```dart
try {
  await Firebase.initializeApp();
} catch (_) {
  // Firebase not available in test — that's OK
}
```

**Countdown timing issues:** If numbers 1-8 can't be found after countdown, increase the pump duration or use `tester.pumpAndSettle(timeout: Duration(seconds: 10))`.

**Game screen numbers already removed:** The `find.text('1')` finder might match numbers in other widgets. Use `find.descendant(of: find.byType(SchulteGrid), matching: find.text('1'))` for precision.

**Result screen redirects to /game:** This happens if `extra` is null or `session` is not a `GameSession`. Verify the mock session is passed correctly via `extra` map.
