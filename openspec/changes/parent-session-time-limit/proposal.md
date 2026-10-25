## Decision and Outcome (2026-08-01, verified 2026-10-25)

Owner decision: **remove the "Maximum session time" control entirely.** The app has no play-time limit, and children play as long as they like. The per-session versus per-day question no longer applies.

Outcome: removed in commit `f0e1ec8`. The 2026-10-25 re-check finds no trace of the control in `brainy-app/lib`, `brainy-app/test`, `brainy-app/integration_test`, the ARB files, `AppConstants` or `docs/plans`. This change is a **removal**. The enforcement work it originally proposed (groups 2-5 of `tasks.md`) is dropped.

## Why

The parent settings screen offered "Maximum session time" with options of 5 / 10 / 15 minutes or unlimited. The value was written to Hive and read back into `ParentSettings.maxSessionTimeMinutes`, but nothing else read it. Neither `game_screen.dart` nor `game_provider.dart` consulted it. A parent who chose 5 minutes got no limit and had no way to notice. `docs/plans/features/parent-panel.md` described it as working.

A parental control that silently does nothing breaks a promise to the parent. Shipping it as it was was ruled out, which left two options: enforce it or remove it. The owner chose removal for three reasons:

- A per-session cap would almost never fire. A Schulte table takes 25 to 81 seconds at target pace, against limits of 5 to 15 minutes.
- A per-day budget would need day-boundary handling, a child-facing "time is up" flow and partial-session rules. That is a lot of design and code for a brain-training app whose sessions are already short.
- The product position is that there is no play-time limit.

## What Changes

Removed (all in `f0e1ec8`):
- The "Max session time" segmented control on `parent_settings_screen.dart`.
- `ParentSettings.maxSessionTimeMinutes`, its `copyWith` and load code, and `ParentNotifier.setMaxSessionTime` in `parent_provider.dart`.
- `AppConstants.parentMaxSessionTimeKey`.
- The ARB key `parentMaxSessionTime` in `l10n/app_en.arb` and `l10n/app_ru.arb`, and the generated getters.
- The "Максимальное время сессии" bullet in `docs/plans/features/parent-panel.md`.

Kept as an invariant: every control left on the parent settings screen changes observable behaviour. Later commits on this branch (`f0e1ec8..HEAD`) wired up the controls that were partly decorative. The notifications toggle now asks for permission and reverts on denial. A daily goal control was added that drives the home "Today: X of N min" bar. The fixed grid size is clamped per mode, auto mode gets an adaptive size suggestion, and privacy and terms links were added. See `tasks.md` 6.3 for the control-to-consumer map.

### Orphan Hive value (left in place on purpose)

Devices that ran an older build may still hold an `int` under the string key `'parentMaxSessionTime'` in the user box. It is left alone because it is harmless:
- Nothing reads it, because no code refers to that key any more.
- It is a primitive stored in an untyped box, so no Hive adapter or typeId depends on it and it cannot break deserialization.
- Nothing iterates the user box's keys or values, so it cannot leak into other logic.
- It costs a few bytes.

Deleting it would need a migration step that can never matter to the user.

### `dailyGoalMinutes` follow-up: resolved

The original analysis asked whether the limit duplicated onboarding's `dailyGoalMinutes`, which at the time was stored but unused. That question is closed. With the limit removed, `UserProgress.dailyGoalMinutes` is the only time-related setting. It is a goal, not a limit, and it is used: it can be edited from parent settings (`parent_settings_screen.dart:89-102`) and drives the home daily-goal bar (`home_screen.dart:110-113`) and the dashboard (`parent_dashboard_screen.dart:85`).

## Capabilities

### New Capabilities
- `session-time-limit`: records that the app has **no** parent-configured play-time limit, and requires that every parent-settings control has an observable effect.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for parental controls. -->

## Impact

All code and docs impact landed in `f0e1ec8`: `parent_settings_screen.dart`, `parent_provider.dart`, `app_constants.dart`, both ARB files and generated localizations, and `docs/plans/features/parent-panel.md`. This change folder records the decision and verifies the result. It adds no further code changes.
