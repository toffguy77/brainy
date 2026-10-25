# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plans

- `docs/plans/features/` — living documentation of app behavior (source of truth)
- Before implementation — read relevant plans (grep tags in YAML frontmatter)
- After implementation — update affected plans in the same commit
- Format: YAML frontmatter with `title` and `tags` fields
- Plan search: grep tags first, fallback to content/filename search, warn if zero results

## Skills

- `/feature` — full feature cycle: questions → plan → checkpoint → implement → test → build → checkpoint → commit → PR
- `/deploy` — bump build number + tag for TestFlight deployment
- `/appstore` — App Store metadata, screenshots, submission
- `/review` — code review against feature plans and coding standards

## Commands

All Flutter commands run from `brainy-app/`:

```bash
# Run on simulator
flutter run

# Build iOS release
flutter build ipa --release

# Run all unit tests
flutter test

# Run a single test file
flutter test test/game/gorbov_tap_logic_test.dart

# Run integration tests (requires running device/simulator)
flutter test integration_test/screenshot_test.dart

# Lint
flutter analyze
```

## Architecture

### Directory layout

```
brainy-app/lib/
  app/             # router.dart, main_shell.dart, theme.dart
  constants/       # AppConstants, AppColors, AppTextStyles — no magic strings
  features/        # feature-first: game, home, character, progress, league,
                   #   onboarding, parent
  models/          # Plain Dart models with Hive adapters (manually written)
  shared/services/ # Firebase, haptic, sound, notification, game services
  l10n/            # ARB files + generated app_localizations*.dart
docs/plans/features/ # Feature plans (source of truth)
```

### State management

Riverpod everywhere — no `setState` in business logic. Providers are hand-written (no code generation) and live inside their feature directory (e.g. `features/game/providers/`).

### Data persistence

- **Hive** (local): sessions, records, user settings, character, progress. Boxes opened at startup in `main.dart`. Hive adapters are written manually.
- **Firestore** (cloud): not used by the app. Leaderboards go through Game Center.
- **Hive box constants**: all box names and key strings are in `AppConstants`.

### Navigation

GoRouter with a `ShellRoute` wrapping the main tab screens (home, character, progress, league). The shell renders `MainShell` (bottom nav). Routes outside the shell: `/onboarding`, `/parent/*`. Router redirects handle onboarding gating and parent PIN verification.

### Game modes

All four modes use `GameNotifier` in `features/game/providers/game_provider.dart`:
- **classic** — tap numbers 1..N² ascending
- **reverse** — tap numbers N²..1 descending
- **gorbov** — alternates white (ascending) and red (descending) numbers
- **letters** — tap letters alphabetically; 3x3–5x5 only, bounded by the shortest supported alphabet

Grid generation and tap logic are pure functions for testability. Every mode and grid size is free —
the app has no paid tier. Adaptive difficulty targets and star thresholds are in `AppConstants`.

### Architecture Rules

- Feature-first: each feature in `lib/features/<name>/`
- Riverpod for all state (no setState in business logic)
- Hive for local data; no cloud storage
- All text localized via ARB files (`l10n/app_ru.arb`, `l10n/app_en.arb`)
- No magic strings — use `lib/constants/`
- Dark theme, brand purple #6C5CE7, animations on actions, haptic on taps
