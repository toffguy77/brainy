## Status

Verified 2026-10-25 against branch `chore/finish-audit-changes` (commits `f0e1ec8..HEAD`).
Legend: `[x]` done (evidence cited), `[~]` dropped / not applicable (reason given), `[ ]` External
(needs something outside this repo). "Weak" marks a ticked task whose test would not catch every
plausible break of the behaviour. Test paths are relative to `brainy-app/`.

## 1. Prerequisites

- [x] 1.1 Confirm `test-suite-stabilization` has landed and the suite is green and terminating — its code tasks are done; its open items (1.1 stale, 5.1/5.2 CI and branch protection) are External. Maintainer reports 267 tests passing in ~5 s locally; not re-run during this verification
- [x] 1.2 Confirm `remove-monetization-go-free` has landed so no test targets deleted code — code tasks done; remaining items (1.10 manual check, 4.6 dependabot, 5.4 App Store Connect) are manual/External. `test/app/free_access_test.dart` guards that purchase surfaces stay deleted
- [x] 1.3 Record the baseline suite runtime to measure growth against — baseline is 126 tests in 8.7 s (`openspec/changes/test-suite-stabilization/design.md:65`); budget 3 min (same file, line 44)

## 2. Cover the game loop

- [x] 2.1 Decide how to control time in `GameNotifier` tests (injected clock or `fakeAsync`) — `fakeAsync`: `test/game/game_notifier_test.dart` drives the countdown, 1 s ticker and 500 ms error flash with `async.elapse` ('countdown runs 3 seconds, then the timer counts', 'pause stops the clock and resume restarts it', 'disposing the container cancels running timers')
- [x] 2.2 Test that a correct tap marks the cell found and advances the expected number — `test/game/ordinal_tap_test.dart` 'a correct tap marks the cell found and advances' for classic, reverse and letters (`processOrdinalTap`); Gorbov: `test/game/gorbov_tap_logic_test.dart` 'correct white tap advances white counter and switches to red'. Through the notifier: `game_notifier_test.dart` 'finishing stops the clock' taps a whole reverse grid via `GameNotifier.tapCell`
- [x] 2.3 Test that an incorrect tap increments mistakes and applies the time penalty — `ordinal_tap_test.dart` 'a wrong tap penalises and does not advance' (mistakes, `penaltySeconds == AppConstants.mistakePenaltySeconds`, cell not found); `game_notifier_test.dart` 'a wrong tap flashes the error, then clears it' (penalty in `totalSeconds`, error cleared after 500 ms); Gorbov: `test/game/game_loop_test.dart` 'a wrong colour is a mistake even with the right number', `gorbov_tap_logic_test.dart` 'right color wrong number is an error'
- [x] 2.4 Test classic-mode completion at the final number — `ordinal_tap_test.dart` 'the last ordinal finishes the game' asserts `playing` after every tap but the last and `finished` on it (all three ordinal modes); `game_loop_test.dart` 'classic is not complete one tap early'
- [x] 2.5 Test Gorbov-mode alternation and that completion requires both sequences exhausted — `gorbov_tap_logic_test.dart` 'correct sequence: W1 -> R4 -> W2 -> R3' and 'game completes when all cells found'. **Weak:** completion is asserted only after the final tap; nothing asserts the game is *not* complete after R1 with W5 still open, so `&&` → `||` in `GameState.isCompleted` (`lib/models/game_state.dart:82`) would pass. The fixture is a hand-built 3×3 the app never produces (Gorbov is clamped to ≥5). `GameNotifier.tapCell`'s Gorbov dispatch (`game_provider.dart:347-349`) has no notifier-level tap test
- [x] 2.6 Test that a completed session is persisted with grid size, duration, mistakes, mode and coins — `test/game/session_completion_test.dart` 'a finished game is saved with its mode, size, time and coins' reads the session back from Hive and checks `sessionsProvider`, coins balance and that the reminder was rescheduled; `ordinal_tap_test.dart` 'a session carries mode, size, total time with penalty and mistakes' (`buildSessionFrom`, duration includes penalty)
- [x] 2.7 Test that a personal record is written under the correct `{mode}_{size}` key when beaten — `session_completion_test.dart` 'a first result is a record under the {mode}_{size} key' (`letters_4` written, `classic_4` untouched) and 'reverse and letters records survive an app restart'. **Weak:** every test that writes a record starts from an empty slot; no test beats an *existing* record, so reducing `RecordsNotifier.isPersonalRecord` (`records_provider.dart:52`) to `current == null` would pass the suite
- [x] 2.8 Test that a slower session does not overwrite an existing record — `session_completion_test.dart` 'a slower or equal game does not overwrite the record' (slower and equal times; coins without record bonus) and the post-restart check in 'reverse and letters records survive an app restart'
- [x] 2.9 Note any refactoring required for testability, and keep it minimal — recorded in `design.md` Outcome: `processOrdinalTap`, `coinsForSession`, `buildSessionFrom` (pure, `game_provider.dart`), `SessionCompleter` moved out of `GameScreen` (`session_completion_provider.dart`, reminder injectable), timers cancelled in `ref.onDispose`

## 3. Cover notification rescheduling

- [x] 3.1 Test that disabled notifications cancel and schedule nothing — `test/services/reminder_plan_test.dart` 'disabled reminders schedule nothing' (`NotificationService.planReminder` returns null). The cancel itself is the unconditional `_plugin.cancel` in `rescheduleFromStorage` (`notification_service.dart:109`), platform code left untested per 3.7
- [x] 3.2 Test that having played today cancels and schedules nothing — `reminder_plan_test.dart` 'having played today schedules nothing, even on a long streak'; the "today" decision: 'hasPlayedOn matches the calendar day only' (00:01 today vs 23:59 yesterday). Same cancel caveat as 3.1
- [x] 3.3 Test that not having played schedules a notification — `reminder_plan_test.dart` 'not having played schedules at the default time'
- [x] 3.4 Test that a custom reminder time is honoured over the default — `reminder_plan_test.dart` 'a custom time wins only when the custom flag is set' (07:30 vs default 20:00, both flag states)
- [x] 3.5 Test that the streak-warning pool is chosen above the streak threshold — `reminder_plan_test.dart` 'the streak-warning pool starts above the threshold' (threshold → motivational, threshold+1 → warning)
- [x] 3.6 Test that variant selection is deterministic for a given day — `reminder_plan_test.dart` 'variant index is pinned to the calendar date' (fixed indices, time-of-day/DST independence); `test/services/notification_text_test.dart` 'the daily index is deterministic for a given day', 'the index changes from one day to the next'
- [x] 3.7 Keep the tests on decision logic, not platform delivery — scheduling decision extracted to pure `planReminder(..., now:)`; no test touches `FlutterLocalNotificationsPlugin`. Not covered as a consequence: the Hive reads feeding it (`notification_service.dart:89-107`)

## 4. Cover achievements

- [x] 4.1 Enumerate the shipped `AchievementId` values as the authority — `test/progress/achievements_test.dart` 'every AchievementId has a definition', 'known keys have not drifted'
- [x] 4.2 Test that each condition unlocks its achievement — `checkAchievements`' rules were extracted to pure `achievementsToUnlock` (`achievements_provider.dart`); `test/progress/achievement_rules_test.dart` has a test for every one of the ten ids: 'first_game needs at least one saved session', 'personal_record follows the session flag', 'speed_demon: 3x3 in 5 seconds or less', 'master_5x5: 5x5 in 20 seconds or less, any mode', 'focus_mode: no mistakes', 'streak achievements unlock at 3, 7 and 30 days', 'night_owl: a session started at 22:00 or later', 'coin_hoarder: a balance of 500 coins'. End to end through persistence: `session_completion_test.dart` 'first game unlocks first_game and personal_record achievements'
- [x] 4.3 Test that an already-unlocked achievement is not awarded twice — `achievement_rules_test.dart` 'an already unlocked achievement is never granted again'; `session_completion_test.dart` 'first game unlocks first_game and personal_record achievements' (second session does not re-announce `first_game`)
- [x] 4.4 Confirm each test fails when its condition is inverted — by reading: every rule in `_isEarned` has an assertion on both sides of its boundary (`[]`/`[s]`, flag true/false, 5/6 s and 4×4, 20/21 s and 4×4, 0/1 mistakes, streak 2/3, 6/7, 29/30, hour 21/22, coins 499/500), and dropping the already-unlocked filter fails the 4.3 test. Not verified by mutation run

## 5. Cover PIN protection

- [x] 5.1 Test that a first four-digit entry sets the PIN and grants access — `test/parent/parent_pin_test.dart` 'setting a PIN marks one as present', 'a stored PIN survives a fresh provider container', 'the PIN is not stored in plain text'. **Weak:** storage layer only (`ParentNotifier.setPin`). The screen's enter-and-confirm flow, the mismatch-is-not-a-guess rule and `parentPinVerifiedSession = true` (`parent_pin_screen.dart:80-100`) have no test
- [x] 5.2 Test that the correct PIN verifies — `parent_pin_test.dart` 'the correct PIN verifies', 'changing the PIN invalidates the old one'
- [x] 5.3 Test that an incorrect PIN is refused and counted — refused: `parent_pin_test.dart` 'an incorrect PIN is refused', 'verification fails when no PIN is stored'; counted: `test/parent/pin_lockout_test.dart` 'attempts below the limit do not lock'. **Weak:** the wiring between them (`_handleWrongPin`, `parent_pin_screen.dart:132`) is untested
- [x] 5.4 Test that reaching the attempt limit triggers the lockout — `pin_lockout_test.dart` 'reaching the limit locks for the lockout duration and resets the count' (limit−1 in the test above does not lock); 'the lockout survives a new instance (screen re-entry or restart)'
- [x] 5.5 Test that the lockout expires after its duration, using faked time — `pin_lockout_test.dart` 'the lockout expires after its duration' with an injected clock (`PinLockout(box, now: ...)`): locked 1 s before, unlocked at the deadline; 'a correct PIN clears the attempt count'

## 6. Keep the suite healthy

- [x] 6.1 Run each new test alone and in the full suite; confirm identical results — full suite green per maintainer; isolation by construction (each new file opens its own temp Hive dir in `setUpAll`, clears boxes in `setUp`, builds a fresh `ProviderContainer` per test). Per-file solo runs not re-verified here
- [x] 6.2 Confirm no new test uses an unbounded wait — new files use `fakeAsync`, an injected clock or fixed `pump` durations; the only real-time wait is `runAsync` + 50 ms in `test/home/home_screen_test.dart`. `pumpAndSettle` appears only in pre-existing league tests
- [x] 6.3 Confirm the full suite stays within its wall-clock budget — 267 tests in ~5 s (maintainer, local) against the 3-minute budget and the 8.7 s baseline
- [ ] 6.4 Confirm the CI gate still passes within its ten-minute limit — External: CI has not run on GitHub for this branch yet (`.github/workflows/ci.yml:28` sets `timeout-minutes: 10`)
- [x] 6.5 Decide whether to produce a coverage report for visibility, without setting a threshold — decided yes: `flutter test --coverage` and an `lcov.info` artifact upload, no threshold (`.github/workflows/ci.yml:57-65`)
