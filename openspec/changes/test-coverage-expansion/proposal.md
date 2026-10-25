## Outcome (2026-10-25)

Implemented on `chore/finish-audit-changes`. 126 → 267 tests, ~5 s locally (maintainer-reported); CI
on GitHub not yet run (External). Time is controlled with `fakeAsync` for `GameNotifier`, an injected
clock for `PinLockout`, and an injected `now` for `NotificationService.planReminder`. Refactors made
for testability: `processOrdinalTap`, `coinsForSession`, `buildSessionFrom`, `SessionCompleter`
(moved out of `GameScreen`), `achievementsToUnlock`, `planReminder`, `PinLockout`. Remaining gaps
(wiring between layers, the `ParentPinScreen` widget, beating an existing record, Gorbov
early-completion) are listed in `design.md`.

## Why

The test suite covered the easy things and skipped the load-bearing ones. The areas with the most
logic and the highest cost of failure had no tests.

The game loop for all four modes (classic, reverse, letters, Gorbov) was untested: tap validation for
the three ordinal modes lived in private `GameNotifier` methods, and session and record persistence
lived inside the `GameScreen` widget. Only the pure Gorbov helpers were covered.

Reminder scheduling (off, already played today, schedule; custom time; two message pools) was mixed
with platform calls and untested. The ten achievement conditions were untested. The parent PIN
lockout was untested and reset whenever the screen was left.

Confirmed audit bugs sat in exactly these gaps — the `ShareCard` record lookup that never matched, and
reverse/letters records not reloaded after restart. Both would have been caught by a single test
asserting observable behaviour.

## What Changes

- Pure tap rules for classic, reverse and letters (`processOrdinalTap`) and Gorbov
  (`processGorbovTap`) are covered for correct, wrong, already-found and final taps.
- `GameNotifier` gains `fakeAsync` coverage of countdown, timer, pause/resume, stop on finish, error
  flash, size clamping and timer disposal.
- Session completion moves into `SessionCompleter` and gains coverage of the saved session,
  `{mode}_{size}` records, no overwrite by slower or equal times, persistence across restart,
  classic-only Game Center submission, achievements and character unlocks.
- Achievement rules become the pure `achievementsToUnlock`, covered per condition at its boundary and
  for no re-award.
- Reminder scheduling becomes the pure `NotificationService.planReminder`, covered for every branch,
  custom time, pool threshold and per-day variant.
- PIN lockout moves into `PinLockout` (persisted, injectable clock), covered for limit, expiry,
  persistence and reset on success.
- CI produces a coverage artifact without a threshold.
- New tests follow `test-suite-stabilization`: order-independent, bounded waits, no hangs, within the
  wall-clock budget.

## Capabilities

### New Capabilities
- `behavioural-test-coverage`: which behaviours must be covered by automated tests, and to what
  standard.

### Modified Capabilities
<!-- None: `test-suite-health` in `test-suite-stabilization` covers suite mechanics; this covers what is tested. -->

## Impact

Tests (new, under `brainy-app/test/`):
- `game/ordinal_tap_test.dart`, `game/game_notifier_test.dart`, `game/session_completion_test.dart`
- `progress/achievement_rules_test.dart`
- `services/reminder_plan_test.dart`
- `parent/pin_lockout_test.dart`

Related tests added on the same branch by sibling changes (not claimed here):
`parent/share_card_test.dart` (rewritten, `share-card-record-key-fix`), `home/home_screen_test.dart`,
`home/training_goals_test.dart`, `character/dressed_avatar_test.dart`,
`progress/grid_stats_mode_test.dart`, `game/game_screen_pause_test.dart`.

Production code (testability refactors, under `brainy-app/lib/`):
- `features/game/providers/game_provider.dart`, `features/game/providers/session_completion_provider.dart` (new),
  `features/game/screens/game_screen.dart`
- `features/progress/providers/achievements_provider.dart`
- `shared/services/notification_service.dart`
- `features/parent/providers/pin_lockout.dart` (new), `features/parent/screens/parent_pin_screen.dart`

CI: `.github/workflows/ci.yml` runs `flutter test --coverage` and uploads `lcov.info`.

Sequencing: after `test-suite-stabilization` and `remove-monetization-go-free` — both landed.
