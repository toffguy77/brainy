## Decision / Outcome (2026-10-25)

**Implemented** on branch `chore/finish-audit-changes` (f0e1ec8, with audit fixes in 5cbd984, b1391c2, 8a340da and 1e1e279). The app has four modes: classic, reverse, Gorbov-Schulte and letters. The store description (`ios/fastlane/metadata/{ru,en-US}/description.txt:8`) now lists all four accurately. The only open task is manual play on a device (tasks.md 8.3).

Where the result differs from the original proposal:
- **Leaderboards are scoped, not equal.** Game Center time boards are per grid size and have no mode dimension, so only **classic** best times are posted (`session_completion_provider.dart:95`). Weekly XP is posted for every mode.
- **Achievements are mode-agnostic.** For example, `master_5x5` counts a 5×5 in 20 s or less in any mode.
- **Adaptive difficulty** did not exist before this change. It was built here (`training_goals_provider.dart`) and is bounded by each mode's size list and per-mode target.
- **Statistics** were classic-only. They gained a per-mode switcher (`ModeFilterChips`) on the progress and parent screens.
- `records_provider.dart` **did** need a change. It loaded a fixed key list, so reverse/letters records vanished after a restart. It now loads every key.

## Why

The App Store description promises "Несколько режимов игры: классический, обратный, буквенный" / "Multiple game modes: classic, reverse, letters". The app ships two modes, and neither of them is reverse or letters — it has classic and Gorbov-Schulte. The listing has been advertising two modes that do not exist.

Rather than correct the listing down, build what was promised. Both are established Schulte variants with real training value: reverse order exercises descending sequencing, and letters transfers the skill from digits to the alphabet, which is closer to the reading-speed benefit the app claims.

## What Changes

- **Reverse mode** — a Schulte table tapped in descending order, from N² down to 1. Available at every grid size.
- **Letters mode** — a grid of letters tapped in alphabetical order, in the app's active language. Available at 3×3, 4×4 and 5×5 only, because larger grids need more letters than either alphabet has.
- The home screen mode selector grows from a two-way toggle to four modes and is restructured accordingly.
- Records, sessions, coins, XP, streaks and achievements treat the new modes on the same terms as the existing ones. Adaptive difficulty respects each mode's size list. Game Center time boards stay classic-only (see Decision).
- The App Store description keeps its claim of multiple modes and becomes accurate for the first time.

## Capabilities

### New Capabilities
- `reverse-mode`: descending-order Schulte play.
- `letters-mode`: alphabetical-order Schulte play, and the alphabet constraints that bound it.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability describing game modes. -->

## Impact

- `lib/models/game_state.dart` — `GridCell` carries an ordinal (`number`) plus an optional `label`. `GameState.expectedLabel` drives the "find" badge.
- `lib/features/game/providers/game_provider.dart` — adds `generateReverseGrid` and `generateLettersGrid`. One pure `processOrdinalTap` validates classic, reverse and letters. `initGame` clamps the size per mode.
- `lib/features/game/widgets/schulte_grid.dart` — renders letters as well as digits.
- `lib/features/home/screens/home_screen.dart` — a 2×2 mode selector with mode hints. Grid sizes are filtered and clamped per mode (including the parent-fixed size), and the selected mode is persisted.
- `lib/constants/app_constants.dart` — per-mode grid size lists, alphabets, star thresholds and target times for the new modes.
- `lib/features/game/providers/records_provider.dart` — keys were already `{mode}_{size}`, but loading had to read every key so records persist for every mode.
- `lib/constants/game_modes.dart` — `GameModes` identifiers.
- `lib/features/home/providers/training_goals_provider.dart` — adaptive difficulty (new).
- `lib/features/game/providers/session_completion_provider.dart` — result persistence, with the classic-only time-board submission.
- `lib/features/progress/widgets/mode_filter.dart` — per-mode stats switcher.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — mode names and hints.
- `docs/plans/features/game-modes.md` — describes four modes.
- `brainy-app/ios/fastlane/metadata/*/description.txt` — the claim becomes true.

Sequencing: after `remove-monetization-go-free`, so the new modes are built without any gating to thread through.
