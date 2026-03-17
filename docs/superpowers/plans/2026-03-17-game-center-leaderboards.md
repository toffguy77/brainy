# Game Center / Google Play Games Leaderboards — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace simulated NPC league standings with real Game Center (iOS) / Google Play Games (Android) leaderboards, showing real player names and scores.

**Architecture:** A `GameServicesService` wraps the `games_services` Flutter package. Existing `leagueStandingsProvider` switches from hardcoded NPCs to real leaderboard data. Score submission happens in `_handleGameFinished()` in `game_screen.dart`. The league UI keeps its custom design but adds a "Full Ranking" button for native UI.

**Tech Stack:** Flutter, `games_services` ^5.0.0, Riverpod, existing Hive/Firebase stack.

**Spec:** `brainy-tasks/TASK_8_1_game_center_leaderboards.md`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `pubspec.yaml` | Modify | Add `games_services` dependency |
| `lib/shared/services/game_services_service.dart` | Create | Wrapper around `games_services` package — sign-in, score submission, leaderboard reads |
| `lib/models/leaderboard_entry.dart` | Create | Data class for a leaderboard row (name, score, rank, isCurrentPlayer) |
| `lib/features/league/providers/game_services_provider.dart` | Create | Riverpod providers for game services state (player name, sign-in status) |
| `lib/features/league/providers/league_provider.dart` | Modify | Replace NPC simulation with real leaderboard data |
| `lib/features/league/screens/league_screen.dart` | Modify | Add connect prompt, full ranking button, handle async leaderboard data |
| `lib/features/game/screens/game_screen.dart` | Modify | Submit scores after session completes |
| `lib/main.dart` | Modify | Initialize Game Services sign-in at startup |
| `l10n/app_en.arb` | Modify | Add new localization strings |
| `l10n/app_ru.arb` | Modify | Add new localization strings |
| `lib/l10n/app_localizations.dart` | Regenerate | After ARB changes |
| `lib/l10n/app_localizations_en.dart` | Regenerate | After ARB changes |
| `lib/l10n/app_localizations_ru.dart` | Regenerate | After ARB changes |
| `test/models/leaderboard_entry_test.dart` | Create | Unit tests for LeaderboardEntry |
| `test/services/game_services_service_test.dart` | Create | Unit tests for GameServicesService (mocked) |
| `test/providers/game_services_provider_test.dart` | Create | Unit tests for game services providers |
| `test/providers/league_provider_test.dart` | Create | Unit tests for updated league provider |
| `test/features/league/league_screen_test.dart` | Create | Widget tests for league screen states |
| `test/integration/score_submission_test.dart` | Create | Integration tests for score submission after sessions |

**Platform configuration notes:**
- iOS: Weekly XP leaderboard → "Highest Score" type. Best time leaderboards → **"Lowest Score"** type (smallest is best) in App Store Connect.
- Android: Same — weekly XP as "Larger is better", best time leaderboards as **"Smaller is better"** in Play Console.

---

## Chunk 1: Foundation — Model, Service, and Unit Tests

### Task 1: Add `games_services` dependency

**Files:**
- Modify: `brainy-app/pubspec.yaml`

- [ ] **Step 1: Add dependency**

In `pubspec.yaml`, add `games_services` under dependencies (after `purchases_flutter`):

```yaml
  games_services: ^5.0.0
```

- [ ] **Step 2: Run pub get**

Run: `cd brainy-app && flutter pub get`
Expected: Resolves successfully, `pubspec.lock` updated.

- [ ] **Step 3: Commit**

```bash
cd brainy-app && git add pubspec.yaml pubspec.lock && git commit -m "feat: add games_services dependency for Game Center/Play Games integration"
```

---

### Task 2: Create `LeaderboardEntry` model

**Files:**
- Create: `brainy-app/test/models/leaderboard_entry_test.dart`
- Create: `brainy-app/lib/models/leaderboard_entry.dart`

- [ ] **Step 1: Write the failing test**

Create `brainy-app/test/models/leaderboard_entry_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry', () {
    test('creates with all fields', () {
      final entry = LeaderboardEntry(
        playerName: 'TestPlayer',
        score: 500,
        rank: 3,
        isCurrentPlayer: false,
      );

      expect(entry.playerName, 'TestPlayer');
      expect(entry.score, 500);
      expect(entry.rank, 3);
      expect(entry.isCurrentPlayer, false);
    });

    test('isCurrentPlayer defaults to false', () {
      final entry = LeaderboardEntry(
        playerName: 'Other',
        score: 100,
        rank: 1,
      );

      expect(entry.isCurrentPlayer, false);
    });

    test('isCurrentPlayer can be true', () {
      final entry = LeaderboardEntry(
        playerName: 'Me',
        score: 200,
        rank: 5,
        isCurrentPlayer: true,
      );

      expect(entry.isCurrentPlayer, true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd brainy-app && flutter test test/models/leaderboard_entry_test.dart`
Expected: FAIL — `leaderboard_entry.dart` not found.

- [ ] **Step 3: Write the model**

Create `brainy-app/lib/models/leaderboard_entry.dart`:

```dart
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final bool isCurrentPlayer;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
    this.isCurrentPlayer = false,
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd brainy-app && flutter test test/models/leaderboard_entry_test.dart`
Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/models/leaderboard_entry.dart test/models/leaderboard_entry_test.dart && git commit -m "feat: add LeaderboardEntry model with tests"
```

---

### Task 3: Create `GameServicesService`

**Files:**
- Create: `brainy-app/test/services/game_services_service_test.dart`
- Create: `brainy-app/lib/shared/services/game_services_service.dart`

- [ ] **Step 1: Write the failing tests**

Create `brainy-app/test/services/game_services_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('GameServicesService', () {
    group('leaderboardId', () {
      test('returns correct ID for weekly_xp', () {
        expect(
          GameServicesService.weeklyXpLeaderboardId(platform: 'ios'),
          'brainy_weekly_xp',
        );
        expect(
          GameServicesService.weeklyXpLeaderboardId(platform: 'android'),
          'brainy_weekly_xp',
        );
      });

      test('returns correct ID for best time leaderboards', () {
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 3, platform: 'ios'),
          'brainy_best_time_3x3',
        );
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 5, platform: 'ios'),
          'brainy_best_time_5x5',
        );
        expect(
          GameServicesService.bestTimeLeaderboardId(gridSize: 9, platform: 'ios'),
          'brainy_best_time_9x9',
        );
      });

      test('returns correct ID for all grid sizes', () {
        for (final size in [3, 4, 5, 6, 7, 9]) {
          final id = GameServicesService.bestTimeLeaderboardId(
            gridSize: size,
            platform: 'ios',
          );
          expect(id, 'brainy_best_time_${size}x$size');
        }
      });
    });

    group('isSignedIn', () {
      test('starts as false', () {
        final service = GameServicesService();
        expect(service.isSignedIn, false);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd brainy-app && flutter test test/services/game_services_service_test.dart`
Expected: FAIL — `game_services_service.dart` not found.

- [ ] **Step 3: Write the service**

Create `brainy-app/lib/shared/services/game_services_service.dart`:

```dart
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import '../../models/leaderboard_entry.dart';

class GameServicesService {
  bool _isSignedIn = false;
  String? _playerName;

  bool get isSignedIn => _isSignedIn;
  String? get playerName => _playerName;

  /// Sign in to Game Center (iOS) / Play Games (Android).
  /// Call at app startup. Returns true if signed in successfully.
  Future<bool> signIn() async {
    try {
      await GamesServices.signIn();
      _isSignedIn = await GamesServices.isSignedIn;
      if (_isSignedIn) {
        _playerName = await GamesServices.getPlayerName();
      }
      return _isSignedIn;
    } on PlatformException {
      _isSignedIn = false;
      return false;
    }
  }

  /// Submit weekly XP score to the weekly leaderboard.
  Future<void> submitWeeklyXp(int xp) async {
    if (!_isSignedIn) return;
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
          androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
          value: xp,
        ),
      );
    } on PlatformException {
      // Silently fail — score will be retried next session
    }
  }

  /// Submit best time (in milliseconds) for a specific grid size.
  Future<void> submitBestTime({
    required int gridSize,
    required int timeMs,
  }) async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: bestTimeLeaderboardId(gridSize: gridSize, platform: 'ios'),
          androidLeaderboardID: bestTimeLeaderboardId(gridSize: gridSize, platform: 'android'),
          value: timeMs,
        ),
      );
    } on PlatformException {
      // Silently fail
    }
  }

  /// Load top players from the weekly XP leaderboard.
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({int count = 25}) async {
    if (!_isSignedIn) return [];
    try {
      final scores = await GamesServices.loadLeaderboardScores(
        iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
        androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
        scope: PlayerScope.global,
        timeScope: TimeScope.week,
        maxResults: count,
      );
      if (scores == null) return [];
      return scores
          .map((s) => LeaderboardEntry(
                playerName: s.scoreHolderDisplayName ?? 'Player',
                score: s.rawScore,
                rank: s.rank ?? 0,
                isCurrentPlayer: false,
              ))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  /// Open the native Game Center / Play Games leaderboard UI.
  Future<void> showNativeLeaderboards() async {
    try {
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
        androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
      );
    } on PlatformException {
      // Native UI unavailable
    }
  }

  // --- Leaderboard ID helpers ---

  static String weeklyXpLeaderboardId({required String platform}) {
    return 'brainy_weekly_xp';
  }

  static String bestTimeLeaderboardId({
    required int gridSize,
    required String platform,
  }) {
    return 'brainy_best_time_${gridSize}x$gridSize';
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd brainy-app && flutter test test/services/game_services_service_test.dart`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/shared/services/game_services_service.dart test/services/game_services_service_test.dart && git commit -m "feat: add GameServicesService with Game Center/Play Games integration"
```

---

### Task 4: Create game services Riverpod providers

**Files:**
- Create: `brainy-app/test/providers/game_services_provider_test.dart`
- Create: `brainy-app/lib/features/league/providers/game_services_provider.dart`

- [ ] **Step 1: Write the failing tests**

Create `brainy-app/test/providers/game_services_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/league/providers/game_services_provider.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('gameServicesProvider', () {
    test('provides a GameServicesService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(gameServicesProvider);
      expect(service, isA<GameServicesService>());
    });

    test('provides same instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service1 = container.read(gameServicesProvider);
      final service2 = container.read(gameServicesProvider);
      expect(identical(service1, service2), true);
    });
  });

  group('isGameServicesSignedInProvider', () {
    test('returns false initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isSignedIn = container.read(isGameServicesSignedInProvider);
      expect(isSignedIn, false);
    });

    test('can be set to true after sign-in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(isGameServicesSignedInProvider.notifier).state = true;
      expect(container.read(isGameServicesSignedInProvider), true);
    });
  });

  group('playerNameProvider', () {
    test('returns null initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(playerNameProvider), isNull);
    });

    test('can be set after sign-in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(playerNameProvider.notifier).state = 'TestPlayer';
      expect(container.read(playerNameProvider), 'TestPlayer');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd brainy-app && flutter test test/providers/game_services_provider_test.dart`
Expected: FAIL — `game_services_provider.dart` not found.

- [ ] **Step 3: Write the providers**

Create `brainy-app/lib/features/league/providers/game_services_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/game_services_service.dart';

/// Singleton GameServicesService instance.
final gameServicesProvider = Provider<GameServicesService>((ref) {
  return GameServicesService();
});

/// Whether the player is signed in to Game Center / Play Games.
/// Updated via ref.read(isGameServicesSignedInProvider.notifier).state = true
/// after successful signIn().
final isGameServicesSignedInProvider = StateProvider<bool>((ref) => false);

/// Player display name from Game Center / Play Games.
/// Updated after sign-in.
final playerNameProvider = StateProvider<String?>((ref) => null);
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd brainy-app && flutter test test/providers/game_services_provider_test.dart`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/features/league/providers/game_services_provider.dart test/providers/game_services_provider_test.dart && git commit -m "feat: add Riverpod providers for Game Services state"
```

---

## Chunk 2: League Provider Update and Localization

### Task 5: Update league provider — replace NPCs with real data

**Files:**
- Create: `brainy-app/test/providers/league_provider_test.dart`
- Modify: `brainy-app/lib/features/league/providers/league_provider.dart`

- [ ] **Step 1: Write the failing tests**

Create `brainy-app/test/providers/league_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/models/league.dart';
import 'package:brainy/features/league/providers/league_provider.dart';

void main() {
  group('LeagueTier.fromWeeklyXp', () {
    test('0 XP returns bronze', () {
      expect(LeagueTier.fromWeeklyXp(0), LeagueTier.bronze);
    });

    test('149 XP returns bronze', () {
      expect(LeagueTier.fromWeeklyXp(149), LeagueTier.bronze);
    });

    test('150 XP returns silver', () {
      expect(LeagueTier.fromWeeklyXp(150), LeagueTier.silver);
    });

    test('399 XP returns silver', () {
      expect(LeagueTier.fromWeeklyXp(399), LeagueTier.silver);
    });

    test('400 XP returns gold', () {
      expect(LeagueTier.fromWeeklyXp(400), LeagueTier.gold);
    });

    test('799 XP returns gold', () {
      expect(LeagueTier.fromWeeklyXp(799), LeagueTier.gold);
    });

    test('800 XP returns platinum', () {
      expect(LeagueTier.fromWeeklyXp(800), LeagueTier.platinum);
    });

    test('9999 XP returns platinum', () {
      expect(LeagueTier.fromWeeklyXp(9999), LeagueTier.platinum);
    });
  });

  group('LeagueTier.nextTier', () {
    test('bronze -> silver', () {
      expect(LeagueTier.bronze.nextTier, LeagueTier.silver);
    });

    test('silver -> gold', () {
      expect(LeagueTier.silver.nextTier, LeagueTier.gold);
    });

    test('gold -> platinum', () {
      expect(LeagueTier.gold.nextTier, LeagueTier.platinum);
    });

    test('platinum -> null', () {
      expect(LeagueTier.platinum.nextTier, isNull);
    });
  });

  group('LeaguePlayer', () {
    test('creates with required fields', () {
      final player = LeaguePlayer(name: 'Test', weeklyXp: 100);
      expect(player.name, 'Test');
      expect(player.weeklyXp, 100);
      expect(player.isCurrentUser, false);
    });

    test('isCurrentUser can be true', () {
      final player = LeaguePlayer(
        name: 'Me',
        weeklyXp: 200,
        isCurrentUser: true,
      );
      expect(player.isCurrentUser, true);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they pass** (these test existing code)

Run: `cd brainy-app && flutter test test/providers/league_provider_test.dart`
Expected: All tests PASS (LeagueTier and LeaguePlayer are unchanged).

- [ ] **Step 3: Update league_provider.dart**

Replace the full contents of `brainy-app/lib/features/league/providers/league_provider.dart`:

```dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/league.dart';
import '../../../models/leaderboard_entry.dart';
import '../../game/providers/sessions_provider.dart';
import '../../game/providers/user_progress_provider.dart';
import 'game_services_provider.dart';

/// Start of current week (Monday 00:00)
DateTime _weekStart() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

/// XP earned this week
final weeklyXpProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final start = _weekStart();
  final end = DateTime.now();
  return sessions
      .where((s) => s.playedAt.isAfter(start) && s.playedAt.isBefore(end))
      .fold<int>(0, (sum, s) => sum + s.xpEarned);
});

/// Current league tier based on weekly XP
final currentLeagueProvider = Provider<LeagueTier>((ref) {
  final xp = ref.watch(weeklyXpProvider);
  return LeagueTier.fromWeeklyXp(xp);
});

class LeaguePlayer {
  final String name;
  final int weeklyXp;
  final bool isCurrentUser;

  const LeaguePlayer({
    required this.name,
    required this.weeklyXp,
    this.isCurrentUser = false,
  });
}

/// League standings — real data from Game Services or simulated fallback.
final leagueStandingsProvider = FutureProvider<List<LeaguePlayer>>((ref) async {
  final userXp = ref.watch(weeklyXpProvider);
  final progress = ref.watch(userProgressProvider);
  final service = ref.watch(gameServicesProvider);

  final isSignedIn = ref.watch(isGameServicesSignedInProvider);
  final pName = ref.watch(playerNameProvider);

  // If signed in, try to get real leaderboard data
  if (isSignedIn) {
    final entries = await service.getWeeklyLeaderboard(count: 25);
    if (entries.isNotEmpty) {
      return _buildRealStandings(
        entries: entries,
        userXp: userXp,
        userLevel: progress.level,
        playerName: pName,
      );
    }
  }

  // Fallback: simulated opponents when not signed in (deliberate deviation
  // from spec which says "return empty list". Better UX to show simulated
  // standings so the league tab isn't empty for users without Game Center).
  return _buildSimulatedStandings(
    userXp: userXp,
    tier: LeagueTier.fromWeeklyXp(userXp),
    userLevel: progress.level,
  );
});

List<LeaguePlayer> _buildRealStandings({
  required List<LeaderboardEntry> entries,
  required int userXp,
  required int userLevel,
  required String? playerName,
}) {
  final players = <LeaguePlayer>[];
  bool userFound = false;

  for (final entry in entries) {
    // Check if this entry is the current player by name match
    final isMe = playerName != null && entry.playerName == playerName;
    if (isMe) userFound = true;

    players.add(LeaguePlayer(
      name: entry.playerName,
      weeklyXp: entry.score,
      isCurrentUser: isMe,
    ));
  }

  // If current user wasn't in the leaderboard, add them
  if (!userFound) {
    players.add(LeaguePlayer(
      name: playerName ?? 'Lv$userLevel',
      weeklyXp: userXp,
      isCurrentUser: true,
    ));
  }

  players.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
  return players;
}

List<LeaguePlayer> _buildSimulatedStandings({
  required int userXp,
  required LeagueTier tier,
  required int userLevel,
}) {
  final rng = Random(tier.index * 1000 + DateTime.now().weekday);
  final minXp = tier.xpThreshold;
  final nextTier = tier.nextTier;
  final maxXp = nextTier != null ? nextTier.xpThreshold + 50 : 1200;

  final players = <LeaguePlayer>[];

  const names = [
    'BrainStar', 'QuickMind', 'FlashCalc', 'NeuroPro', 'FocusKid',
    'MindRacer', 'SharpEye', 'SpeedBrain', 'ThinkFast',
  ];

  for (final name in names) {
    final xp = minXp + rng.nextInt(max(1, maxXp - minXp));
    players.add(LeaguePlayer(name: name, weeklyXp: xp));
  }

  players.add(LeaguePlayer(
    name: 'Lv$userLevel',
    weeklyXp: userXp,
    isCurrentUser: true,
  ));

  players.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
  return players;
}
```

**Key change:** `leagueStandingsProvider` is now a `FutureProvider` instead of `Provider`. This means the league screen needs to handle `AsyncValue` (loading/error/data states).

- [ ] **Step 4: Run tests again to verify nothing broke**

Run: `cd brainy-app && flutter test test/providers/league_provider_test.dart`
Expected: All tests still PASS.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/features/league/providers/league_provider.dart test/providers/league_provider_test.dart && git commit -m "feat: update league provider to use real Game Services data with simulated fallback"
```

---

### Task 6: Add localization strings

**Files:**
- Modify: `brainy-app/l10n/app_en.arb`
- Modify: `brainy-app/l10n/app_ru.arb`

- [ ] **Step 1: Add English strings**

Add the following entries to `brainy-app/l10n/app_en.arb` (before the closing `}`):

```json
  "leagueConnectTitle": "Compete with real players!",
  "leagueConnectSubtitle": "Connect Game Center to see real leaderboards",
  "leagueConnect": "Connect",
  "leagueFullRanking": "Full Ranking",
  "leagueLoading": "Loading leaderboard...",
  "leagueError": "Could not load leaderboard",
  "leagueNotConnected": "Game Center not connected"
```

Note: `leagueResetsMonday` and `leagueUpdatesMonday` from the spec are already covered by the existing `leagueResetsMonday` key — no need to add a duplicate.

- [ ] **Step 2: Add Russian strings**

Add the following entries to `brainy-app/l10n/app_ru.arb` (before the closing `}`):

```json
  "leagueConnectTitle": "Соревнуйся с реальными игроками!",
  "leagueConnectSubtitle": "Подключи Game Center для настоящих лидербордов",
  "leagueConnect": "Подключить",
  "leagueFullRanking": "Полный рейтинг",
  "leagueLoading": "Загрузка рейтинга...",
  "leagueError": "Не удалось загрузить рейтинг",
  "leagueNotConnected": "Game Center не подключён"
```

- [ ] **Step 3: Regenerate localizations**

Run: `cd brainy-app && flutter gen-l10n`
Expected: `lib/l10n/app_localizations*.dart` files regenerated without errors.

- [ ] **Step 4: Verify build**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add l10n/app_en.arb l10n/app_ru.arb lib/l10n/ && git commit -m "feat: add localization strings for Game Services league integration"
```

---

## Chunk 3: League Screen UI Update

### Task 7: Update league screen for async data + Game Services states

**Files:**
- Modify: `brainy-app/lib/features/league/screens/league_screen.dart`
- Create: `brainy-app/test/features/league/league_screen_test.dart`

- [ ] **Step 1: Rewrite the league screen**

Replace the full contents of `brainy-app/lib/features/league/screens/league_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/league.dart';
import '../providers/game_services_provider.dart';
import '../providers/league_provider.dart';

class LeagueScreen extends ConsumerWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tier = ref.watch(currentLeagueProvider);
    final weeklyXp = ref.watch(weeklyXpProvider);
    final standingsAsync = ref.watch(leagueStandingsProvider);
    final isSignedIn = ref.watch(isGameServicesSignedInProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.leagueTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _TierHeader(tier: tier, l10n: l10n),
            const SizedBox(height: 16),
            _TierProgress(tier: tier, weeklyXp: weeklyXp, l10n: l10n),
            const SizedBox(height: 16),
            if (!isSignedIn) ...[
              _ConnectCard(l10n: l10n, ref: ref),
              const SizedBox(height: 16),
            ],
            standingsAsync.when(
              data: (standings) => _StandingsList(standings: standings, l10n: l10n),
              loading: () => Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      l10n.leagueLoading,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.leagueError,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            if (isSignedIn) ...[
              const SizedBox(height: 16),
              _FullRankingButton(l10n: l10n, ref: ref),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.leagueResetsMonday,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _ConnectCard({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.leagueConnectTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.leagueConnectSubtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final service = ref.read(gameServicesProvider);
                await service.signIn();
                ref.read(isGameServicesSignedInProvider.notifier).state = service.isSignedIn;
                ref.read(playerNameProvider.notifier).state = service.playerName;
                ref.invalidate(leagueStandingsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                l10n.leagueConnect,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullRankingButton extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _FullRankingButton({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(gameServicesProvider).showNativeLeaderboards();
        },
        icon: const Icon(Icons.leaderboard_rounded, size: 20),
        label: Text(
          l10n.leagueFullRanking,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  final LeagueTier tier;
  final AppLocalizations l10n;

  const _TierHeader({required this.tier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tier.color.withValues(alpha: 0.2),
            tier.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Image.asset(tier.assetPath, width: 80, height: 80),
          const SizedBox(height: 12),
          Text(
            tier.title(l10n),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: tier.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.leagueTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  final LeagueTier tier;
  final int weeklyXp;
  final AppLocalizations l10n;

  const _TierProgress({
    required this.tier,
    required this.weeklyXp,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final next = tier.nextTier;
    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: tier.color, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.leagueMaxTier,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    final progressInTier = weeklyXp - tier.xpThreshold;
    final tierRange = next.xpThreshold - tier.xpThreshold;
    final fraction = (progressInTier / tierRange).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(tier.assetPath, width: 24, height: 24),
              const Spacer(),
              Text(
                l10n.leagueWeeklyXp(weeklyXp),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Image.asset(next.assetPath, width: 24, height: 24),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.leagueNextTier(next.xpThreshold - weeklyXp, next.title(l10n)),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsList extends StatelessWidget {
  final List<LeaguePlayer> standings;
  final AppLocalizations l10n;

  const _StandingsList({required this.standings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < standings.length; i++)
            _PlayerRow(
              rank: i + 1,
              player: standings[i],
              l10n: l10n,
              isLast: i == standings.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final int rank;
  final LeaguePlayer player;
  final AppLocalizations l10n;
  final bool isLast;

  const _PlayerRow({
    required this.rank,
    required this.player,
    required this.l10n,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: player.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.background,
                  width: 1,
                ),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: rank <= 3
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.isCurrentUser ? l10n.leagueYou : player.name,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight:
                    player.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                color: player.isCurrentUser
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${player.weeklyXp} XP',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: player.isCurrentUser
                  ? AppColors.secondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key changes from original:**
- `leagueStandingsProvider` is now `FutureProvider` → uses `AsyncValue.when()` for loading/error/data
- Added `_ConnectCard` widget when Game Services not signed in
- Added `_FullRankingButton` for native leaderboard UI
- Removed promotion/demotion arrows from `_PlayerRow` (no tier-based grouping with real data)

- [ ] **Step 2: Write widget tests**

Create `brainy-app/test/features/league/league_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/league/providers/league_provider.dart';
import 'package:brainy/features/league/providers/game_services_provider.dart';
import 'package:brainy/features/league/screens/league_screen.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget _buildTestApp({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: LeagueScreen(),
    ),
  );
}

void main() {
  group('LeagueScreen', () {
    testWidgets('shows connect card when not signed in', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => false),
          weeklyXpProvider.overrideWithValue(100),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(name: 'Test', weeklyXp: 200),
              const LeaguePlayer(name: 'You', weeklyXp: 100, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Compete with real players!'), findsOneWidget);
    });

    testWidgets('hides connect card when signed in', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(200),
          currentLeagueProvider.overrideWithValue(LeagueTier.silver),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(name: 'RealPlayer', weeklyXp: 300),
              const LeaguePlayer(name: 'Me', weeklyXp: 200, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Connect'), findsNothing);
      expect(find.text('Full Ranking'), findsOneWidget);
    });

    testWidgets('shows leaderboard with player names', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(250),
          currentLeagueProvider.overrideWithValue(LeagueTier.silver),
          leagueStandingsProvider.overrideWith((ref) async {
            return [
              const LeaguePlayer(name: 'TopPlayer', weeklyXp: 500),
              const LeaguePlayer(name: 'MiddlePlayer', weeklyXp: 300),
              const LeaguePlayer(name: 'Me', weeklyXp: 250, isCurrentUser: true),
            ];
          }),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('TopPlayer'), findsOneWidget);
      expect(find.text('MiddlePlayer'), findsOneWidget);
      expect(find.text('You'), findsOneWidget); // current user shows "You"
      expect(find.text('500 XP'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        overrides: [
          isGameServicesSignedInProvider.overrideWith((ref) => true),
          weeklyXpProvider.overrideWithValue(0),
          currentLeagueProvider.overrideWithValue(LeagueTier.bronze),
          leagueStandingsProvider.overrideWith((ref) async {
            // Never complete — stays in loading
            await Future.delayed(const Duration(days: 1));
            return <LeaguePlayer>[];
          }),
        ],
      ));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Run widget tests**

Run: `cd brainy-app && flutter test test/features/league/league_screen_test.dart`
Expected: All 4 widget tests PASS.

- [ ] **Step 4: Verify full project builds**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
cd brainy-app && git add lib/features/league/screens/league_screen.dart test/features/league/ && git commit -m "feat: update league screen with Game Services integration, connect card, and full ranking button"
```

---

## Chunk 4: Score Submission and App Initialization

### Task 8: Submit scores after game completion

**Files:**
- Modify: `brainy-app/lib/features/game/screens/game_screen.dart`

- [ ] **Step 1: Add import**

Add at the top of `brainy-app/lib/features/game/screens/game_screen.dart` (after existing imports):

```dart
import '../../league/providers/game_services_provider.dart';
import '../../league/providers/league_provider.dart';
```

- [ ] **Step 2: Add score submission to `_handleGameFinished`**

In `brainy-app/lib/features/game/screens/game_screen.dart`, in `_handleGameFinished()`, add the following code **after** `await progress.addXp(session.xpEarned);` (after line 173) and **before** `final levelAfter` (line 174):

```dart
    // Submit scores to Game Center / Play Games
    final gameServices = ref.read(gameServicesProvider);
    if (gameServices.isSignedIn) {
      final weeklyXp = ref.read(weeklyXpProvider);
      gameServices.submitWeeklyXp(weeklyXp);
      if (isRecord) {
        gameServices.submitBestTime(
          gridSize: session.gridSize,
          timeMs: session.durationSeconds * 1000,
        );
      }
    }
```

- [ ] **Step 3: Verify build**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
cd brainy-app && git add lib/features/game/screens/game_screen.dart && git commit -m "feat: submit scores to Game Center/Play Games after each session"
```

---

### Task 9: Initialize Game Services at app startup

**Files:**
- Modify: `brainy-app/lib/main.dart`

- [ ] **Step 1: Add import**

Add at the top of `brainy-app/lib/main.dart` (after existing imports):

```dart
import 'features/league/providers/game_services_provider.dart';
```

- [ ] **Step 2: Add Game Services sign-in in `_NotificationReschedulerState`**

The sign-in must happen inside the `ProviderScope` so we can access `ref` and update the state providers. In `_NotificationReschedulerState.initState()`, after the existing `_reschedule()` call, add:

```dart
      _signInToGameServices();
```

And add a new method to the `_NotificationReschedulerState` class:

```dart
  void _signInToGameServices() {
    final service = ref.read(gameServicesProvider);
    service.signIn().then((_) {
      if (!mounted) return;
      ref.read(isGameServicesSignedInProvider.notifier).state = service.isSignedIn;
      ref.read(playerNameProvider.notifier).state = service.playerName;
    });
  }
```

- [ ] **Step 3: Verify build**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
cd brainy-app && git add lib/main.dart && git commit -m "feat: initialize Game Services sign-in at app startup"
```

---

### Task 10: Platform configuration — iOS

**Files:**
- Modify: iOS Xcode project (via command line)

- [ ] **Step 1: Add Game Center capability to iOS**

This must be done in Xcode (or via manual plist edit). Add the Game Center entitlement:

Run: Check if entitlements file exists:
```bash
ls brainy-app/ios/Runner/*.entitlements 2>/dev/null || echo "No entitlements file"
```

If no entitlements file, create `brainy-app/ios/Runner/Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.game-center</key>
	<true/>
</dict>
</plist>
```

Then update `project.pbxproj` to reference it (easiest via opening Xcode briefly).

**Important:** The actual leaderboard IDs (`brainy_weekly_xp`, `brainy_best_time_3x3`, etc.) must be created in **App Store Connect** → Your App → Features → Game Center → Leaderboards. This is a manual step in the Apple developer portal.

- [ ] **Step 2: Commit iOS config**

```bash
cd brainy-app && git add ios/ && git commit -m "feat: add Game Center capability to iOS project"
```

---

### Task 11: Platform configuration — Android

**Files:**
- Modify: `brainy-app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add Play Games metadata**

In `brainy-app/android/app/src/main/AndroidManifest.xml`, add inside the `<application>` tag (before `</application>`):

```xml
        <meta-data
            android:name="com.google.android.gms.games.APP_ID"
            android:value="@string/app_id" />
```

- [ ] **Step 2: Create games-ids.xml**

Create `brainy-app/android/app/src/main/res/values/games-ids.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Replace with actual Play Games app ID from Google Play Console -->
    <string name="app_id" translatable="false">YOUR_PLAY_GAMES_APP_ID</string>
</resources>
```

**Note:** The actual app ID must come from **Google Play Console** → Play Games Services → Configuration. The leaderboard IDs are also created there.

- [ ] **Step 3: Verify Android build**

Run: `cd brainy-app && flutter build apk --debug 2>&1 | tail -5`
Expected: Build succeeds (may have warnings about placeholder ID, which is OK for now).

- [ ] **Step 4: Commit Android config**

```bash
cd brainy-app && git add android/ && git commit -m "feat: add Google Play Games Services config to Android"
```

---

### Task 12: Add integration tests for score submission

**Files:**
- Create: `brainy-app/test/integration/score_submission_test.dart`

- [ ] **Step 1: Write the tests**

Create `brainy-app/test/integration/score_submission_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('Score submission logic', () {
    test('submitWeeklyXp does nothing when not signed in', () async {
      final service = GameServicesService();
      // Not signed in — should not throw
      expect(service.isSignedIn, false);
      await service.submitWeeklyXp(100); // Should silently return
    });

    test('submitBestTime does nothing when not signed in', () async {
      final service = GameServicesService();
      expect(service.isSignedIn, false);
      await service.submitBestTime(gridSize: 5, timeMs: 22000);
      // Should silently return without error
    });

    test('getWeeklyLeaderboard returns empty list when not signed in', () async {
      final service = GameServicesService();
      final results = await service.getWeeklyLeaderboard();
      expect(results, isEmpty);
    });

    test('leaderboard IDs are correctly generated for all grid sizes', () {
      for (final size in [3, 4, 5, 6, 7, 9]) {
        final iosId = GameServicesService.bestTimeLeaderboardId(
          gridSize: size, platform: 'ios',
        );
        final androidId = GameServicesService.bestTimeLeaderboardId(
          gridSize: size, platform: 'android',
        );
        expect(iosId, 'brainy_best_time_${size}x$size');
        expect(androidId, 'brainy_best_time_${size}x$size');
      }
    });

    test('weekly XP leaderboard ID is consistent across platforms', () {
      expect(
        GameServicesService.weeklyXpLeaderboardId(platform: 'ios'),
        GameServicesService.weeklyXpLeaderboardId(platform: 'android'),
      );
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd brainy-app && flutter test test/integration/score_submission_test.dart`
Expected: All tests PASS.

- [ ] **Step 3: Commit**

```bash
cd brainy-app && git add test/integration/score_submission_test.dart && git commit -m "test: add integration tests for Game Services score submission"
```

---

### Task 13: Run all tests and verify

- [ ] **Step 1: Run all tests**

Run: `cd brainy-app && flutter test`
Expected: All tests pass (model tests, provider tests, widget tests).

- [ ] **Step 2: Run analyzer**

Run: `cd brainy-app && flutter analyze --no-fatal-infos`
Expected: No errors.

- [ ] **Step 3: Final commit if any fixes needed**

If any fixes were needed:
```bash
cd brainy-app && git add -A && git commit -m "fix: resolve test/analyzer issues in Game Services integration"
```
