Legend: `[x]` done and verified (evidence given); `[~]` dropped: does not apply because the owner decided on 2026-08-01 to remove the control.

## 1. Decide the semantics

- [x] 1.1 Owner decides: enforce per-session, enforce per-day, or remove the control. Decision: **remove** (2026-08-01, recorded in `proposal.md` and `design.md`).
- [~] 1.2 If merging with `dailyGoalMinutes`, decide whether one setting replaces the other. Dropped because the control was removed by owner decision, so there was nothing to merge. `dailyGoalMinutes` stays as the only time-related setting. It is a goal, not a limit (`home_screen.dart:110-113`, `home_screen.dart:481-527`).
- [x] 1.3 Record the decision in `proposal.md` and `design.md`. The label was removed, not renamed: the `parentMaxSessionTime` ARB key ("Max Session Time" / "Макс. время сессии") was deleted from `l10n/app_en.arb` and `l10n/app_ru.arb`, and the generated getters went with it, in commit `f0e1ec8`. No new strings were added.
- [x] 1.4 If the decision is to remove: delete the control, `parentMaxSessionTimeKey`, the provider field, and the plan section, then close this change. Done in `f0e1ec8`. Its diff deletes `AppConstants.parentMaxSessionTimeKey`, `ParentSettings.maxSessionTimeMinutes`, `setMaxSessionTime`, the settings-screen block and the `parent-panel.md` bullet. Re-verified on 2026-10-25: `grep -rniE "maxSession|sessionTime|parentMaxSession|session_time|timeLimit"` finds nothing in `brainy-app/lib`, `brainy-app/test`, `brainy-app/integration_test`, `brainy-app/l10n` or `docs/plans`.

## 2. Enforce the limit

- [~] 2.1 Read `parentProvider.maxSessionTimeMinutes` when a session starts in `game_screen.dart`. Dropped: control removed by owner decision.
- [~] 2.2 Measure elapsed play time from the end of the countdown, not from screen entry. Dropped: control removed by owner decision.
- [~] 2.3 If per-day, accumulate across sessions using the same day-boundary definition as the streak logic. Dropped: control removed by owner decision.
- [~] 2.4 End the session through the normal completion path with a limit-reached flag, so persistence is reused. Dropped: control removed by owner decision.
- [~] 2.5 Treat 0 as unlimited and skip all limit logic. Dropped: control removed by owner decision.
- [~] 2.6 Do not terminate a session already in progress when the setting changes. Dropped: control removed by owner decision.

## 3. Explain it to the child

- [~] 3.1 Add localized strings for the limit-reached message to `l10n/app_ru.arb` and `l10n/app_en.arb`. Dropped: control removed by owner decision.
- [~] 3.2 Word it as a boundary, not a failure, with no loss framing. Dropped: control removed by owner decision.
- [~] 3.3 Show the message on the result screen when the session ended on the limit. Dropped: control removed by owner decision.
- [~] 3.4 Verify ru and en ARB key sets remain identical and regenerate localizations. Dropped: control removed by owner decision. ARB parity is enforced in CI anyway (`9180bab`).

## 4. Preserve progress

- [~] 4.1 Confirm coins and XP earned before the limit are retained. Dropped: control removed by owner decision.
- [~] 4.2 Confirm no personal record is written for an incomplete session. Dropped: control removed by owner decision.
- [~] 4.3 Confirm the partial session is recorded consistently with other incomplete sessions. Dropped: control removed by owner decision.

## 5. Test

- [~] 5.1 Test that a session ends when the limit is reached. Dropped: control removed by owner decision.
- [~] 5.2 Test that a session completing before the limit is unaffected. Dropped: control removed by owner decision.
- [~] 5.3 Test that unlimited (0) never ends a session. Dropped: control removed by owner decision.
- [~] 5.4 Test that the countdown is excluded from elapsed time. Dropped: control removed by owner decision.
- [~] 5.5 Test that progress is preserved and no record is written. Dropped: control removed by owner decision.
- [~] 5.6 If per-day, test accumulation across sessions and reset at the day boundary. Dropped: control removed by owner decision.

## 6. Verify and document

- [~] 6.1 Manually verify with a 1-minute limit that the message appears and progress is kept. Dropped: control removed by owner decision, so there is no limit to verify.
- [x] 6.2 Update `docs/plans/features/parent-panel.md` to describe the real behaviour. The settings section (`parent-panel.md:45-60`) lists grid size, daily goal, notifications with permission handling, change PIN, legal links, and sound and haptics. It does not mention a session time limit.
- [x] 6.3 Review the parent settings screen and confirm every remaining control changes observable behaviour. Re-run on 2026-10-25 against `brainy-app/lib/features/parent/screens/parent_settings_screen.dart`. Every control has a consumer:
  - Grid size auto/fixed (`:44-53`) → `parent_provider.dart:116-119` → `home_screen.dart:66-73` picks the size, `:135-136` shows the adaptive suggestion only in auto, `:317-335` locks the picker in fixed. Tests: `test/home/home_screen_test.dart:118`.
  - Fixed size chips (`:54-83`) → `parent_provider.dart:121-124` → `home_screen.dart:70-73` (`clampGridSizeForMode`) → game route `home_screen.dart:438`. Tests: `test/home/home_screen_test.dart:150-172`.
  - Daily goal 5/10/15 (`:89-102`) → `user_progress_provider.dart:117-120` (`_persist` notifies, `:141-144`) → home `_DailyGoalBar` (`home_screen.dart:110-113`, `:481-527`) and the dashboard (`parent_dashboard_screen.dart:85`). Tests: `test/home/home_screen_test.dart:98-106`, `test/home/training_goals_test.dart:25`.
  - Sounds (`:110-120`) → `parent_provider.dart:164-167` → `sound_service.dart:13-21,37` gates every `SoundService.play` (`game_provider.dart:326,355,359`, `result_screen.dart:142,173`).
  - Haptics (`:127-138`) → `parent_provider.dart:169-172` → `haptic_service.dart:8-16,19,24,29` (`game_provider.dart:354,358`, `game_screen.dart:193`).
  - Notifications (`:148-165`) → `parent_provider.dart:129-139` asks for permission and returns false on denial. The screen then shows `settingsNotificationsDenied` (`:156-160`). Otherwise it reschedules via `notification_service.dart:89-110`, which cancels when the toggle is off (`:72`, `:109`).
  - Reminder time picker (`:169-233`) and reset (`:234-253`) → `parent_provider.dart:141-162` → `notification_service.dart:74-75,98-103` (the scheduled time). Tests: `test/services/reminder_plan_test.dart`.
  - Change PIN (`:261-265`) → `parent_pin_screen.dart:31` (change mode).
  - Privacy and terms (`:271-280`) → `_openLink` (`:459-460`) with per-locale URLs (`l10n/app_en.arb:178-179`, `l10n/app_ru.arb:178-179`).
  - Version label tap (`:284-315`) copies to the clipboard and shows a snackbar.
